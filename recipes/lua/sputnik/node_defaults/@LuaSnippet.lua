module(..., package.seeall)

NODE = {}
NODE.title = "@LuaSnippet prototype for Lua snippets"
NODE.actions = [[
  show = "snippets.show_snippet"
]]
NODE.save_hook = "snippets.save_snippet"

NODE.translations = "sputnik_translations"
NODE.icon = "icons/lua.png"
NODE.content = ""

NODE.fields = [[
  author = {1.3}
  description = {1.4}
  creation_time = {1.5}
  short_desc = {1.6}
]]

NODE.permissions = [[
  allow(Authenticated, edit_and_save)
]]

NODE.edit_ui=[[
  reset()
  title = {1.0, "text_field"}
  description = {1.1, "textarea", editor_modules = {"resizeable", "markitup"}, rows = 8}
  content = {1.2, "textarea", editor_modules = {"validatelua", "resizeable"}, rows = 15}
]]

NODE.admin_edit_ui = [[
snippet_section  = {1.410, "div_start", id="snippet_section", closed="true"}
  author = {1.412, "text_field"}
  description = {1.413, "textarea", editor_modules = {"resizeable", "markdown"}}
  creation_time = {1.413, "text_field"}
snippet_section_end = {1.418, "div_end"}
]]
