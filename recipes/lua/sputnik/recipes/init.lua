
module ('sputnik.recipes',package.seeall)
local util = require("sputnik.util")

local append = table.insert

function index_of (tbl,val,key)
    if not key then
        for i,v in ipairs(tbl) do
            if v == val then return i end
        end
    else
        for i,v in ipairs(tbl) do
            if v[key] == val then return i end
        end
    end
end

function empty (val)
    return val==nil or #val == 0
end

-- note the convention for 'removed' snippets; they are just made hidden

function get_snippets (sputnik)
    local t = sputnik.saci:get_nodes_by_prefix 'snippets'
    for id,snip in pairs(t) do
        if snip.title == '' then t[id] = nil end
    end
    return t
end

function remove_snippet(sputnik,node)
   sputnik:update_node_with_params(node, {title = ''})
   node:save()
end

function get_uid (id)
    return id:match('_(%d+)$')
end

function get_snippet_uids (sputnik,snippets)
    snippets = snippets or get_snippets(sputnik)
    local get_uid = get_uid
    local res = {}
    for id,snip in pairs(snippets) do
        res[get_uid(id)] = id
    end
    return res
end

function get_snippet_from_uid(uid,sputnik,snippets)
    snippets = snippets or get_snippets(sputnik)
    for id,snip in pairs(snippets) do
        if get_uid(id) == uid then
            return id
        end
    end
end

function get_snippets_in_order (sputnik,snippets)
    snippets = snippets or get_snippets(sputnik)
    local res = {}
    for id,snip in pairs(snippets) do
        append(res,snip)
    end
    table.sort(res,function(a,b) return tonumber(a.uid) < tonumber(b.uid) end)
    return res
end

function filter_snippets (snippets,condn)
    local res = {}
    for id,snippet in pairs(snippets) do
        if condn(snippet) then
            append(res,snippet)
        end
    end
    return res
end

-- if we later choose to store tags etc as lists, this can be changed

function list (t)
    return table.concat(t,' ')
end

function get_list (val)
    if not val or #val == 0 then return {}
    else return {util.split(val or '','%s+')}
    end
end

local get_list_ = get_list

function extract_tags (snippet)
    return get_list_(snippet.tags)
end

function extract_modules (snippet)
    local ls = get_list_(snippet.requires)
    if #ls == 0 then return ls end
    local res = {}
    for _,r in ipairs(ls) do
        if not r:find '^snippets/' then append(res,r) end
    end
    return res
end


-- given two tag lists, return all the tags in tags1 also present in tags2
function intersection (tags1,tags2)
    local res = {}
    for _,t in ipairs(tags1) do
        if index_of(tags2,t) then
            append(res,t)
        end
    end
    return res
end

function node_history (sputnik,id)
    local history = sputnik:get_history (id)
    if not history then return {} end
    local res = {}
    for i = 1,#history do
        local h = history[i]
        res[i] = sputnik:get_node(id,h.version)
        res[i].timestamp = h.timestamp
        res[i].editor = h.author
    end
    return res
end

function update_count_map (map,key)
    if not map[key] then
        map[key] = 0
    end
    map[key] = map[key] + 1
end

local function map_to_sorted_list (map)
    local res = {}
    for key,val in pairs(map) do
        append(res,{name=key,value=val})
    end
    table.sort(res,function(a,b) return a.name < b.name end)
    return res
end

function get_all_tags (sputnik)
    local tbl = get_snippets(sputnik)
    local tagmap = {}
    for _,snippet in pairs(tbl) do
        local tags = extract_tags(snippet)
        for _,tag in ipairs(tags) do
            update_count_map(tagmap,tag)
        end
    end
    return map_to_sorted_list(tagmap)
end

function get_all_authors (sputnik)
    local tbl = get_snippets(sputnik)
    local authors = {}
    for _,snippet in pairs(tbl) do
        if snippet.author then
            update_count_map(authors,snippet.author)
        end
    end
    return map_to_sorted_list(authors)
end

function get_all_modules (sputnik)
    local tbl = get_snippets(sputnik)
    local map = {}
    for _,snippet in pairs(tbl) do
        for _,mod in ipairs(extract_modules(snippet)) do
            update_count_map(map,mod)
        end
    end
    return map_to_sorted_list(map)
end

-- given a snippet node, return a table of relevant snippets according to tag match score.
-- In this simple implementation, the score is the number of tags in common.
-- Each entry of the result has fields snippet and score.
function relevant_snippets (snippet,sputnik,snippets)
    snippets = snippets or get_snippets(sputnik)
    local our_tags = extract_tags(snippet)
    local relevant = {}
    for _,other in pairs(snippets) do
        if other ~= snippet then
            local other_tags = extract_tags(other)
            local common = intersection(our_tags,other_tags)
            if #common > 0 then
                append(relevant,{snippet=other,score=#common})
            end
        end
    end
    table.sort(relevant, function(a,b) return a.score > b.score end)
    return relevant
end
