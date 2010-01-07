module(..., package.seeall)

NODE = {}
NODE.title = "@SnipDiscussion prototype for discussion nodes"
NODE.actions = [[
    edit = "snippets.edit_comment"
    save = "snippets.save_comment"
--~   show = "tag.list_tag_snippets"
]]

NODE.icon = "icons/lua.png"
NODE.content = ""

NODE.permissions = [[
  deny(all_users,edit_and_save)
  allow(Authenticated, edit_and_save)
  deny(all_users,"remove")
]]

NODE.edit_ui=[[
  reset()
  content = {1.3, "textarea", editor_modules = {"resizeable", "markitup"}, rows = 10}
]]
