module(..., package.seeall)

NODE = {}
NODE.content = ""
NODE.prototype = "@Collection"
NODE.title = "Code Snippets"
NODE.breadcrumb = "Code Snippets"
NODE.translations = "sputnik_translations"

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
title     = "Enter a title for your snippet here"
actions   = 'save="collections.save_new"'
permissions = "allow(Authenticated, edit_and_save)"
]]
]=]

NODE.html_content = [=[
$markup{$content}

$has_node_permissions{$new_id, "edit"}[[<p><a href="$new_url">_(ADD_NEW_LUA_SNIPPET)</a></p>]],[[<p><a href="$make_url{"sputnik/login", next = $id}">_(LOGIN)</a> to create a snippet</p>]]

<table class="sortable" width="100%">
 <thead>
  <tr>
   <th>Title</th>
   <th>Description</th>
   <th>Added</th>
  </tr>
 </thead>
 $do_nodes[[
 <tr>
  <td><a href="$url">$title</a></td>
  <td>$short_desc</td>
  <td>$format_time{$creation_time, "%a, %d %b %Y %H:%M:%S"} by $author</td>
 </tr>
]]
</table>
]=]
