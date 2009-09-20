module(..., package.seeall)

actions = {}

local tmpl = [=[
<h2>$title</h2>
<p>$description</p>
<h3>Snippet</h3>
<pre>$code</pre>
<hr>
<div>Posted by $author at $date</div>]=]

function actions.show_snippet(node, request, sputnik)
    node.inner_html = cosmo.f(tmpl){
        title = node.title,
        description = node.markup.transform(node.description),
        code = node.content,
        author = node.author,
        date = sputnik:format_time_RFC822(node.creation_time),
    }

    return node.wrappers.default(node, request, sputnik)
end

local wiki = require("sputnik.actions.wiki")
local util = require("sputnik.util")

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
