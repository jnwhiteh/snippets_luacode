module(..., package.seeall)

NODE = {
   title="Authors",
   content = "",
   child_defaults = [[any='prototype = "@Author"']],
   actions=[[ show="tag.list_authors" ]],
   permissions = "deny(all_users, edit_and_save)"
}
