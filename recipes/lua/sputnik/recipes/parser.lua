local lexer = require 'sputnik.recipes.lexer'
module ('sputnik.recipes.parser',package.seeall)

local globals = {
    string = "table",
    xpcall = "function",
    package = "table",
    tostring = "function",
    print = "function",
    os = "table",
    unpack = "function",
    require = "function",
    getfenv = "function",
    setmetatable = "function",
    next = "function",
    assert = "function",
    tonumber = "function",
    io = "table",
    rawequal = "function",
    collectgarbage = "function",
    arg = "table",
    getmetatable = "function",
    module = "function",
    rawset = "function",
    tp = "string",
    math = "table",
    debug = "table",
    pcall = "function",
    table = "table",
    newproxy = "function",
    type = "function",
    coroutine = "table",
    _G = "table",
    select = "function",
    gcinfo = "function",
    pairs = "function",
    rawget = "function",
    loadstring = "function",
    ipairs = "function",
    _VERSION = "string",
    dofile = "function",
    setfenv = "function",
    load = "function",
    error = "function",
    loadfile = "function",
}

local append = table.insert

function token_list (s)
    local tt = {{type='space',value=''}}
    for token,value in lexer.lua(s,{space=true,comments=true}) do
        if token == 'keyword' then
            token = value
        end
        append(tt,{type=token,value=value})
    end
    return tt
end

local function dump (msg,t)
    io.write(msg,': ')
    for v in pairs(t) do
        io.write(v,' ')
    end
    print()
end

local function set2list (t)
    local res = {}
    for v in pairs(t) do
        res[#res+1] = v
    end
    return res
end

local function specialize (fun,value)
    return function(a) return fun(a,value) end
end

function scan_lua_code (s)
    local tt = token_list(s)
    local declared = {}
    local requires,foreign,export_fun,export_mod = {},{},{},{}
    local function string_arg (i)
        if tt[i+1].type == '(' then i = i + 1 end
        if tt[i+1].type == 'string' then
            return tt[i+1].value
        end
    end

    local function skip_list (i,delim_set)
        i = i + 1
        while delim_set[tt[i].type] do
            i = i + 2
        end
        return i
    end

    local var_chain = {['.']=true,[':']=true}
    local skip_var_chain = specialize(skip_list,var_chain)
    local skip_arg_list = specialize(skip_list,{[',']=true})

    local function declare (name)
        declared[name] = true
        --print('declared',name)
    end

    local function declare_list (i)
        i = i + 1
        repeat
            declare(tt[i].value)
            i = i + 2
        until tt[i-1].type ~= ','
        i = i - 1
        return i
    end

    local i,n = 1,#tt
    while i <= n do
        local t = tt[i]
        if  t.type == 'function' then
            local lastt,nextt,name = tt[i-1],tt[i+1]
            if nextt.type == 'iden' then
                name = nextt.value
                i = i + 2
                if var_chain[tt[i].type] then
                    while var_chain[tt[i].type] do
                        name = name .. tt[i].type .. tt[i+1].value
                        i = i + 2
                    end
                    i = i - 1
                end
                declare(name)
            else
                i = i + 1
            end
            i = i + 1
            if tt[i].type ~= ')' then
                while tt[i-1].type ~= ')' do
                    declare(tt[i].value)
                    i = i + 2
                end
                i = i - 1
            end
            -- global function as export
            if lastt.type ~= 'local' and lastt.type ~= '=' and name then
                export_fun[name] = true
            end
        elseif  t.value == 'module' then -- module as export
            local mod = string_arg(i)
            if mod then export_mod[mod] = true end
        elseif t.value == 'for' then -- implicit declaration in for statement
            i = declare_list(i)
        elseif t.value == 'local' and tt[i+1].type ~= 'function' then
            i = declare_list(i)
        end
        if t.value == 'require' then
            local mod = string_arg(i)
            if mod then
                requires[mod] = true
                declare(mod)
            end
        elseif t.type == 'iden' then
            local name = t.value
            local tp = globals[name]
            if tp == 'table' then -- e.g. io.write, io.stdout:write
                i = skip_var_chain(i)
            elseif tp == nil and not declared[name] then
                -- might be a declaration
                if tt[i-1].type == 'function' or tt[skip_arg_list(i)].type == '=' then
                    declare(name)
                else
                    foreign[name] = true
                end
            elseif declared[name] then -- e.g. obj:method()
                i = skip_var_chain(i)
            end
        end
        i = i + 1
    end
    return {
        export_fun = set2list(export_fun),
        export_mod = set2list(export_mod),
        require_map = requires,
        foreign_map = foreign,
        requires = set2list(requires),
        foreign = set2list(foreign)
    }
end


