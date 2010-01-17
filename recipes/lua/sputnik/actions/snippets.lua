module(..., package.seeall)
actions = {}

local wiki = require("sputnik.actions.wiki")
local util = require("sputnik.util")
local recipes = require("sputnik.recipes")
local parser = require("sputnik.recipes.parser")
local hook = require("sputnik.hooks.snippets")
local append = table.insert
local empty = recipes.empty

---- managing user comments on a per snippet basis ---

function actions.edit_comment (node, request, sputnik)
    -- this doesn't do what it says: it is _meant_ to clear the text, since this new
    -- revision is meant to be a new comment. But it doesn't.
    node.content = ''
    return wiki.actions.edit(node, request, sputnik)
end

--- after editing and saving a new comment, we get redirected back to the snippet page
function actions.save_comment (node, request, sputnik)
    local res = wiki.actions.save(node, request, sputnik)
    if res then return res  -- it might return a page if request.try_again
    else -- was a redirect. We want to redirect to the containing snippet page.
        local id = node.id:gsub('discussion/','snippets/')
        request.redirect = sputnik:make_url(id,'show',nil,'endc')
    end
end

local comments_tmpl = [=[
<p><b>$nc comments</b></p>
$do_comments[[
   <b>$author</b> on $date
   $markup{$text}
]]
<p><a name="endc"/><a href="/?p=$cid.edit">Add a Comment</a></p>
]=]

local function create_comment_section (node,sputnik)
    local _,part_id = node:get_parent_id()
    local comment_id = 'discussion/'..part_id
    local commentary = recipes.node_history(sputnik,comment_id)
    return cosmo.f(comments_tmpl) {
        nc = #commentary,
        id = node.id,
        cid = comment_id,
        do_comments = function()
            -- prefer to get comments in order of creation
            for i = #commentary,1,-1 do
                local  version = commentary[i]
                cosmo.yield {
                    author = version.editor,
                    date = version.timestamp,
                    text = version.content,
                    markup = function(params)
                        return node.markup.transform(params[1], node)
                    end,
                }
            end
        end
    }
end

------- end of comments -----

function actions.preview_snippet (node, request, sputnik)
    -- we are previewing a node, may be unsaved; use the form fields in preference to node fields
    local old_author = not empty(node.author) and node.author
    for k,v in pairs(request.params) do
        node[k] = v
    end
    node.creation_time = tostring(os.time())
    node.author = old_author or request.user or "Anonymous user"
    -- using the error field to indicate previewing feels like a hack ...
    node.error = "Preview"
    if not node.description then node.description = "" end
    local info = {author = node.author, version = '00000'}

    return actions.display_snippet(node, request, sputnik, info)
end

function actions.show_snippet (node,request,sputnik)
    -- we didn't find this snippet in storage
  if node.is_a_stub then
        -- might be a short form URL like snippets/45, so see if we have a snippet with this UID
    local maybe_uid = node.id:match("snippets/(%d+)")
    local id
    if maybe_uid then
      id = recipes.get_snippet_from_uid(maybe_uid,sputnik,snippets)
    end
    if id then
      request.redirect = sputnik:make_url(id, request.action, request.params)
      return
    else
      node.inner_html = "<h2>Unknown Snippet</h2>"
      return node.wrappers.default(node, request, sputnik)
    end
  end

  local info = sputnik.saci:get_node_info(node.id)
  return actions.display_snippet(node, request, sputnik, info)
end

local required_tmpl = [=[
<p><b>Required</b></p>
<ul>
$do_required[[
    <li><a href="/?p=$id">$name</a></li>
]]
</ul>
]=]


local function create_required_list (node, snippets)
    local needs,required = recipes.get_list(node.needs),recipes.get_list(node.requires)

    if #needs > 0 or #required > 0 then
        -- make a list of the snippets that provided a function
        local req = {}
        for _,id in ipairs(needs) do
            local snip = snippets[id]
            append(req,{id,snip.title})
        end
        -- make a list of those that provided a module;
        -- external modules are made into module references.
        for _,id in ipairs(required) do
            local name
            if not id:find 'snippets/' then
                name = id
                id = 'modules/'..id
            else
                name = snippets[id].title
            end
            append(req,{id,name})
        end
        return cosmo.f(required_tmpl) {
            do_required = function()
                for _,r in ipairs(req) do
                    cosmo.yield{id = r[1], name = r[2]}
                end
            end
        }
    else
        return ''
    end
end

local tests_tmpl = [=[
<p><b>Tests/Usage</b></p>
<pre>$test</pre>
]=]

local function create_tests_section (node, sputnik)
    if not empty(node.tests) then
        return cosmo.f(tests_tmpl) {
            test = sputnik:escape(node.tests)
        }
    else
        return ''
    end
end

local tmpl = [=[
$error
<p>$navigate</p>
<p>$description</p>
<p><b>Author:</b> <a href="/?p=authors/$author">$author</a></p>
<p><b>License:</b> $licence
<b>Tags:</b>
$do_tags[[
    <a href="/?p=tags/$tag">$tag</a>
]]
</p>
<h3>Snippet</h3>
<pre>$code</pre>
$tests
$required
<p><b>Related Snippets</b></p>
<ul>
$do_related[[
    <li><a href="/?p=$id">$name </a> ($score) </li>
]]
</ul>
<hr>
<div>Revision $revision by $editor; created $date</div>
$comments
]=]

function actions.display_snippet(node, request, sputnik, info)
    local snippets = recipes.get_snippets(sputnik)
    local uids = recipes.get_snippets_in_order(sputnik,snippets)
    local tags = recipes.extract_tags(node)
    local uid = recipes.get_uid(node.id)
    local idx  = recipes.index_of(uids,uid,'uid')
    local related = recipes.relevant_snippets(node,sputnik,snippets)
    local reqstr = create_required_list(node,snippets)
    local teststr = create_tests_section(node, sputnik)
    local commentstr = create_comment_section(node,sputnik)

    local function ref_by_uid (delta,text)
        if idx == nil then return "" end
        local nidx = idx + delta
        if nidx <= #uids and nidx > 1 then
            return (('<a href="/?p=%s">%s</a>'):format(uids[nidx].id,text))
        else
            return ""
        end
    end

    node.inner_html = cosmo.f(tmpl){
        title = node.title,
        navigate = ref_by_uid(-1,'Previous')..' '..ref_by_uid(1,'Next'),
        this = node.id,
        required = reqstr,
        comments = commentstr,
        error = not empty(node.error) and ('<h2 style="color:red">%s</h2> '):format(node.error) or '',
        description = node.markup.transform(node.description),
        code = util.escape(node.content),
        author = node.author,
        licence = node.licence ,
        revision = info.version,
        editor = not empty(info.author) and info.author or node.author,
        date = sputnik:format_time_RFC822(node.creation_time),
        tests = teststr,
        do_tags = function()
            for i = 1,#tags do cosmo.yield {tag = tags[i]} end
        end,
        do_related = function()
            for _,r in ipairs(related) do
                cosmo.yield {id = r.snippet.id, name = r.snippet.title, score = r.score}
            end
        end
    }
    return node.wrappers.default(node, request, sputnik)
end

function actions.remove(node, request, sputnik)
    recipes.remove_snippet(sputnik,node)
    request.redirect = sputnik:make_url 'snippets'
    return
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
