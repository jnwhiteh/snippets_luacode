-- customizing search for LuaSnippets site (see node_defaults/snip_search.lua)
module(..., package.seeall)

actions = {}

local wiki = require"sputnik.actions.wiki"
local util = require"sputnik.util"
local recipes = require"sputnik.recipes"
local lib = require"sputnik.recipes.lib"
local append,Range = table.insert,lib.Range

--------------------- Searching our nodes -----------------------------------
-- modified version of Node:multimatch ---

local function init_obj (obj,field)
   if obj[field] == nil then obj[field] = {} end
   return obj[field]
end

-- this will return true if any of the node's given fields matches any of the patterns.
-- Unlike the original, it searches each field with all patterns.
-- Also, if true, the node gets a field search_results which is a map from any matching
-- fields to arrays of matches, which are {start pos, end pos, pattern}
local function multimatch(node,fields, patterns, match_case)
   local value
   for _, field in ipairs(fields) do
      value = node[field]
      if value and type(value)=="string" then
         --value = " "..value:lower().." "
         if not match_case then
            value = value:lower()
         end
         for __, pattern in ipairs(patterns) do
            local i1,i2 = value:find(pattern)
            if i1 then
              -- keep going, adding matches to the node's search_results
               local res = init_obj(node,'search_results')
               append(init_obj(res,field),Range{i1,i2,pattern})
            end
         end
      end
   end
   return node.search_results ~= nil
end

-- modified versions of Saci:find_nodes and Saci:query_nodes

local function find_nodes(saci, fields, patterns, prefix)
   assert(fields)
   assert(patterns)
   if type(fields) == "string" then fields = {fields} end
   if type(patterns) == "string" then patterns = {patterns} end
   local nodes = {}
   -- find nodes matching the patterns
   local basic_match, matched, node, value

   local function basic_match(vnode) -- check if the pattern matches raw node
      for _, pattern in ipairs(patterns) do
         if vnode:lower():match(pattern) then return true end
      end
      return false
   end

   for id, vnode in pairs(saci:get_versium_nodes_by_prefix(prefix)) do
      if basic_match(vnode) then -- ok, the pattern is somewhere there, let's look
         node = saci:make_node(vnode, id)
         if multimatch(node,fields, patterns) then
            append(nodes, node)
         end
      end
   end

   return nodes
end

-- fix; note that instead of %Wdog%W (which fails on string boundaries) we use the frontier pattern

local function query_nodes(saci, fields, query, prefix)
   query = " "..query.." "
   fields = fields or {"content"}
   local positive_terms = {}
   local negative_terms = {}
   for term in query:gmatch("%S+") do
      if term:match("%:") then
         local key, value = term:match("^(%w+):(.+)")
         if key == "prefix" then
            prefix=value
         end
      elseif term:sub(1,1)=="-" then
         append(negative_terms, "%f[%w]"..term:sub(2).."%f[%W]")
      else
         append(positive_terms, "%f[%w]"..term.."%f[%W]")
      end
   end

   local nodes = find_nodes(saci, fields, positive_terms, prefix)
   local nodes_without_negatives = {}
   for i, node in ipairs(nodes) do
      if not node:multimatch(fields, negative_terms) then
         append(nodes_without_negatives, node)
      end
   end
   return nodes_without_negatives
end
----------------------------------------------------------------

