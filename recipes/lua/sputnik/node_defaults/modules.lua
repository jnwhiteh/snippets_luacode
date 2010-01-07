module(..., package.seeall)

NODE = {
   title="Modules",
   content = "",
    child_defaults = [[any='prototype = "@Module"']],
   actions=[[ show="tag.list_modules" ]],
    permissions = "deny(all_users, edit_and_save)"
}
