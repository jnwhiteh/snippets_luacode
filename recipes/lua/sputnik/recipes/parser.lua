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
    local tt = {{type='space',value=''}} -- so tt[i-1] is always valid
    for token,value in lexer.lua(s,{space=true}) do --  ,comments=true}) do
        if token == 'keyword' then
            token = value
        end
        append(tt,{type=token,value=value})
    end
    return tt
end

local function dump (msg,t)
    io.write(msg,': ')
    for k,v in pairs(t) do
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
        while tt[i] and delim_set[tt[i].type] do
            i = i + 2
        end
        return i
    end

    local var_chain = {['.']=true,[':']=true}
    local skip_var_chain = specialize(skip_list,var_chain)
    local skip_arg_list = specialize(skip_list,{[',']=true})

    local function eof(i)
        return not tt[i+2] or (tt[i+2].value == ';' and not tt[i+3])
    end

    local function declare (name,field)
        if field then
            if declared[name] == nil or declared[name] == true then
                declared[name] = {}
            end
            declared[name][field] = true
        else
            declared[name] = true
        end
        --print('declared',name,field)
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

    local blevel = 1

    local i,n = 1,#tt
    while i <= n do
        local t = tt[i]
        if  t.type == 'function' then
            blevel = blevel + 1
            local lastt,nextt,name = tt[i-1],tt[i+1]
            local fname
            if nextt.type == 'iden' then
                name = nextt.value
                i = i + 2
                if var_chain[tt[i].type] then
                    fname = ''
                    while var_chain[tt[i].type] do
                        fname = fname .. tt[i].type .. tt[i+1].value
                        i = i + 2
                    end
                    --i = i - 1
                end
                declare(name,fname)
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
            -- global function as export, unless the function was inside a table
            if lastt.type ~= 'local' and lastt.type ~= '=' and name and not fname then
                export_fun[name] = true
            end
        elseif  t.value == 'module' then -- module as export
            local mod = string_arg(i)
            if mod then export_mod[mod] = true end
        elseif t.value == 'for' then -- implicit declaration in for statement
            i = declare_list(i)
            blevel = blevel + 1
        elseif t.value == 'local' and tt[i+1].type ~= 'function' then
            i = declare_list(i)
            blevel = blevel + 1
        elseif t.value == 'if' then
            blevel = blevel + 1
        elseif t.value == 'repeat' then
            blevel = blevel + 1
        elseif t.value == 'end' then
            blevel = blevel - 1
        elseif t.value == 'until' then
            blevel = blevel - 1
        elseif t.value == 'return' then
            if tt[i+1].type == 'iden' and eof(i) then
                export_mod[tt[i+1].value] = true  -- 'new style' module
            end
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
        elseif t.type == 'comment' then
            local type,name = t.value:match('@(%w+)%s+(.+)')
            if type == 'class' or type == 'function' then
                export_fun[name] = true
            elseif type == 'module' then
                export_mod[name] = true
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

