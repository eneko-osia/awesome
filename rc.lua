-- {{{ LuaRocks
pcall(require, "luarocks.loader")
-- }}}

-- {{{ Standard libraries
local awful         = require("awful")
                      require("awful.autofocus")
local hotkeys_popup = require("awful.hotkeys_popup")
                      require("awful.hotkeys_popup.keys")
local watch         = require("awful.widget.watch")
local beautiful     = require("beautiful")
local calendar      = require("calendar")
local freedesktop   = require("freedesktop")
local gears         = require("gears")
local timer         = require("gears.timer")
local lain          = require("lain")
local menubar       = require("menubar")
local naughty       = require("naughty")
local wibox         = require("wibox")
-- }}}

-- {{{ Variable definitions
local altkey          = "Mod1"
local modkey          = "Mod4"
local terminal        = "xterm"
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify(
        {
            preset = naughty.config.presets.critical,
            title = "Startup error",
            text = awesome.startup_errors
        }
    )
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)

        if in_error then return end
        in_error = true

        naughty.notify(
            {
                preset = naughty.config.presets.critical,
                title = "Unexpected error",
                text = tostring(err)
            }
        )
        in_error = false
    end)
end
-- }}}

-- {{{ Themes definitions
function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/zenburn/theme.lua")
-- }}}

-- {{{ Notifications theme
-- naughty.config.defaults.screen              = awful.screen.preferred
naughty.config.presets.critical.opacity     = 0.8
naughty.config.presets.normal.bg            = beautiful.notify_bg
naughty.config.presets.normal.border_color  = beautiful.notify_border
naughty.config.presets.normal.fg            = beautiful.notify_fg
naughty.config.presets.normal.font          = beautiful.notify_font
naughty.config.presets.normal.opacity       = 0.8
naughty.config.presets.low.opacity          = 0.8
-- }}}

-- {{{ Layouts definitions
local layouts =
{
    LAYOUT_FLOATING =               1,
    LAYOUT_TILE =                   2,
    LAYOUT_TILE_LEFT =              3,
    LAYOUT_TILE_BOTTOM =            4,
    LAYOUT_TILE_TOP =               5,
    LAYOUT_FAIR =                   6,
    LAYOUT_FAIR_HORIZONTAL =        7,
    LAYOUT_SPIRAL =                 8,
    LAYOUT_SPIRAL_DWINDLE =         9,
    LAYOUT_MAX =                    10,
    LAYOUT_MAX_FULLSCREEN =         11,
    LAYOUT_MAGNIFIER =              12,
    LAYOUT_CENTERWORK =             13,
    LAYOUT_CASCADE =                14,
    LAYOUT_CASCADE_TILE =           15,
    LAYOUT_CENTERWORK_HORIZONTAL =  16,
    LAYOUT_TERMFAIR_CENTER =        17,

    suits =
    {
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.top,
        awful.layout.suit.fair,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.spiral,
        awful.layout.suit.spiral.dwindle,
        awful.layout.suit.max,
        awful.layout.suit.max.fullscreen,
        awful.layout.suit.magnifier,
        lain.layout.centerwork,
        lain.layout.cascade,
        lain.layout.cascade.tile,
        lain.layout.centerwork.horizontal,
        lain.layout.termfair.center
    }
}

-- Set layouts
awful.layout.layouts = layouts.suits
-- }}}

-- {{{ Screens definitions
local screens =
{
    SCREEN_ONE =    1,
    SCREEN_TWO =    2
}
-- }}}

