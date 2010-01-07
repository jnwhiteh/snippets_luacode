module(..., package.seeall)

NODE = {}
NODE.title = "@Author prototype for authors"
NODE.actions = [[
  show = "tag.list_author_snippets"
]]

NODE.translations = "sputnik_translations"
NODE.icon = "icons/lua.png"
NODE.content = ""

NODE.permissions = [[
  deny(all_users,"edit")
  allow(function(user,node)
    if not user then return false end
    if user == 'Admin' or user == node.id:match('authors/(.+)'):gsub('_',' ') then
        return true
    end
  end, "edit")
   deny(all_users,"remove")
]]


