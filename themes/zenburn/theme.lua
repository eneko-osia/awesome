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
theme.bg_reset   = "#00000000"
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
theme.mpd_feishin                   = themes_path .. "zenburn/panel/apps/feishin.png"
theme.mpd_prev                      = themes_path .. "zenburn/panel/widgets/mpd_prev.svg"
theme.mpd_next                      = themes_path .. "zenburn/panel/widgets/mpd_next.svg"
theme.mpd_stop                      = themes_path .. "zenburn/panel/widgets/mpd_stop.svg"
theme.mpd_pause                     = themes_path .. "zenburn/panel/widgets/mpd_pause.svg"
theme.mpd_play                      = themes_path .. "zenburn/panel/widgets/mpd_play.svg"
theme.mpd_sepr                      = themes_path .. "zenburn/panel/widgets/mpd_sepr.png"
theme.mpd_sepl                      = themes_path .. "zenburn/panel/widgets/mpd_sepl.png"
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
theme.widget = {}
theme.widget.ac                     = themes_path .. "zenburn/panel/widgets/battery_ac.svg"
theme.widget.battery_charging_empty = themes_path .. "zenburn/panel/widgets/battery_charging_empty.svg"
theme.widget.battery_charging_full  = themes_path .. "zenburn/panel/widgets/battery_charging_full.svg"
theme.widget.battery_charging_good  = themes_path .. "zenburn/panel/widgets/battery_charging_good.svg"
theme.widget.battery_charging_low   = themes_path .. "zenburn/panel/widgets/battery_charging_low.svg"
theme.widget.battery_empty          = themes_path .. "zenburn/panel/widgets/battery_empty.svg"
theme.widget.battery_full           = themes_path .. "zenburn/panel/widgets/battery_full.svg"
theme.widget.battery_good           = themes_path .. "zenburn/panel/widgets/battery_good.svg"
theme.widget.battery_low            = themes_path .. "zenburn/panel/widgets/battery_low.svg"
theme.widget.cal                    = themes_path .. "zenburn/panel/widgets/cal.png"
theme.widget.clock                  = themes_path .. "zenburn/panel/widgets/clock.png"
theme.widget.cpu                    = themes_path .. "zenburn/panel/widgets/cpu.png"
theme.widget.eth                    = themes_path .. "zenburn/panel/widgets/eth.svg"
theme.widget.mem                    = themes_path .. "zenburn/panel/widgets/mem.png"
theme.widget.microphone_high        = themes_path .. "zenburn/panel/widgets/microphone_high.svg"
theme.widget.microphone_low         = themes_path .. "zenburn/panel/widgets/microphone_low.svg"
theme.widget.microphone_medium      = themes_path .. "zenburn/panel/widgets/microphone_medium.svg"
theme.widget.microphone_muted       = themes_path .. "zenburn/panel/widgets/microphone_muted.svg"
theme.widget.netdl                  = themes_path .. "zenburn/panel/widgets/netdl.png"
theme.widget.netul                  = themes_path .. "zenburn/panel/widgets/netul.png"
theme.widget.ssd                    = themes_path .. "zenburn/panel/widgets/fs.png"
theme.widget.volume_high            = themes_path .. "zenburn/panel/widgets/volume_high.svg"
theme.widget.volume_low             = themes_path .. "zenburn/panel/widgets/volume_low.svg"
theme.widget.volume_medium          = themes_path .. "zenburn/panel/widgets/volume_medium.svg"
theme.widget.volume_muted           = themes_path .. "zenburn/panel/widgets/volume_muted.svg"
theme.widget.vpn_connected          = themes_path .. "zenburn/panel/widgets/vpn_connected.svg"
theme.widget.vpn_disconnected       = themes_path .. "zenburn/panel/widgets/vpn_disconnected.svg"
theme.widget.wifi                   = themes_path .. "zenburn/panel/widgets/wifi.svg"
theme.widget.wifi_excellent         = themes_path .. "zenburn/panel/widgets/wifi_excellent.svg"
theme.widget.wifi_very_good         = themes_path .. "zenburn/panel/widgets/wifi_very_good.svg"
theme.widget.wifi_good              = themes_path .. "zenburn/panel/widgets/wifi_good.svg"
theme.widget.wifi_weak              = themes_path .. "zenburn/panel/widgets/wifi_weak.svg"
theme.widget.wifi_none              = themes_path .. "zenburn/panel/widgets/wifi_none.svg"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(25)
theme.menu_width  = dpi(180)
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