-- {{{ Tags definitions
function set_tags(s, tags)
    if tags[s.index] ~= nil then
        for i, settings in ipairs(tags[s.index]) do
            awful.tag.add(
                settings.name,
                {
                    layout = layouts.suits[settings.layout],
                    screen = s,
                    selected = ((s.index == screens.SCREEN_TWO) and (i == 2)) or ((s.index == screens.SCREEN_ONE) and (i == 1))
                }
            )
        end
    else
        awful.tag({ "main" }, s,layouts.suits[layouts.LAYOUT_FLOATING])
    end
end

local tags =
{
    TAG_CHAT =      1,
    TAG_DEV =       2,
    TAG_EXTRA =     3,
    TAG_MUSIC =     4,
    TAG_PARSEC =    5,
    TAG_TERMINAL =  6,
    TAG_WEB =       7,
    TAG_ZOOM =      8,

    names =
    {
        "chat",
        "dev",
        "extra",
        "music",
        "parsec",
        "terminal",
        "web",
        "zoom"
    },

    [screens.SCREEN_ONE] =
    {
        { name = "terminal",    layout = layouts.LAYOUT_TILE_LEFT               },
        { name = "web",         layout = layouts.LAYOUT_TILE_LEFT               },
        { name = "dev",         layout = layouts.LAYOUT_MAX                     },
        { name = "parsec",      layout = layouts.LAYOUT_MAX                     },
        { name = "chat",        layout = layouts.LAYOUT_TILE_LEFT               },
        { name = "zoom",        layout = layouts.LAYOUT_TILE_LEFT               },
        { name = "extra",       layout = layouts.LAYOUT_FLOATING                }
    },

    [screens.SCREEN_TWO] =
    {
        { name = "terminal",    layout = layouts.LAYOUT_CENTERWORK_HORIZONTAL   },
        { name = "web",         layout = layouts.LAYOUT_TILE_TOP                },
        { name = "dev",         layout = layouts.LAYOUT_MAX                     },
        { name = "music",       layout = layouts.LAYOUT_TILE_TOP                },
        { name = "chat",        layout = layouts.LAYOUT_TILE_TOP                },
        { name = "zoom",        layout = layouts.LAYOUT_TILE_TOP                },
        { name = "extra",       layout = layouts.LAYOUT_FLOATING                }
    }
}
-- }}}

-- {{{ Menu definitions
-- Set the terminal for applications that require it
menubar.utils.terminal = terminal

local awesome_menu =
{
    { "Hotkeys",    function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "Lock",       "xscreensaver-command -lock"                                        },
    { "Restart",    awesome.restart                                                     },
    { "Quit",       function() awesome.quit() end                                       },
    { "Reboot",     "shutdown -r now"                                                   },
    { "Shutdown",   "shutdown -h now"                                                   }
}

local main_menu = freedesktop.menu.build(
    {
        before =
        {
            { "awesome", awesome_menu, beautiful.awesome_icon }
        }
    }
)

local menu = awful.widget.launcher(
    {
        image = beautiful.awesome_icon,
        menu =  main_menu
    }
)
-- }}}

-- {{{ Music definitions
local spotify_song          = "Spotify"
local spotify_song_color    = beautiful.fg_focus
local spotify_song_index    = 0
local spotify_song_size     = 0
local spotify_song_state    = 0
local spotify_song_text     = "Spotify"

function set_spotify_text(widget, song)
    if string.find(song, "Error: Spotify is not running.") ~= nil then
        spotify_song = "Spotify"
        spotify_song_text = "  Spotify  "
        spotify_song_color = beautiful.fg_urgent
        spotify_song_index = 1
        spotify_song_size = spotify_song_text:len()

        widget:set_markup(
            "<span foreground=" .. "'"..spotify_song_color .. "'" .. ">" ..
            spotify_song_text ..
            "</span>"
        )
    else
        if (spotify_song ~= song) then
            spotify_song = song
            spotify_song_text = "   " .. spotify_song:sub(1, spotify_song:len() - 1) .. "   "
            spotify_song_index = 1
            spotify_song_size = spotify_song_text:len()
        end

        if (spotify_song_state == 1) then
            spotify_song_color = beautiful.fg_focus
        else
            spotify_song_color = beautiful.fg_normal
        end

        widget:set_markup(
            "<span foreground=" .. "'"..spotify_song_color .. "'" .. ">" ..
            spotify_song_text:sub(spotify_song_index, spotify_song_size) ..
            spotify_song_text:sub(1, spotify_song_index - 1) ..
            "</span>"
        )
    end
end

function update_play_pause_icon(widget, state)
    if (state:gsub("\n", "") == "Playing") then
        spotify_song_state = 1
        widget.image = beautiful.mpd_pause
    else
        spotify_song_state = 0
        widget.image = beautiful.mpd_play
    end
end

function update_spotify_text(widget, song)
    if (spotify_song_state == 1) then
        spotify_song_index = spotify_song_index + 1
    else
        spotify_song_index = 1
    end

    if (spotify_song_index <= 0) then
        spotify_song_index = spotify_song_size - 1
    end

    if (spotify_song_index >= spotify_song_size) then
        spotify_song_index = 1
    end

    set_spotify_text(widget, song)
end

function spotify_next()
    awful.util.spawn("sp next")
end

function spotify_pause()
    awful.util.spawn("sp pause")
end

function spotify_play()
    awful.util.spawn("sp play")
end

function spotify_play_pause()
    spotify_play()
end

function spotify_previous()
    awful.util.spawn("sp prev")
end
-- }}}

function startup_programs()
    awful.spawn("librewolf")
    awful.spawn("discord")
    awful.spawn("slack")
    awful.spawn("steam")
    awful.spawn("zoom")
