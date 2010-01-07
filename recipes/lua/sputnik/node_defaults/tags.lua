module(..., package.seeall)

NODE = {
   title="Tags",
   content = "",
    child_defaults = [[any='prototype = "@Tag"']],
   actions=[[ show="tag.list_tags" ]],
    permissions = "deny(all_users, edit_and_save)"
}
