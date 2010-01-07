module(..., package.seeall)
local recipes = require("sputnik.recipes")
NODE = {}
NODE.content = ""
NODE.prototype = "@Collection"
NODE.title = "Lua Snippets"
NODE.breadcrumb = "Lua Snippets"
NODE.translations = "sputnik_translations"
NODE.permissions = "deny(Authenticated, edit_and_save)"

NODE.child_proto = "@LuaSnippet"
NODE.child_uid_format = "$slug_%d"
NODE.sort_params = [[
  sort_key = "creation_time"
  sort_desc = true
  sort_type = "number"
]]

NODE.actions = [[
  rss = "snippets.rss"
]]

NODE.child_defaults = [=[
new = [[
prototype = "@LuaSnippet"
title     = "title"
licence = "MIT/X11"
tags = ""
actions   = 'save="collections.save_new"'
]]
]=]

NODE.template_helpers = {
    uid = function(id)
        return recipes.get_uid(id)
    end
}

-- (SJD) this conditional macro which is user-aware is borked on Kaio, but works fine on CVS version
---$has_node_permissions{$new_id, "edit"}[[<p><a href="$new_url">_(ADD_NEW_LUA_SNIPPET)</a></p>]],[[<p><a href="$make_url{"sputnik/login", next = $id}">_(LOGIN)</a> to create a snippet</p>]]

NODE.html_content = [=[
$markup{$content}

<h2><a href="$new_url">_(ADD_NEW_LUA_SNIPPET)</a></h2>

<table class="sortable" width="100%">
 <thead>
  <tr>
   <th>#</th>
   <th>Title</th>
   <th>Author</th>
   <th>Added</th>
  </tr>
 </thead>
 $do_nodes[[
 <tr>
  <td>$uid{$id}</td>
  <td><a href="$url">$title</a></td>
  <td>$author</td>
  <td>$format_time{$creation_time, "%d %b %Y"}</td>
 </tr>
]]
</table>
]=]