end
-- }}}

-- {{{ Widgets definitions
-- Quake console
quake = lain.util.quake(
    {
        app         = terminal,
        extra       = "-fg white -bg black",
        followtag   = true,
        height      = 0.5,
        onlyone     = true
    }
)

-- Menu bar buttons
local menu_bar_buttons = gears.table.join(
    awful.button(
        { },
        3,
        function ()
            awful.menu.client_list({ theme = { width = 250 } })
        end
    )
)

-- Tag list buttons
local taglist_buttons = gears.table.join(
    awful.button(
        { },
        1,
        function(t) t:view_only() end
    ),

    awful.button(
        { modkey },
        1,
        function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end
    ),

    awful.button(
        { },
        3,
        awful.tag.viewtoggle
    ),

    awful.button(
        { modkey },
        3,
        function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end
    ),

    awful.button(
        { },
        4,
        function(t)
            awful.tag.viewnext(t.screen)
        end
    ),

    awful.button(
        { },
        5,
        function(t) awful.tag.viewprev(t.screen) end
    )
)

-- Task list buttons
local tasklist_buttons = gears.table.join(
    awful.button(
        { },
        1,
        function (c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal(
                    "request::activate",
                    "tasklist",
                    {
                        raise = true
                    }
                )
            end
        end
    ),

    awful.button(
        { },
        2,
        function(c)
            c:kill()
        end
    ),

    awful.button(
        { },
        3,
        function ()
            awful.menu.client_list({ theme = { width = 250 } })
        end
    ),

    awful.button(
        { },
        4,
        function ()
            awful.client.focus.byidx(1)
        end
    ),

    awful.button(
        { },
        5,
        function ()
            awful.client.focus.byidx(-1)
        end
    )
)

-- Widget container
local widget_display        = wibox.widget.imagebox(beautiful.widget_display)
local widget_display_center = wibox.widget.imagebox(beautiful.widget_display_center)
local widget_display_left   = wibox.widget.imagebox(beautiful.widget_display_left)
local widget_display_right  = wibox.widget.imagebox(beautiful.widget_display_right)

-- Separators
local spr       = wibox.widget.imagebox(beautiful.spr)
local spr4px    = wibox.widget.imagebox(beautiful.spr4px)
local spr5px    = wibox.widget.imagebox(beautiful.spr5px)

-- Keyboard widget
local keyboard_widget = awful.widget.keyboardlayout()

-- Clock widget
local clock_icon = wibox.widget.imagebox(beautiful.widget_clock)
local text_clock = wibox.widget.textclock(" %a %d %b %H:%M ")
local clock_widget = wibox.container.background(text_clock)
clock_widget.bgimage = beautiful.widget_display

-- Calendar widget
calendar({}):attach(text_clock)

-- Cpu widget
local cpu_icon = wibox.widget.imagebox(beautiful.widget_cpu)
local cpu = lain.widget.cpu({
    settings =
        function()
            widget:set_markup(" " .. cpu_now.usage .. "%" .. " ")
        end
})
local cpu_widget = wibox.container.background(cpu.widget)
cpu_widget.bgimage = beautiful.widget_display

cpu.widget:buttons(awful.util.table.join(
    awful.button(
        { },
        1,
        function()
            awful.spawn(terminal .." -e htop")
        end
    )
))

-- Memory widget
local mem_icon = wibox.widget.imagebox(beautiful.widget_mem)
local mem = lain.widget.mem({
    settings =
        function()
            widget:set_markup(" " .. mem_now.perc .. "%" .. " ")
        end
})
local mem_widget = wibox.container.background(mem.widget)
mem_widget.bgimage = beautiful.widget_display

-- Ssd widget
local ssd_icon = wibox.widget.imagebox(beautiful.widget_ssd)
local ssd = lain.widget.fs({
    followtag = true,
    settings = function()
        widget:set_markup(string.format(" %d%% ", fs_now["/home"].percentage))
    end
})
local ssd_widget = wibox.container.background(ssd.widget)
ssd_widget.bgimage = beautiful.widget_display

-- Battery widget
local battery_icon = wibox.widget.imagebox(beautiful.widget_battery)
local battery_notification = nil
local battey_time = ""
local battery = lain.widget.bat({
    notify = "off",
    full_notify = "off",
    settings = function()
        if bat_now.ac_status == "N/A" or bat_now.ac_status == 1 then
            battery_icon:set_image(beautiful.widget_battery_ac)
            if bat_now.perc ~= "N/A" then
                battery_time = " " .. bat_now.time .. " "
                widget:set_markup(" " .. bat_now.perc .. "%" .. " ")
            else
                battery_time = " " .. bat_now.time .. " "
                widget:set_markup(" 100% ")
            end
        elseif bat_now.perc ~= "N/A" then
            bat_perc_number = tonumber(bat_now.perc)
            if bat_now.ac_status == 1 or bat_perc_number == 100 then
                battery_icon:set_image(beautiful.widget_battery_ac)
                battery_time = " " .. bat_now.time .. " "
                widget:set_markup(" " .. bat_now.perc .. "%" .. " ")
            elseif bat_perc_number > 50 then
                battery_icon:set_image(beautiful.widget_battery)
                battery_time = " " .. bat_now.time .. " "
                widget:set_markup(" " .. bat_now.perc .. "%" .. " ")
            elseif bat_perc_number > 15 then
                battery_icon:set_image(beautiful.widget_battery_low)
                battery_time = " " .. bat_now.time .. " "
                widget:set_markup(lain.util.markup(beautiful.fg_focus, " " .. bat_now.perc .. "%" .. " "))
            else
                battery_icon:set_image(beautiful.widget_battery_empty)
                battery_time = " " .. bat_now.time .. " "
                widget:set_markup(lain.util.markup(beautiful.fg_urgent, " " .. bat_now.perc .. "%" .. " "))
            end
        else
            battery_icon:set_image(beautiful.widget_battery_empty)
            battery_time = " " .. bat_now.time .. " "
            widget:set_markup(lain.util.markup(beautiful.fg_urgent, " " .. bat_now.perc .. "%" .. " "))
        end
    end
})
local battery_widget = wibox.container.background(battery.widget)
battery_widget.bgimage = beautiful.widget_display
battery_widget:connect_signal('mouse::enter', function()
    battery_notification = naughty.notify(
        {
            title = "Battery time",
            text = battery_time
        })
end)
battery_widget:connect_signal('mouse::leave', function()
    naughty.destroy(battery_notification)
    battery_notification = nil
end)

-- Network widget
local netdl_icon = wibox.widget.imagebox(beautiful.widget_netdl)
local netup_icon = wibox.widget.imagebox(beautiful.widget_netul)
local netdl = wibox.widget.textbox()
netdl.align = "center"
netdl.forced_width = 64
local netup = wibox.widget.textbox()
netup.align = "center"
netup.forced_width = 64
local net = lain.widget.net({
    settings = function()
        if (tonumber(net_now.received) > 1024.0) then
            netdl:set_markup(string.format(" %.1f Mb ", tonumber(net_now.received) / 1024))
        else
            netdl:set_markup(string.format(" %.1f Kb ", net_now.received))
        end

        if (tonumber(net_now.sent) > 1024.0) then
            netup:set_markup(string.format(" %.1f Mb ", tonumber(net_now.sent) / 1024))
        else
            netup:set_markup(string.format(" %.1f Kb ", net_now.sent))
        end
    end
})
local netdl_widget = wibox.container.background(netdl)
netdl_widget.bgimage = beautiful.widget_display
local netup_widget = wibox.container.background(netup)
netup_widget.bgimage = beautiful.widget_display

-- Music widget
local next_icon = wibox.widget.imagebox(beautiful.mpd_nex)
local play_pause_icon = wibox.widget.imagebox(beautiful.mpd_play)
local prev_icon = wibox.widget.imagebox(beautiful.mpd_prev)
local spotify_text = wibox.widget.textbox()
spotify_text.align = "center"
spotify_text.forced_width = 256
local spotify_widget = wibox.container.background(spotify_text)
spotify_widget.bgimage = beautiful.widget_display

next_icon:buttons(gears.table.join(awful.button({ }, 1, function() spotify_next() end)))
play_pause_icon:buttons(gears.table.join(awful.button({ }, 1, function() spotify_play_pause() end)))
prev_icon:buttons(gears.table.join(awful.button({ }, 1, function() spotify_previous() end)))

play_pause_icon:connect_signal(
    "button::press",
    function(x, y, button, mods, find_widgets_result)
        awful.spawn.easy_async("sp status",
            function(stdout, stderr, exitreason, exitcode)
                update_play_pause_icon(play_pause_icon, stdout)
            end
        )
    end
)

spotify_text:buttons(awful.util.table.join(
    awful.button(
        { },
        4,
        function()
            if (spotify_song_state == 1) then
                spotify_song_index = spotify_song_index + 1
                if (spotify_song_index >= spotify_song_size) then
                    spotify_song_index = 1
                end
                set_spotify_text(spotify_text, spotify_song)
            end
        end
    ),

    awful.button(
        { },
        5,
        function()
            if (spotify_song_state == 1) then
                spotify_song_index = spotify_song_index - 1
                if (spotify_song_index <= 0) then
                    spotify_song_index = spotify_song_size - 1
                end
                set_spotify_text(spotify_text, spotify_song)
            end
        end
    )
))

watch("sp current-oneline", 1,
    function (widget, stdout, _, _, _)
        update_spotify_text(widget, stdout)
    end,
    spotify_text
)

watch("sp status", 1,
    function (widget, stdout, _, _, _)
        update_play_pause_icon(widget, stdout)
    end,
    play_pause_icon
)

-- Volume widget
local volume_icon = wibox.widget.imagebox(beautiful.widget_volume)
local volume = lain.widget.pulse{
    devicetype = "sink",
    settings =
        function()
            widget:set_markup(lain.util.markup(beautiful.fg_focus, " " .. volume_now.left .. "%" .. (volume_now.muted == "yes" and " [M]" or "") .. " "))
        end
}
local volume_widget = wibox.container.background(volume.widget)
volume_widget.bgimage = beautiful.widget_display

volume.widget:buttons(awful.util.table.join(
    awful.button(
        { },
        1,
        function()
            awful.spawn("pavucontrol")
        end
    ),

    awful.button(
        { },
        2,
        function()
            if volume.device ~= nil then
                os.execute(string.format("pactl set-sink-mute %d toggle", volume.device))
                volume.update()
            end
        end
    ),

    awful.button(
        { },
        3,
        function()
            if volume.device ~= nil then
                os.execute(string.format("pactl set-sink-volume %d %d%%", volume.device, 100))
                volume.update()
            end
        end
    ),

    awful.button(
        { },
        4,
        function()
            if volume.device ~= nil then
                os.execute(string.format("pactl set-sink-volume %d +1%%", volume.device))
                volume.update()
            end
        end
    ),

    awful.button(
        { },
        5,
        function()
            if volume.device ~= nil then
                os.execute(string.format("pactl set-sink-volume %d -1%%", volume.device))
                volume.update()
            end
        end
    )
))

-- Microphone widget
local microphone_icon = wibox.widget.imagebox(beautiful.widget_microphone)
local microphone = lain.widget.pulse{
    devicetype = "source",
    settings =
        function()
            widget:set_markup(lain.util.markup(beautiful.fg_focus, " " .. volume_now.left .. "%" .. (volume_now.muted == "yes" and " [M]" or "") .. " "))
        end
}
local microphone_widget = wibox.container.background(microphone.widget)
microphone_widget.bgimage = beautiful.widget_display

microphone.widget:buttons(awful.util.table.join(
    awful.button(
        { },
        1,
        function()
            awful.spawn("pavucontrol")
        end
    ),

    awful.button(
        { },
        2,
        function()
            if microphone.device ~= nil then
                os.execute(string.format("pactl set-source-mute %d toggle", microphone.device))
                microphone.update()
            end
        end
    ),

    awful.button(
        { },
        3,
        function()
            if microphone.device ~= nil then
                os.execute(string.format("pactl set-source-volume %d %d%%", microphone.device, 100))
                microphone.update()
            end
        end
    ),

    awful.button(
        { },
        4,
        function()
            if microphone.device ~= nil then
                os.execute(string.format("pactl set-source-volume %d +1%%", microphone.device))
                microphone.update()
            end
        end
    ),

    awful.button(
        { },
        5,
        function()
            if microphone.device ~= nil then
                os.execute(string.format("pactl set-source-volume %d -1%%", microphone.device))
                microphone.update()
            end
        end
    )
))

function set_widgets(s)
    -- Prompt box
    s.promptbox =
        awful.widget.prompt({
            prompt = " Execute: "
        })

    -- Layout box
    s.layoutbox = awful.widget.layoutbox(s)
    s.layoutbox:buttons(
        gears.table.join(
            awful.button(
                { },
                1,
                function () awful.layout.inc( 1) end
            ),

            awful.button(
                { },
                3,
                function () awful.layout.inc(-1) end
            ),

            awful.button(
                { },
                4,
                function () awful.layout.inc( 1) end
            ),

            awful.button(
                { },
                5,
                function () awful.layout.inc(-1) end
            )
        )
    )

    -- Tag list
    s.tag_list = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Task list
    s.task_list = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Wibox
    s.top_wibox = awful.wibar({ position = "top", screen = s, height = 22, bg = beautiful.panel, fg = beautiful.fg_normal })
    s.top_wibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- Separator
            spr,
            spr4px,
            spr,
            -- Tag list
            s.tag_list,
            -- Separator
            spr,
            spr4px,
            spr,
            -- Volume
            spr4px,
            volume_icon,
            widget_display_left,
            volume_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            -- Microphone
            spr4px,
            microphone_icon,
            widget_display_left,
            microphone_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            spr4px,
            spr,
        },
        {
            -- Middle widget
            layout = wibox.layout.fixed.horizontal,
        },
        {
            -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- Separator
            spr,
            spr4px,
            spr,
            -- Cpu
            cpu_icon,
            widget_display_left,
            cpu_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            -- Memory
            mem_icon,
            widget_display_left,
            mem_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            -- Ssd widget
            ssd_icon,
            widget_display_left,
            ssd_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            -- Battery widget
            battery_icon,
            widget_display_left,
            battery_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            -- Network
            netdl_icon,
            widget_display_left,
            netdl_widget,
            widget_display_center,
            netup_widget,
            widget_display_right,
            netup_icon,
            -- Separator
            spr,
            spr4px,
            spr,
            -- Clock
            clock_icon,
            widget_display_left,
            clock_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            spr4px,
            spr,
          -- Layout box
            s.layoutbox,
        },
    }

    s.bottom_wibox = awful.wibar({ position = "bottom", screen = s, height = 22, bg = beautiful.panel, fg = beautiful.fg_normal })
    s.bottom_wibox:setup {
        buttons = menu_bar_buttons,
        layout = wibox.layout.align.horizontal,
        {
            -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- Menu
            menu,
            -- Separator
            spr,
            spr4px,
        },
        {
            -- Middle widget
            layout = wibox.layout.fixed.horizontal,
            -- Task list
            s.task_list,
        },
        {
            -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- Separator
            spr,
            spr4px,
            spr,
            -- Prompt box
            s.promptbox,
            -- Separator
            spr,
            spr4px,
        },
    }
end

function set_widgets_primary(s)
    -- Prompt box
    s.promptbox =
        awful.widget.prompt({
            prompt = " Execute: "
        })

    -- Layout box
    s.layoutbox = awful.widget.layoutbox(s)
    s.layoutbox:buttons(
        gears.table.join(
            awful.button(
                { },
                1,
                function () awful.layout.inc( 1) end
            ),

            awful.button(
                { },
                3,
                function () awful.layout.inc(-1) end
            ),

            awful.button(
                { },
                4,
                function () awful.layout.inc( 1) end
            ),

            awful.button(
                { },
                5,
                function () awful.layout.inc(-1) end
            )
        )
    )

    -- Tag list
    s.tag_list = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Task list
    s.task_list = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Wibox
    s.top_wibox = awful.wibar({ position = "top", screen = s, height = 22, bg = beautiful.panel, fg = beautiful.fg_normal })
    s.top_wibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- Separator
            spr,
            spr4px,
            spr,
            -- Tag list
            s.tag_list,
            -- Separator
            spr,
            spr4px,
            spr,
            -- Music
            spr4px,
            widget_display_left,
            spotify_widget,
            widget_display_right,
            spr4px,
            spr,
            prev_icon,
            spr,
            play_pause_icon,
            spr,
            next_icon,
            -- Separator
            spr,
            spr4px,
            spr,
            -- Volume
            spr4px,
            volume_icon,
            widget_display_left,
            volume_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            -- Microphone
            spr4px,
            microphone_icon,
            widget_display_left,
            microphone_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            spr4px,
            spr,
        },
        {
            -- Middle widget
            layout = wibox.layout.fixed.horizontal,
        },
        {
            -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- Separator
            spr,
            spr4px,
            spr,
            -- Cpu
            cpu_icon,
            widget_display_left,
            cpu_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            -- Memory
            mem_icon,
            widget_display_left,
            mem_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            -- Ssd widget
            ssd_icon,
            widget_display_left,
            ssd_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            -- Battery widget
            battery_icon,
            widget_display_left,
            battery_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            -- Network
            netdl_icon,
            widget_display_left,
            netdl_widget,
            widget_display_center,
            netup_widget,
            widget_display_right,
            netup_icon,
            -- Separator
            spr,
            spr4px,
            spr,
            -- Clock
            clock_icon,
            widget_display_left,
            clock_widget,
            widget_display_right,
            spr4px,
            -- Separator
            spr,
            spr4px,
            spr,
          -- Layout box
            s.layoutbox,
        },
    }

    s.bottom_wibox = awful.wibar({ position = "bottom", screen = s, height = 22, bg = beautiful.panel, fg = beautiful.fg_normal })
    s.bottom_wibox:setup {
        buttons = menu_bar_buttons,
        layout = wibox.layout.align.horizontal,
        {
            -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- Menu
            menu,
            -- Separator
            spr,
            spr4px,
        },
        {
            -- Middle widget
            layout = wibox.layout.fixed.horizontal,
            -- Task list
            s.task_list,
        },
        {
            -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- Separator
            spr,
            spr4px,
            spr,
            -- Prompt box
            s.promptbox,
            -- Separator
            spr,
            spr4px,
            spr,
            -- System tray
            wibox.widget.systray(),
            -- Separator
            spr,
            spr4px,
        },
    }
