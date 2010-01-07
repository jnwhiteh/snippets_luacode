module(..., package.seeall)

local recipes = require("sputnik.recipes")
local parser = require("sputnik.recipes.parser")
local append = table.insert

function save_snippet(node, request, sputnik)
   request = request or {}
   local params = {}
   local new_id = node.id
   local snippets = recipes.get_snippets(sputnik)
   local err_msg

   local function check_existing_snippets (field,value,msg)
       for id,snippet in pairs(snippets) do
            if id ~= new_id and snippet[field] == value then
                return false
            end
       end
       return true
   end

   -- If the node is being saved, set initial params
   if not node.creation_time then
       params.author = request.user or "Anonymous user"
       params.creation_time = tostring(os.time())
   end
   -- temporary (shd be on creation only)
   if not node.uid then
        params.uid = recipes.get_uid(new_id)
   end

   -- be strict about this!  (Not filling in tags is not a terminal offence)
   if not check_existing_snippets('title',request.params.title) then
        err_msg = "Title already used"
   end

   if #node.content > 0 then
       local scan = parser.scan_lua_code(node.content)

       ---------------------- Exports ---------------------------------------------
       -- a snippet can either export a module, a single function or just be an example
       -- We do insist on any exported names being unique
       if #scan.export_mod > 0 then
            params.mod = scan.export_mod[1]
            if not check_existing_snippets('mod',params.mod) then
                err_msg = ("Module %s already used"):format(params.mod)
            end
       elseif #scan.export_fun > 0 then
            params.fun = scan.export_fun[1]
            if not check_existing_snippets('fun',params.fun) then
                err_msg = ("Function '%s' already used"):format(params.fun)
            end
        end
        -----------------------------------------------------------------------------

        --------------------- External Dependencies ---------------
        --- this snippet may have external dependencies:
        --- (1) functions, which must be exported by other snippets
        --- (2) modules which are provided by other snippets
        --- (3) modules which are not (assumed _external_)
        local foreign,requires = scan.foreign_map,scan.require_map
        local imports,required = {},{}

        for id,snippet in pairs(snippets) do
            if foreign[snippet.fun] then
                append(imports,id)
                foreign[snippet.fun] = nil
            end
            if requires[snippet.mod] then
                append(required,id)
                requires[snippet.mod] = nil
            end
        end

        -- this is a list of snippets needed implicitly by our new snippet to provide foreign functions
        if #imports > 0 then params.needs = recipes.list(imports) end

        -- and this lists snippets _or_ foreign modules required (explicitly via require())
        if #scan.requires > 0 then
            local res = {}
            -- the snippet modules we found
            for _,id in ipairs(required) do
                append(res,id)
            end
            -- and any unidentified modules (presumed external)
            for k in pairs(requires) do
                append(res,k)
            end
            params.requires = recipes.list(res)
        end

    end

    ---------------------------------------------------------------------------------


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

  if err_msg then
     params.error = err_msg..'; please edit'
  elseif node.error then
    params.error = ""
  end

   node = sputnik:update_node_with_params(node, params)
   return node
end

