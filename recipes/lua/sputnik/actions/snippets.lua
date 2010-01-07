module(..., package.seeall)
actions = {}

local wiki = require("sputnik.actions.wiki")
local util = require("sputnik.util")
local recipes = require("sputnik.recipes")
local parser = require("sputnik.recipes.parser")
local hook = require("sputnik.hooks.snippets")
local append = table.insert

local tmpl = [=[
$error
<p>$navigate</p>
<p>$description</p>
<p><b>Author:</b> <a href="/?p=authors/$author">$author</a><p>
<p><b>License:</b> $licence
<b>Tags:</b>
$do_tags[[
    <a href="/?p=tags/$tag">$tag</a>
]]
</p>
<h3>Snippet</h3>
<pre>$code</pre>
$required
<p><b>Related Snippets</b></p>
<ul>
$do_related[[
    <li><a href="/?p=$id">$name </a> ($score) </li>
]]
</ul>
<hr>
<div>Revision $revision by $editor; created $date</div>]=]

local required_tmpl = [=[
<p><b>Required</b></p>
<ul>
$do_required[[
    <li><a href="/?p=$id">$name</a></li>
]]
</ul>
]=]

function actions.show_snippet(node, request, sputnik)
    local info = sputnik.saci:get_node_info(node.id)
    if not info or request.params.title then
        -- we are previewing a node, may be unsaved; use the form fields in preference to node fields
        for k,v in pairs(request.params) do
            node[k] = v
        end
        node.creation_time = tostring(os.time())
        node.author = request.user or "Anonymous user"
        node.error = "Preview"
        if not node.description then node.description = "" end
        info = {author = node.author, version = '00000'}
    end
    local snippets = recipes.get_snippets(sputnik)
    local tags = recipes.extract_tags(node)
    local uids = recipes.get_snippets_in_order(sputnik,snippets)
    local uid = recipes.get_uid(node.id)
    local idx  = recipes.index_of(uids,uid,'uid')
    local related = recipes.relevant_snippets(node,sputnik,snippets)

    local function ref_by_uid (delta,text)
        if idx == nil then return "" end
        local nidx = idx + delta
        if nidx <= #uids and nidx > 1 then
            return (('<a href="/?p=%s">%s</a>'):format(uids[nidx].id,text))
        else
            return ""
        end
    end

    local needs,required = recipes.get_list(node.needs),recipes.get_list(node.requires)

    local reqstr
    if #needs > 0 or #required > 0 then
        local req = {}
        for _,id in ipairs(needs) do
            local snip = snippets[id]
            append(req,{id,snip.title})
        end
        for _,id in ipairs(required) do
            local name
            if not id:find 'snippets/' then
                name = id
                id = 'tags/'..id
            else
                name = snippets[id].title
            end
            append(req,{id,name})
        end
        reqstr = cosmo.f(required_tmpl) {
            do_required = function()
                for _,r in ipairs(req) do
                    cosmo.yield{id = r[1], name = r[2]}
                end
            end
        }
    else
        reqstr = ''
    end

    node.inner_html = cosmo.f(tmpl){
        title = node.title,
        navigate = ref_by_uid(-1,'Previous')..' '..ref_by_uid(1,'Next'),
        this = node.id,
        required = reqstr,
        error = (node.error and #node.error > 0) and ('<h2 style="color:red">%s</h2> '):format(node.error) or '',
        description = node.markup.transform(node.description),
        code = node.content,
        author = node.author,
        licence = node.licence ,
        revision = info.version,
        editor = #info.author > 0 and info.author or node.author,
        date = sputnik:format_time_RFC822(node.creation_time),
        do_tags = function()
            for i = 1,#tags do
                cosmo.yield {tag = tags[i]}
            end
        end,
        do_related = function()
            for _,r in ipairs(related) do
                cosmo.yield {id = r.snippet.id, name = r.snippet.title, score = r.score}
            end
        end
    }
    return node.wrappers.default(node, request, sputnik)
end


function actions.rss(node, request, sputnik)
   local title = "Recent Additions to '" .. node.title .."'"  --::LOCALIZE::--

   local items = wiki.get_visible_nodes(sputnik, request.user, node.id.."/")
   table.sort(items, function(x,y) return x.id > y.id end )

   local tmpl = [=[
   <p>$description</p>
   <h3>Snippet</h3>
   <pre>$code</pre>]=]

   local url_format = string.format("http://%s%%s", sputnik.config.DOMAIN)
   return cosmo.f(node.templates.RSS){
      title   = title,
      baseurl = sputnik.config.BASE_URL,
      channel_url = url_format:format(sputnik:make_url(node.id, request.action)),
      items   = function()
                   for i, item in ipairs(items) do
                      local inode = sputnik:decorate_node(item)
                      local summary = cosmo.f(tmpl){
                         description = inode.markup.transform(tostring(inode.description)),
                         code = inode.content,
                      }
                      local node_info = sputnik.saci:get_node_info(item.id)
                       cosmo.yield{
                          link        = url_format:format(sputnik:make_url(item.id)),
                          title       = util.escape(item.title),
                          ispermalink = "false",
                          guid        = item.id,
                          author      = util.escape(node_info.author),
                          pub_date    = sputnik:format_time_RFC822(node_info.timestamp),
                          summary     = util.escape(summary),
                       }
                   end
                end,
   }, "application/rss+xml"
end