end
-- }}}

-- {{{ Mouse bindings definitions
root.buttons(gears.table.join(
    awful.button({ }, 1, function () main_menu:hide() end),
    awful.button({ }, 3, function () main_menu:show() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings definitions
local globalkeys = gears.table.join(

    -- General

    awful.key(
        { modkey, "Shift" },
        "/",
        hotkeys_popup.show_help,
        { description = "show help", group="awesome" }
    ),

    awful.key(
        { modkey },
        "w",
        function () main_menu:show() end,
        { description = "show main menu", group = "awesome" }
    ),

    awful.key(
        { modkey, "Shift" },
        "r",
        awesome.restart,
        { description = "reload awesome", group = "awesome" }
    ),

    awful.key(
        { modkey, "Shift" },
        "q",
        awesome.quit,
        { description = "quit awesome", group = "awesome" }
    ),

    awful.key(
        { modkey },
        "q",
        function () awful.util.spawn("xscreensaver-command -lock") end,
        { description = "lock awesome", group = "awesome" }
    ),

    -- Launcher

    awful.key(
        { modkey, "Shift" },
        "Return",
        function () startup_programs() end,
        { description = "startup programs", group = "launcher" }
    ),

    awful.key(
        { modkey },
        "Return",
        function () awful.spawn(terminal) end,
        { description = "terminal", group = "launcher" }
    ),

    awful.key(
        { modkey },
        "`",
        function () quake:toggle() end,
        { description = "quake terminal", group = "launcher" }
    ),

    awful.key(
        { modkey },
        "F2",
        function () awful.screen.focused().promptbox:run() end,
        { description = "run program", group = "launcher" }
    ),

    awful.key(
        { modkey },
        "p",
        function() awful.util.spawn("snipping") end,
        { description = "snipping tool", group = "launcher" }
    ),

    -- Layout

    awful.key(
        { modkey },
        "l",
        function () awful.tag.incmwfact(-0.05) end,
        { description = "increase width", group = "layout" }
    ),

    awful.key(
        { modkey },
        "h",
        function () awful.tag.incmwfact( 0.05) end,
        { description = "decrease width", group = "layout" }
    ),

    awful.key(
        { modkey, "Shift" },
        "space",
        function () awful.layout.inc(-1) end,
        { description = "previous layout", group = "layout" }
    ),

    awful.key(
        { modkey },
        "space",
        function () awful.layout.inc( 1) end,
        { description = "next layout", group = "layout" }
    ),

    -- Programs

    awful.key(
        { modkey, "Shift" },
        "Tab",
        function () awful.client.focus.byidx( 1) end,
        { description = "previous program", group = "program" }
    ),

    awful.key(
        { modkey },
        "Tab",
        function () awful.client.focus.byidx(-1) end,
        { description = "next program", group = "program" }
    ),

    -- Screen

    awful.key(
        { modkey, "Shift" },
        "j",
        function () awful.screen.focus_relative( 1) end,
        { description = "previous screen", group = "screen" }
    ),

    awful.key(
        { modkey, "Shift" },
        "k",
        function () awful.screen.focus_relative(-1) end,
        { description = "next screen", group = "screen" }
    ),

    -- Spotify

    awful.key(
        { modkey },
        "s",
        function() spotify_play_pause() end,
        { description = "play / pause music", group = "spotify" }
    ),

    awful.key(
        { modkey },
        "a",
        function() spotify_previous() end,
        { description = "previous song", group = "spotify" }
    ),

    awful.key(
        { modkey },
        "d",
        function() spotify_next() end,
        { description = "next song", group = "spotify" }
    ),

    -- Tags

    awful.key(
        { modkey },
        "Left",
        awful.tag.viewprev,
        { description = "previous tag", group = "tag" }
    ),

    awful.key(
        { modkey },
        "Right",
        awful.tag.viewnext,
        { description = "next tag", group = "tag" }
    )
)

clientkeys = gears.table.join(

    -- Programs

    awful.key(
        { modkey },
        "F4",
        function (c) c:kill() end,
        { description = "close", group = "program" }
    ),

    awful.key(
        { modkey },
        "f",
        awful.client.floating.toggle,
        { description = "toggle floating", group = "program" }
    ),

    awful.key(
        { modkey },
        "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        { description = "(un)maximize", group = "program" }
    ),

    awful.key(
        { modkey },
        "n",
        function (c) c.minimized = true end ,
        { description = "minimize", group = "program" }
    ),

    awful.key(
        { modkey },
        "o",
        function (c) c:move_to_screen() end,
        { description = "move to screen", group = "program" }
    ),

    awful.key(
        { modkey },
        "t",
        function (c) c.ontop = not c.ontop end,
        { description = "toggle on top", group = "program" }
    )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key(
            { modkey },
            "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "tag #"..i, group = "tag" }
        ),

        -- Move client to tag.
        awful.key(
            { modkey, "Shift" },
            "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move to tag #"..i, group = "tag" }
        )
    )
end

clientbuttons = gears.table.join(
    awful.button(
        { },
        1,
        function (c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end
    ),

    awful.button(
        { modkey },
        1,
        function (c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.move(c)
        end
    ),

    awful.button(
        { modkey },
        3,
        function (c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.resize(c)
        end
    )
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules definitions
awful.rules.rules =
{
    {
        rule =
        {

        },
        properties =
        {
            border_color    = beautiful.border_normal,
            border_width    = beautiful.border_width,
            focus           = awful.client.focus.filter,
            raise           = true,
            buttons         = clientbuttons,
            keys            = clientkeys,
            screen          = awful.screen.preferred,
            placement       = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    },

    {
        rule_any =
        {
            type = { "dialog", "normal" }
        },
        properties =
        {
            floating = true,
            titlebars_enabled = true
        },
        callback = function (c)
            awful.placement.centered(c,nil)
        end
    },

    {
        rule =
        {
            class = "[Bb]attle.net"
        },
        properties =
        {
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_EXTRA]
        }
    },

    {
        rule =
        {
            class = "[Ll]ibre[Ww]olf"
        },
        properties =
        {
            floating = false,
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_WEB],
            titlebars_enabled = false
        }
    },

    {
        rule =
        {
            class = "[Vv][Ss][Cc]odium"
        },
        properties =
        {
            floating = false,
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_DEV],
            titlebars_enabled = false
        }
    },

    {
        rule =
        {
            class = "[Dd]iscord"
        },
        properties =
        {
            floating = false,
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_CHAT],
            titlebars_enabled = false
        }
    },

    {
        rule =
        {
            class = "[Pp]arsecd"
        },
        properties =
        {
            floating = false,
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_PARSEC],
            titlebars_enabled = false
        }
    },

    {
        rule =
        {
            class = "[Ss]lack"
        },
        properties =
        {
            floating = false,
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_CHAT],
            titlebars_enabled = false
        }
    },

    {
        rule =
        {
            class = "[Ss]potify"
        },
        properties =
        {
            floating = false,
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_MUSIC],
            titlebars_enabled = false
        }
    },

    {
        rule =
        {
            class = "[Ss]team"
        },
        properties =
        {
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_EXTRA]
        }
    },

    {
        rule =
        {
            class = "[Xx][Tt]erm"
        },
        properties =
        {
            floating = false,
            titlebars_enabled = false
        }
    },

    {
        rule =
        {
            class = "[Zz]oom"
        },
        properties =
        {
            floating = false,
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_ZOOM]
        }
    }
}
-- }}}

-- {{{ Signals definitions
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    local clicks = 0
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button(
            { },
            1,
            function()
                clicks = clicks + 1
                if clicks == 2 then
                    c.maximized = not c.maximized
                else
                    c:emit_signal("request::activate", "titlebar", { raise = true })
                    awful.mouse.client.move(c)
                end

                timer.weak_start_new(250 / 1000, function() clicks = 0 end)
            end
        ),

        awful.button(
            { },
            2,
            function()
                c:kill()
            end
        ),

        awful.button(
            { },
            3,
            function()
                c:emit_signal("request::activate", "titlebar", { raise = true })
                awful.mouse.client.resize(c)
            end
        )
    )

    awful.titlebar(c) : setup {
        {
            -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },

        {
            -- Middle
            {
                -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },

        {
            -- Right
            awful.titlebar.widget.minimizebutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(
    function(s)
        -- Wallpaper
        set_wallpaper(s)

        -- Tags
        set_tags(s, tags)

        -- Widgets
        if s == screen.primary then
            set_widgets_primary(s)
        else
            set_widgets(s)
        end
    end
)
-- }}}
