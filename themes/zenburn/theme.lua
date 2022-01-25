-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
-------------------------------

local themes_path       = os.getenv("HOME") .. "/.config/awesome/themes/"
local themes_lain_path  = os.getenv("HOME") .. "/.config/awesome/lain/"
local dpi = require("beautiful.xresources").apply_dpi

-- {{{ Main
local theme = {}
theme.panel     = "png:" .. themes_path .. "zenburn/panel/panel.png"
theme.wallpaper = themes_path .. "zenburn/wallpapers/pro-medium-dark.png"
-- }}}

-- {{{ Styles
theme.font      = "sans 8"

-- {{{ Colors
theme.fg_normal  = "#DCDCCC"
theme.fg_focus   = "#F0DFAF"
theme.fg_urgent  = "#CC9393"
theme.bg_normal  = "#3F3F3F"
theme.bg_focus   = "#1E2320"
theme.bg_urgent  = "#3F3F3F"
theme.bg_systray = theme.bg_normal
theme.systray_icon_spacing = dpi(3)
-- }}}

-- {{{ Borders
theme.useless_gap   = dpi(0)
theme.border_width  = dpi(2)
theme.border_normal = "#3F3F3F"
theme.border_focus  = "#6F6F6F"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Separators

theme.spr    = themes_path .. "zenburn/panel/separators/spr.png"
theme.sprtr  = themes_path .. "zenburn/panel/separators/sprtr.png"
theme.spr4px = themes_path .. "zenburn/panel/separators/spr4px.png"
theme.spr5px = themes_path .. "zenburn/panel/separators/spr5px.png"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Tasklist |
theme.tasklist_font                 = theme.font
theme.tasklist_disable_icon         = false
theme.tasklist_bg_normal            = "png:" .. themes_path .. "zenburn/panel/tasklist/normal.png"
theme.tasklist_bg_focus             = "png:" .. themes_path .. "zenburn/panel/tasklist/focus.png"
theme.tasklist_bg_urgent            = "png:" .. themes_path .. "zenburn/panel/tasklist/urgent.png"
theme.tasklist_fg_focus             = theme.fg_focus
theme.tasklist_fg_urgent            = theme.fg_urgent
theme.tasklist_fg_normal            = theme.fg_normal
theme.tasklist_floating             = ""
theme.tasklist_sticky               = ""
theme.tasklist_ontop                = ""
theme.tasklist_maximized_horizontal = ""
theme.tasklist_maximized_vertical   = ""
-- }}}

-- {{{ Music
theme.mpd_prev                      = themes_path .. "zenburn/panel/widgets/mpd/mpd_prev.png"
theme.mpd_nex                       = themes_path .. "zenburn/panel/widgets/mpd/mpd_next.png"
theme.mpd_stop                      = themes_path .. "zenburn/panel/widgets/mpd/mpd_stop.png"
theme.mpd_pause                     = themes_path .. "zenburn/panel/widgets/mpd/mpd_pause.png"
theme.mpd_play                      = themes_path .. "zenburn/panel/widgets/mpd/mpd_play.png"
theme.mpd_sepr                      = themes_path .. "zenburn/panel/widgets/mpd/mpd_sepr.png"
theme.mpd_sepl                      = themes_path .. "zenburn/panel/widgets/mpd/mpd_sepl.png"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
theme.widget_battery        = themes_path .. "zenburn/panel/widgets/battery/battery.png"
theme.widget_battery_ac     = themes_path .. "zenburn/panel/widgets/battery/ac.png"
theme.widget_battery_empty  = themes_path .. "zenburn/panel/widgets/battery/battery_empty.png"
theme.widget_battery_low    = themes_path .. "zenburn/panel/widgets/battery/battery_low.png"
theme.widget_cal            = themes_path .. "zenburn/panel/widgets/widget_cal.png"
theme.widget_clock          = themes_path .. "zenburn/panel/widgets/widget_clock.png"
theme.widget_cpu            = themes_path .. "zenburn/panel/widgets/widget_cpu.png"
theme.widget_display        = themes_path .. "zenburn/panel/widgets/display/widget_display.png"
theme.widget_display_center = themes_path .. "zenburn/panel/widgets/display/widget_display_c.png"
theme.widget_display_left   = themes_path .. "zenburn/panel/widgets/display/widget_display_l.png"
theme.widget_display_right  = themes_path .. "zenburn/panel/widgets/display/widget_display_r.png"
theme.widget_mem            = themes_path .. "zenburn/panel/widgets/widget_mem.png"
theme.widget_microphone     = themes_path .. "zenburn/panel/widgets/widget_microphone.png"
theme.widget_netdl          = themes_path .. "zenburn/panel/widgets/widget_netdl.png"
theme.widget_netul          = themes_path .. "zenburn/panel/widgets/widget_netul.png"
theme.widget_ssd            = themes_path .. "zenburn/panel/widgets/widget_fs.png"
theme.widget_volume         = themes_path .. "zenburn/panel/widgets/widget_volume.png"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = themes_path .. "zenburn/taglist/squarefz.png"
theme.taglist_squares_unsel = themes_path .. "zenburn/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = themes_path .. "zenburn/awesome-icon.png"
theme.menu_submenu_icon      = themes_path .. "zenburn/submenu.png"
-- }}}

-- {{{ Layout
theme.layout_tile           = themes_path .. "zenburn/layouts/tile.png"
theme.layout_tileleft       = themes_path .. "zenburn/layouts/tileleft.png"
theme.layout_tilebottom     = themes_path .. "zenburn/layouts/tilebottom.png"
theme.layout_tiletop        = themes_path .. "zenburn/layouts/tiletop.png"
theme.layout_fairv          = themes_path .. "zenburn/layouts/fairv.png"
theme.layout_fairh          = themes_path .. "zenburn/layouts/fairh.png"
theme.layout_spiral         = themes_path .. "zenburn/layouts/spiral.png"
theme.layout_dwindle        = themes_path .. "zenburn/layouts/dwindle.png"
theme.layout_max            = themes_path .. "zenburn/layouts/max.png"
theme.layout_fullscreen     = themes_path .. "zenburn/layouts/fullscreen.png"
theme.layout_magnifier      = themes_path .. "zenburn/layouts/magnifier.png"
theme.layout_floating       = themes_path .. "zenburn/layouts/floating.png"
theme.layout_cornernw       = themes_path .. "zenburn/layouts/cornernw.png"
theme.layout_cornerne       = themes_path .. "zenburn/layouts/cornerne.png"
theme.layout_cornersw       = themes_path .. "zenburn/layouts/cornersw.png"
theme.layout_cornerse       = themes_path .. "zenburn/layouts/cornerse.png"

theme.layout_termfair       = themes_lain_path .. "icons/layout/zenburn/termfair.png"
theme.layout_centerfair     = themes_lain_path .. "icons/layout/zenburn/centerfair.png"
theme.layout_cascade        = themes_lain_path .. "icons/layout/zenburn/cascade.png"
theme.layout_cascadetile    = themes_lain_path .. "icons/layout/zenburn/cascadetile.png"
theme.layout_centerwork     = themes_lain_path .. "icons/layout/zenburn/centerwork.png"
theme.layout_centerworkh    = themes_lain_path .. "icons/layout/zenburn/centerworkh.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = themes_path .. "zenburn/titlebar/close_focus.png"
theme.titlebar_close_button_normal = themes_path .. "zenburn/titlebar/close_normal.png"

theme.titlebar_minimize_button_normal = themes_path .. "zenburn/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path .. "zenburn/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_focus_active  = themes_path .. "zenburn/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = themes_path .. "zenburn/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path .. "zenburn/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = themes_path .. "zenburn/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = themes_path .. "zenburn/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = themes_path .. "zenburn/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path .. "zenburn/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = themes_path .. "zenburn/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = themes_path .. "zenburn/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = themes_path .. "zenburn/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = themes_path .. "zenburn/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = themes_path .. "zenburn/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = themes_path .. "zenburn/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = themes_path .. "zenburn/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path .. "zenburn/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = themes_path .. "zenburn/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
