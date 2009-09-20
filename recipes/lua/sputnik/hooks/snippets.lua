module(..., package.seeall)

function save_snippet(node, request, sputnik)
   request = request or {}
   local params = {}

   -- If the node is being saved, set initial params
   if not node.creation_time then
       params.author = request.user or "Anonymous user"
       params.creation_time = tostring(os.time())
   end

   local title = request.params.title or node.title
   if #node.title > 25 then
      params.breadcrumb = title:sub(1, 25) .. "..."
   else
      params.breadcrumb = title
   end

   -- Generate a snippet for the content by stripping markup and trimming
   local short_desc = node.description:gsub("%b<>", ""):gsub("%b[]", "")
   if #short_desc > 250 then
      params.short_desc = short_desc:sub(1, 250) .. "..."
   else
      params.short_desc = short_desc
   end

   node = sputnik:update_node_with_params(node, params)
   return node
end