------- building search context -------
-- the idea is quote the immediate context of the match, while handling the case where the matches
-- are within each other's context; any separate contexts are then separated by '...' and the matching
-- text is suitably bolded.
function construct_search_context_string (text,ranges,delim,ndelim)
   -- construct a list of extended ranges
   -- each context starts with an assoc match (the original match range)
   -- which is shifted to be relative to the context start
   -- e.g. 1 2 3 4 { 5 6 |7| 8 9 } 10
   local res = {}
   for i,r in ipairs(ranges) do
      local cntxt = lib.extract_context(text,r,delim,ndelim)
      cntxt.match = {r:shift(-cntxt[1]+1)}
      res[i] = cntxt
   end

   -- merge overlapping ranges
   -- the tricky bit is combining the match of the second range with the match(es) of the first.
   -- This involves shifting the second match so that it is relative to the first range.
   -- e.g. [1 2 |3| 4 { 5 ] 6 |7| 8 9 } 10
   ranges = lib.partial_reduce(res,function(r1,r2)
           if r1:overlaps(r2) then
               local w = r1:width()
               local res = Range{r1[1],r2[2]; match = r1.match} -- union of the two ranges
               append(res.match,r2.match[1]:shift(w-1-(r1[2]-r2[1])))
               return true,res
           end
       end)
   -- construct the annotated string of all the contexts
   res = {}
   for i,r in ipairs(ranges) do
      local str = text:sub(r:upper_lower())
      if delim ~= '\n' then str = str:gsub('[\r\n]',' ') end
      res[i] = lib.annotate(str,r.match,'<b>','</b>')
   end
   local tag
   if delim == '\n' then tag = 'pre' else tag = 'p' end
   return ('<%s>%s</%s>'):format(tag,table.concat(res,'...'..delim),tag)
end

local TEMPLATE = [[
$do_nodes[=[
  <p><b>$type</b> <a title="$title" href="$url">$title</a> - $time by $author</p>
  $context
  <hr/>
]=]
]]

----- Result order -----
-- First, we create a map from keywords (the search patterns) to their occurance.
-- Second, we find the maximum number of hits and the total number of keywords hit;
-- the score is weighted towards the number of keywords, then the number of keyword matches.
local function count_keywords (node)
   local max,update_count_map = math.max,recipes.update_count_map
   local res = node.search_results
   if not res then return 0 end -- shdn't really get here
   local keywords = {}
   for field,matches in pairs(res) do
      for _,m in ipairs(matches) do
         update_count_map(keywords,m[3])
      end
   end
   local maxk,nkeyword = 0,0
   for keyword,count in pairs(keywords) do
      maxk = max(maxk,count)
      nkeyword = nkeyword + 1
   end
   return maxk + 10*(nkeyword - 1)
end

local search_fields = {"title", "content", "tags", "description"}

actions.show_results = function(node, request, sputnik)
   local search_str = request.params.q or ""
   local nodes
   nodes = query_nodes(sputnik.saci,search_fields,search_str)
   node.title = 'Pages matching "'..search_str..'"'

   --- sort the nodes according to their score
   for i, node in ipairs(nodes) do
      node.score = count_keywords(node)
   end
   table.sort(nodes,function(a,b) return a.score > b.score end)

   node.inner_html = util.f(TEMPLATE){
      do_nodes = function()
         for i, node in ipairs(nodes) do
            local metadata = sputnik.saci:get_node_info(node.id)
            local parent = node:get_parent_id()
            local type,was_snippet = 'info', false
            if parent then
               type = parent:gsub('s$','')  -- i.e. snippet,tag,author, module, etc
               -- special case: snippets have a useful UID
               if type == 'snippet' then
                  type = type..' #'..recipes.get_uid(node.id)
                  was_snippet = true
               end
            end
            local context = {
               add = function(self,caption,text,ranges,delim,ndelim)
                  if text ~= nil then  -- this does happen - but why?
                     append(self,'<b>'..caption..'</b>: '..construct_search_context_string(text,ranges,delim,ndelim))
                  end
               end
            }
            local search_res = assert(node.search_results)
            -- magic number alert: 3 is the context width (in lines) for code matches, 6 is the width (in 'words') for text matches.
            local ncode,ntext = 3,6
            local matches = search_res.description
            if matches then context:add('description',node.description,matches,'%s',ntext) end
            matches = search_res.content
            if matches then  -- snippet code is in the 'content' field, which is usually wiki text.
               if was_snippet then context:add('code',node.content,matches,'\n',ncode)
               else  context:add('text',node.content,matches,'%s',ntext)
               end
            end
            matches = search_res.tags
            if matches then context:add('tags',node.tags,matches,'%s',ntext) end
            cosmo.yield {
               type = type,
               author = node.author or 'unknown',
               title = node.title,
               url = sputnik.config.NICE_URL..node.id,
               time = sputnik:format_time(metadata.timestamp, "%Y/%m/%d"),
               context = table.concat(context,'<br>\n')
            }
         end
     end
  }
   return node.wrappers.default(node, request, sputnik)
end
