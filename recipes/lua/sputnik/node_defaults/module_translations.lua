module(..., package.seeall)
-- note: we can't use sputnik_translations.lua for the module forms,
-- because EDIT_FORM_CONTENT is already defined as snippet code.

NODE = {
   title = "Translations for Module form",
   prototype = "@Lua_Config",
}

NODE.content = [==[
EDIT_FORM_CONTENT = {
    en_US = "Description",
}
EDIT_FORM_PROJECT_NAME = {
    en_US = "Project Name"
}
EDIT_FORM_PROJECT_URL = {
    en_US = "Project URL"
}
]==]
