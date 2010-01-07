module(..., package.seeall)
actions = {}

local wiki = require("sputnik.actions.wiki")
local util = require("sputnik.util")
local recipes = require("sputnik.recipes")

local empty = recipes.empty

local function unedited_module (node)
    return empty(node.project_name) or empty(node.project_url)
end

local snippets_tmpl = [=[
$extra
$content

<h2>$title</h2>
<ul>
$do_snippets[[
    <li><a href="/?p=$id">$title</a></li>
]]
</ul>
]=]

function list_snippets_text (snippets,node,title,extra)
    return cosmo.f(snippets_tmpl) {
        content = node.markup.transform(node.content or ""),
        title = title,
        extra = extra or '',
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
    <li><a href="/?p=$base/$tag">$tag</a> ($count) $extra</li>
]]
</ul>
]=]

function list_items_text (items,base,title)
    return cosmo.f(items_tmpl) {
        title = title,
        base = base,
        do_items = function()
            for _,item in ipairs(items) do
                cosmo.yield{tag = item.name, count = item.value, extra = item.extra or ''}
            end
        end
    }
end

function actions.list_tags(node, request, sputnik)
    local tags = recipes.get_all_tags(sputnik)
    node.inner_html = list_items_text(tags,"tags","Tags")
    return node.wrappers.default(node, request, sputnik)
end

function actions.list_modules (node, request, sputnik)
    local modules = recipes.get_all_modules(sputnik)
    for _,mod in ipairs(modules) do
        local m = sputnik:get_node('modules/'..mod.name)
        if not unedited_module (m) then
            mod.extra = ('<a href="%s">%s</a>'):format(m.project_url,m.project_name)
        end
    end
    node.inner_html = list_items_text(modules,"modules","Modules")
    return node.wrappers.default(node, request, sputnik)
end

function actions.list_authors (node, request, sputnik)
    local authors = recipes.get_all_authors(sputnik)
    node.inner_html = list_items_text(authors,"authors","Authors")
    return node.wrappers.default(node, request, sputnik)
end

function actions.list_tag_snippets (node, request, sputnik)
    local index_of,extract_tags = recipes.index_of,recipes.extract_tags
    local this_tag = node.id:gsub('tags/','')
    local snippets = recipes.get_snippets(sputnik)
    local snippets_for_tag  = recipes.filter_snippets(snippets,function(snippet)
        return index_of(extract_tags(snippet),this_tag)
    end)
    node.inner_html = list_snippets_text(snippets_for_tag,node,"Snippets Using This Tag")
    return node.wrappers.default(node, request, sputnik)
end

local mod_tmpl = [=[
    <p>Provided by <a href="$url">$project</a></p>
]=]

function actions.list_module_sniippets (node, request, sputnik)
    local index_of,extract_modules = recipes.index_of,recipes.extract_modules
    local this_module = node.id:gsub('modules/','')
    local snippets = recipes.get_snippets(sputnik)
    local snippets_for_module  = recipes.filter_snippets(snippets,function(snippet)
        return index_of(extract_modules(snippet),this_module)
    end)
    local provided_str = ''
    if not unedited_module(node) then
        provided_str =  cosmo.f(mod_tmpl) { url = node.project_url, project = node.project_name }
    end
    node.inner_html = list_snippets_text(snippets_for_module,node,"Snippets Using This Module",provided_str)
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
    node.inner_html = list_snippets_text(snippets_for_author,node,"Snippets by this Author")
    return node.wrappers.default(node, request, sputnik)
end

