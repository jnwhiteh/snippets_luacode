module(..., package.seeall)

NODE = {}
NODE.title = "@Tag prototype for tags"
NODE.actions = [[
  show = "tag.list_tag_snippets"
]]

NODE.translations = "sputnik_translations"
NODE.icon = "icons/lua.png"
NODE.content = ""

NODE.permissions = [[
  allow(Authenticated, edit_and_save)
  deny(all_users,"remove")
]]

