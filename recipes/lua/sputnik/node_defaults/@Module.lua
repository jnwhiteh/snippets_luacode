module(..., package.seeall)

NODE = {}
NODE.title = "@Module prototype for module"
NODE.actions = [[
  show = "tag.list_module_sniippets"
]]

NODE.translations = "module_translations"
NODE.icon = "icons/lua.png"
NODE.content = ""

NODE.permissions = [[
  deny(all_users, edit_and_save)
  allow(Authenticated, edit_and_save)
  deny(all_users,"remove")
]]

-- the node content field will be the (optional) module description
NODE.fields = [[
    project_name = {1.1}
    project_url = {1.2}
]]

NODE.edit_ui=[[
  reset()
  project_name = {1.0, "text_field"}
  project_url = {1.1,"text_field"}
  content = {1.3, "textarea", editor_modules = {"resizeable", "markitup"}, rows = 10}
]]

