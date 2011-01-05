require('sputnik.wsapi_app')
require 'syntaxhighlighter'
return sputnik.wsapi_app.new{
   VERSIUM_PARAMS = { '/home/steve/lua/snippets_luacode/sandbox/wiki-data/' },
   BASE_URL       = '/',
   PASSWORD_SALT  = 'R642OT5P5e8E8v7Ff4zHLVbgdsmL8z6Pw1IaKEQG',
   TOKEN_SALT     = 'IOaG97cf2CNDoOKr6W25mZLJQjKrOrYm5YT5WWbP',
   MORE_JAVASCRIPT = syntaxhighlighter.get_javascript{"Lua"},
   MORE_CSS = syntaxhighlighter.get_css(),
}
