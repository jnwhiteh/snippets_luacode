module(..., package.seeall)

NODE = {
fields = [[
-- Think twice before editing this ------------------------
fields          = {0.0, proto="concat", activate="lua"}
title           = {0.1  }
category        = {0.2  }
actions         = {0.3, proto="concat", activate="lua"}
action_hooks    = {0.31, proto="concat", activate="lua"}
config          = {0.4, proto="concat", activate="lua"}
markup_module   = {0.41, proto="fallback"}
templates       = {0.5, proto="concat", activate="list"}
translations    = {0.51, proto="concat", activate="list"}
prototype       = {0.6  }
permissions     = {0.7,   proto="concat"}
html_main       = {0.701, proto="fallback"}
html_head       = {0.702, proto="fallback"}
html_menu       = {0.703, proto="fallback"}
html_logo       = {0.704, proto="fallback"}
html_page       = {0.706, proto="fallback"}
html_content    = {0.7061, proto="fallback"}
html_body       = {0.707, proto="fallback"}
html_header     = {0.708, proto="fallback"}
html_footer     = {0.708, proto="fallback"}
html_sidebar    = {0.709, proto="fallback"}
html_meta_keywords = {0.70901, proto="fallback"}
html_meta_description = {0.70902, proto="fallback"}
redirect_destination =  {0.70903}
xssfilter_allowed_tags = {0.7091, proto="concat", activate="lua"}
http_cache_control = {0.710, proto="fallback"}
http_expires    = {0.711, proto="fallback"}
content         = {0.81  }
edit_ui         = {0.9, proto="concat"}
admin_edit_ui   = {0.91, proto="concat"}
child_defaults  = {0.92, proto="concat", activate="lua"}
icon            = {0.93, proto="fallback"}
breadcrumb      = {0.94 }
save_hook       = {0.95, proto="fallback"}
raw_content_type = {0.96 }
template_helpers = {0.97, activate="lua", proto="concat"}
-- "virtual" fields (never saved) ------------------------
version         = {virtual=true}
prev_version    = {virtual=true}
raw             = {virtual=true}
history         = {virtual=true}
name            = {virtual=true}
]],
title="@Root (Root Prototype)",
category="Prototypes",
actions=[[
show            = "wiki.show"
show_content    = "wiki.show_content"
history         = "wiki.history"
edit            = "wiki.edit"
configure       = "wiki.configure"
post            = "wiki.post"
rss             = "wiki.rss"
diff            = "wiki.diff"
code            = "wiki.code"
raw             = "wiki.raw"
raw_content     = "wiki.raw_content"
login           = "wiki.show_login_form"
sputnik_version = "wiki.sputnik_version"
save            = "wiki.save"
preview         = "wiki.preview"
preview_content = "wiki.preview_content"
cancel          = "wiki.cancel"
reload          = "wiki.reload"
]],
markup_module = "markdown",
templates     = "sputnik/templates",
translations  = "sputnik/translations",
config        = [[
   
]],
edit_ui = [[
-------------------------- basic fields ----------------
content_section  = {1.0, "div_start", id="content_section", open="true"}
 content         = {1.3, "textarea", rows=15, no_label=true}
 content.editor_modules = {
                      "resizeable",
                      "markitup",
 }
content_section_end = {1.4, "div_end"}

-------------------------- advanced fields -------------
advanced_section = {2.0, "div_start", id="advanced"}
 page_name       = {2.21, "readonly_text"}
 title           = {2.22, "text_field"}
 breadcrumb      = {2.23, "text_field"}
 category        = {2.24, "select", options = {}}
 prototype       = {2.25, "hidden", no_label=true, div_class="hidden"}
advanced_section_end = {2.3, "div_end"}

--- info about the edit --------------------------------
edit_info_section  = {3.00, "div_start", id="edit_info_section", open="true"} 
 summary         = {3.2, "textarea", no_label=true, rows=2, editor_modules = {"resizeable"}}
edit_info_section_end = {3.3, "div_end"}
]],
admin_edit_ui = [[
-------------------------- basic fields ----------------
--page_params_hdr = {1.0, "header"}
content_section  = {1.00, "div_start", id="content_section", open="true"}
 page_name       = {1.1, "readonly_text"}
 title           = {1.2, "text_field"}
 breadcrumb      = {1.3, "text_field"}
 content         = {1.4, "textarea", editor_modules = {"resizeable"}, rows=15, no_label=true}
content_section_end = {1.5, "div_end"}

-------------------------- advanced fields -------------
advanced_section = {2.0, "div_start", id="advanced_section"}
 category        = {2.01, "select", options = {"Foo", "Bar"}}
 prototype       = {2.02, "text_field"}
 redirect_destination = {2.022, "text_field"}
 permissions     = {2.03, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
 actions         = {2.04, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
 config          = {2.05, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
 markup_module   = {2.0501, "text_field"}
 html_meta_keywords = {2.051, "text_field"}
 html_meta_description = {2.052, "text_field"}
 save_hook       = {2.053, "text_field"}
advanced_section_end = {2.06, "div_end"}

html_section     = {2.100, "div_start", id="html_section", state="open"}
 html_main       = {2.101, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_head       = {2.102, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_body       = {2.103, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_header     = {2.104, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_menu       = {2.105, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_logo       = {2.106, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_page       = {2.108, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_content    = {2.108, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_sidebar    = {2.109, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_footer     = {2.110, "textarea", rows=3, editor_modules = {"resizeable"}}
 xssfilter_allowed_tags = {2.111, "textarea", rows=3, editor_modules = {"resizeable"}}
html_section_end = {2.112, "div_end"}

http_section     = {2.201, "div_start", id="http_section", state="open"}
 http_cache_control = {2.202, "textarea", rows=3, editor_modules = {"resizeable"}}
 http_expires    = {2.203, "textarea", rows=3, editor_modules = {"resizeable"}}
http_section_end = {2.209, "div_end"}

guru_section     = {2.30, "div_start", id="guru_section"}
 templates       = {2.31, "text_field"}
 translations    = {2.32, "text_field"}
 fields          = {2.33, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
 edit_ui         = {2.34, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
 admin_edit_ui   = {2.35, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
guru_section_end = {2.36, "div_end"}

--- info about the edit --------------------------------
edit_info_section  = {3.00, "div_start", id="edit_info_section", open="true"} 
 summary         = {3.2, "textarea", rows=3, editor_modules = {"resizeable"}}
edit_info_section_end = {3.3, "div_end"}
]],
content=[===[

This is the root proto-page.  The content of this form is ignored, but
it's fields are inherited by all other pages.  E.g., if you were to set

    actions = [[show_content = "wiki.show_content_as_lua_code"]]

on this page, _all_ pages would default to displaying their content as
if it was Lua code.  (Note that any page that sets `show_content` to
its own value, and any pages that inherit from it, will continue to
work as they did before.)  I.e., this page only affects the default
values.  Handle with care.

]===],
permissions=[[
   deny(all_users, all_actions)
   allow(all_users, show)  -- show, show_content, cancel
   allow(all_users, edit_and_save) -- edit, save, preview
   allow(all_users, "post")  --needed for login
   allow(all_users, "login")
   allow(all_users, history_and_diff)
   allow(all_users, "rss")
   allow(all_users, "xml")
   --deny(Anonymous, edit_and_save)
   allow(Admin, "reload")
   allow(Admin, "configure")
]]
}

NODE.html_main      = [==[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
$head
 </head>
 <body>
$body

  <script type="text/javascript" src="$js_base_url{}sputnik/scripts.js"></script>
   $do_javascript_links[[<script type="text/javascript" src="$href"></script>
  ]]
  $do_javascript_snippets[=[
   <script type="text/javascript">/* <![CDATA[ */ $snippet /* ]]> */</script>
  ]=] </body>
</html>
]==]

NODE.html_head      = [=[  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  <meta name="keywords" content="$html_meta_keywords"/>
  <meta name="description" content="$html_meta_description"/>
  <title>$site_title: $title</title>
  <link type="text/css" rel="stylesheet" href="$css_base_url{}sputnik/style.css" media="all"/>
  $do_css_links[[<link type="text/css" rel="stylesheet" href="$href" media="$media"/>
]]$do_css_snippets[[
   <style type="text/css" media="$media">$snippet</style>
]]<link rel="shortcut icon" href="$favicon_url"/>
  <link rel="alternate" type="application/rss+xml" title="_(RECENT_EDITS_TO_SITE)" $site_rss_link/>
  <link rel="alternate" type="application/rss+xml" title="_(RECENT_EDITS_TO_NODE)" $node_rss_link/>
  $if_no_index[[<meta name="ROBOTS" content="NOINDEX, NOFOLLOW"/>]]

  <script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-20679350-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
]=]

NODE.html_menu      = [==[<ul class="level1">$do_nav_sections[=[
     <li class='$class level1' id='menu_item_$id'>
      <a title="$accessibility_title" $link>$title</a>
      <ul class='$class level2'>$subsections[[<li class='$class level2'><a title="$accessibility_title" $link>$title</a></li>]]
       <li style="display:none">&nbsp;</li>
      </ul>
     </li>]=]
    </ul>
]==]

NODE.html_logo      = [[<a class="home_page" href="$home_page_url" title="Home page">
      <p class="site_title">$site_title</p>
      <p class="site_subtitle">$site_subtitle</p>
     </a>]]

NODE.html_page      = [=[<div id="breadcrumbs">
     <ul>
      $do_breadcrumb[[<li class="first"><a $link>$title</a></li>]],[[
      <li class="follow"><a $link>▹&nbsp; $title</a></li>]]
     </ul>
    </div>
    <div id="toolbar">
     $do_toolbar[[$if_icon[====[<a $link title="$title"><img src="$icon_base_url{}$icon" alt="_(BUTTON)"/></a>]====]
      $if_text[====[<a $link>$title</a>]====]
     ]]
    </div>
    <div id="page_title">$if_title_icon[[
     <img src="$title_icon" class="title_icon" alt="type icon ($title_icon)"/>]]
     <a name="title" title="_(CURRENT_PAGE)" $show_link >$title</a> $if_old_version[[<span class="from_version">($version)</span>]]
    </div>
    <div id="content" class="content">
     $do_messages[[<p class="$class">$message</p>]]

<!-- start page content -->$content<!-- end page content -->

    </div>
]=]

NODE.html_content   = [[Not used by default.
]]

NODE.html_body      = [[  <div id="container">
   <div id="header">
    $header
   </div>
   <div id="page">
    $page
   </div>
   <div id="sidebar">
    $sidebar
   </div>
   <div id="menu">
    $menu
   </div>
   <div id="footer">
     $footer
   </div>
  </div>
]]


NODE.html_header    = [=[<div id="logo">
     $logo
    </div>
]=]

NODE.html_sidebar = [==[
    <div id="login">
     <img align="left" style="margin-right: 6px" src="http://www.gravatar.com/avatar/0ee56f66d982976640e2a92a906c67cb.png?s=32" alt="Bertrand Mansion" />
     $if_logged_in[[<p style="font-weight:bold;margin:0">$user</p>
                    <a href="">Edit profile</a> | <a class="logout" title="_(LOGOUT)" $logout_link>_(LOGOUT)</a>]]
     $if_not_logged_in[[<a class="login_link" $login_link>_(LOGIN)</a> _(OR) <a $register_link>_(REGISTER)</a>]]
    </div>
    <div id="search">
     <form action="$base_url" class="search">
      <input class="hidden" type="hidden" name="p" value="snip_search"/>
      <input class="search_box" type="text" name="q" size="16"
             title="_(TOOLTIP_FOR_SEARCH_BOX)" value="$search_box_content"/>
      <input class="search_button" type="image" src="http://losr.org/img/search.png" alt="_(BUTTON)"/>
     </form>
    </div>

    <div>
    <h1><a href="" style="color:#000;">Software development</a></h5>
          <ul>
            <li><a href="">Build tools</a>       <span class="count" style="font-size:10px;color:#666">12</span></li>

            <li><a href="">Code generators</a>   <span class="count" style="font-size:10px;color:#666">24</span></li>
            <li><a href="">Compilers</a>         <span class="count" style="font-size:10px;color:#666">54</span></li>
            <li><a href="">Debuggers</a>         <span class="count" style="font-size:10px;color:#666">32</span></li>
            <li><a href="">Interpreters</a>      <span class="count" style="font-size:10px;color:#666">98</span></li>

            <li><a href="">Object brokering</a>  <span class="count" style="font-size:10px;color:#666">102</span></li>
            <li><a href="">Parsers</a>           <span class="count" style="font-size:10px;color:#666">30</span></li>
            <li><a href="">Profilers</a>         <span class="count" style="font-size:10px;color:#666">8</span></li>
            <li class="active" style="font-weight:bold">Testing tools         <span class="count" style="font-size:10px;color:#666">123</span></li>

            <li><a href="">Version control</a>   <span class="count" style="font-size:10px;color:#666">2</span></li>
          </ul>
        </div>




<script type="text/javascript" src="http://losr.org/js/twitter.min.js"></script>
  <script type="text/javascript">
    getTwitters('luanewsTweets', {
        id: 'luanews', 
        count: 3, 
        withFriends: false,
        enableLinks: true, 
        ignoreReplies: true,
        template: '<span class="twitterTime"><a href="http://twitter.com/%user_screen_name%/statuses/%id%">%time%</a></span> <span class="twitterStatus">%text%</span>'
    });
  </script>

          <h1><a href="http://twitter.com/luanews" style="color:#000;">@luanews</a><img src="http://losr.org/img/twittie.png" style="vertical-align:top" alt="twitter" /></h1>
          <div id="luanewsTweets"></div>
]==]

NODE.html_footer = [===[
<p>_(POWERED_BY_SPUTNIK) | <a class="etc" href="href="http://validator.w3.org/check?uri=referer">XHTML 1.1</a></p>
]===]

NODE.html_meta_keywords = " "
NODE.html_meta_description = " "

NODE.child_defaults = [[

--talk = [==[
--title = "Discussion of $id"
--prototype ="@Discussion"
--]==]

]]


