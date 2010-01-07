module(..., package.seeall)

NODE = {
   title="Discussions",
   content = "",
   child_defaults = [[any='prototype = "@SnipDiscussion"']],
   --actions=[[ show="tag.list_authors" ]],
   permissions = "deny(all_users, edit_and_save)"
}
