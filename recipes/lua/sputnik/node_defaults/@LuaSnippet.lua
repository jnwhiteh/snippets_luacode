module(..., package.seeall)

NODE = {}
NODE.title = "@LuaSnippet prototype for Lua snippets"
NODE.actions = [[
  show = "snippets.show_snippet"
  preview = "snippets.preview_snippet"
  remove = "snippets.remove"
]]

-- save = "snippets.save_snippet"
NODE.save_hook = "snippets.save_snippet"

NODE.translations = "sputnik_translations"
NODE.icon = "icons/lua.png"
NODE.content = ""

NODE.fields = [[
  author = {1.3}
  description = {1.4}
  creation_time = {1.5}
  short_desc = {1.6}
  licence = {1.7}
  tags = {1.8}
  fun = {1.9}
  mod = {2.0}
  requires = {2.1}
  needs = {2.2}
  uid = {2.3}
  error = {2.4}
  tests = {2,5}
]]

NODE.permissions = [[
  deny(function(user,node)
    return node.title == ''
  end,show)
  allow(Authenticated, edit_and_save)
  allow(function(user,node)
    if not user then return false end
    if user == 'Admin' or user == node.author then
        return true
    end
  end,"remove")
]]

NODE.edit_ui=[[
  reset()
  title = {1.0, "text_field"}
  licence = {1.1,"text_field"}
  tags = {1.2,"text_field"}
  description = {1.3, "textarea", editor_modules = {"resizeable", "markitup"}, rows = 4}
  content = {1.4, "textarea", editor_modules = {"validatelua", "resizeable"}, rows = 15}
  tests = {1.5,"textarea", editor_modules = {"validatelua", "resizeable"}, rows = 15}
]]

NODE.admin_edit_ui = [[
snippet_section  = {1.410, "div_start", id="snippet_section", closed="true"}
  author = {1.412, "text_field"}
  description = {1.413, "textarea", editor_modules = {"resizeable", "markdown"}}
  creation_time = {1.414, "text_field"}
  fun = {1.415,"text_field"}
  mod = {1.415,"text_field"}
  requires = {1.415,"text_field"}
  needs = {1.416,"text_field"}
snippet_section_end = {1.418, "div_end"}
]]
