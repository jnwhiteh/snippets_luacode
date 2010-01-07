module(..., package.seeall)
actions = {}

local wiki = require("sputnik.actions.wiki")
local util = require("sputnik.util")
local recipes = require("sputnik.recipes")

local snippets_tmpl = [=[
$content

<h2>$title</h2>
<ul>
$do_snippets[[
    <li><a href="/?p=$id">$title</a></li>
]]
</ul>
]=]

function list_snippets_text (snippets,node,title)
    return cosmo.f(snippets_tmpl) {
        content = node.markup.transform(node.content or ""),
        title = title,
        do_snippets = function()
            for _,snippet in ipairs(snippets) do
                cosmo.yield { title = snippet.title, id = snippet.id }
            end
        end
    }
end

local items_tmpl = [=[
<h2>$title</h2>
<ul>
$do_items[[
    <li><a href="/?p=$base/$tag">$tag</a> ($count)</li>
]]
</ul>
]=]

function list_items_text (items,base,title)
    return cosmo.f(items_tmpl) {
        title = title,
        base = base,
        do_items = function()
            for _,item in ipairs(items) do
                cosmo.yield{tag = item.name, count = item.value}
            end
        end
    }
end

function actions.list_tags(node, request, sputnik)
    local tags = recipes.get_all_tags(sputnik)
    node.inner_html = list_items_text(tags,"tags","Tags")
    return node.wrappers.default(node, request, sputnik)
end

function actions.list_authors (node, request, sputnik)
    local authors = recipes.get_all_authors(sputnik)
    node.inner_html = list_items_text(authors,"authors","Authors")
    return node.wrappers.default(node, request, sputnik)
end

function actions.list_snippets (node, request, sputnik)
    local index_of = recipes.index_of
    local this_tag = node.id:gsub('tags/','')
    local snippets = recipes.get_snippets(sputnik)
    local snippets_for_tag  = recipes.filter_snippets(snippets,function(snippet)
        local tags = recipes.extract_tags(snippet)
        return index_of(tags,this_tag)
    end)
    node.inner_html = list_snippets_text(snippets_for_tag,node,"Snippets Using This Tag")
    return node.wrappers.default(node, request, sputnik)
end

local function author_from_node (node)
    return node.id:gsub('authors/',''):gsub('_',' ')
end

function actions.list_author_snippets (node, request, sputnik)
    local author = author_from_node(node)
    local snippets = recipes.get_snippets(sputnik)
    local snippets_for_author = recipes.filter_snippets(snippets,function(snippet)
        return snippet.author == author
    end)
    sputnik.saci.permission_groups.Author = function(user,node)
        if not user then return false end
        local author = author_from_node(node)
        local res = user=='Admin' or user==author
       -- print('id',user,author,res)
        return res
    end
    node.inner_html = list_snippets_text(snippets_for_author,node,"Snippets by this Author")
    return node.wrappers.default(node, request, sputnik)
end

