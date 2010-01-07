module(..., package.seeall)

NODE = {}
NODE.title = "@Tag prototype for tags"
NODE.actions = [[
  show = "tags.show_tags"
]]

NODE.translations = "sputnik_translations"
NODE.icon = "icons/lua.png"
NODE.content = ""

NODE.permissions = [[
  allow(Authenticated, edit_and_save)
]]

--[==[
NODE.edit_ui=[[
  reset()
  title = {1.0, "text_field"}
  licence = {1.1,"text_field"}
  tags = {1.2,"text_field"}
  description = {1.3, "textarea", editor_modules = {"resizeable", "markitup"}, rows = 4}
  content = {1.4, "textarea", editor_modules = {"validatelua", "resizeable"}, rows = 15}
]]

NODE.admin_edit_ui = [[
snippet_section  = {1.410, "div_start", id="snippet_section", closed="true"}
  author = {1.412, "text_field"}
  description = {1.413, "textarea", editor_modules = {"resizeable", "markdown"}}
  creation_time = {1.413, "text_field"}
snippet_section_end = {1.418, "div_end"}
]]
--]==]
