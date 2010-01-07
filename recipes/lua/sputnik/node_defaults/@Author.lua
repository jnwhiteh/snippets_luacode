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
  allow(Author, "edit")
]]

--[[
  allow(fd,
  edit_and_save)
]]

