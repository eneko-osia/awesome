-- {{{ Standard libraries
local awful           = require("awful")
                        require("awful.autofocus")
local hotkeys_popup   = require("awful.hotkeys_popup").widget
                        require("awful.hotkeys_popup.keys")
local watch           = require("awful.widget.watch")
local beautiful       = require("beautiful")
local calendar        = require("calendar")
local freedesktop     = require("freedesktop")
local gears           = require("gears")
local lain            = require("lain")
local menubar         = require("menubar")
local naughty         = require("naughty")
local wibox           = require("wibox")

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
            title = "Oops, there were errors during startup!",
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
                title = "Oops, an error happened!",
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
    SCREEN_TWO =    2,
    SCREEN_THREE =  3,
    MAX_SCREEN =    3
}
-- }}}

-- {{{ Tags definitions
function set_tags(s, tags)
    if screens.MAX_SCREEN == screen:count() then
        if tags[s.index] ~= nil then
            for i, settings in ipairs(tags[s.index]) do
                awful.tag.add(
                    settings.name, 
                    {
                        layout = layouts.suits[settings.layout],
                        screen = s,
                        selected = (i == 1)
                    }
                )
            end
        else
            awful.tag({ "1", "2", "3" }, s,layouts.suits[layouts.LAYOUT_FLOATING])
        end
    elseif 1 == screen:count() then
        is_selected = false
        for _, i in ipairs({screens.SCREEN_THREE , screens.SCREEN_ONE, screens.SCREEN_TWO}) do
            if tags[i] ~= nil then
                for j, settings in ipairs(tags[i]) do
                    awful.tag.add(
                        settings.name, 
                        {
                            layout = layouts.suits[settings.layout],
                            screen = s,
                            selected = (i == screens.SCREEN_THREE) and (j == 1)
                        }
                    )
                end
            end
        end
    else
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s,layouts.suits[layouts.LAYOUT_FLOATING])
    end
end

local tags = 
{
    TAG_TERMINAL =      1,
    TAG_VSCODE =        2,
    TAG_SUBLIME =       3,
    TAG_DEV =           4,
    TAG_UNITY =         5,
    TAG_WEB_UNITY =     6,
    TAG_WEB_HOME =      7,
    TAG_SLACK =         8,
    TAG_MUSIC =         9,
    TAG_EXTRA =         10,

    names =
    {
        "terminal",
        "vscode",
        "sublime",
        "dev",
        "unity",
        "web [unity]",
        "web [home]",
        "slack",
        "music",
        "extra"
    },

    [screens.SCREEN_ONE] = 
    {
        { name = "vscode",      layout = layouts.LAYOUT_MAX         },
        { name = "dev",         layout = layouts.LAYOUT_MAX         },
        { name = "extra",       layout = layouts.LAYOUT_FLOATING    }
    },

    [screens.SCREEN_TWO] = 
    {
        { name = "web [unity]", layout = layouts.LAYOUT_MAX         },
        { name = "web [home]",  layout = layouts.LAYOUT_MAX         },
        { name = "slack",       layout = layouts.LAYOUT_TILE        },
        { name = "music",       layout = layouts.LAYOUT_MAX         },
        { name = "unity",       layout = layouts.LAYOUT_FLOATING    },
        { name = "extra",       layout = layouts.LAYOUT_FLOATING    }
    },

    [screens.SCREEN_THREE] = 
    {
        { name = "terminal",    layout = layouts.LAYOUT_CENTERWORK_HORIZONTAL   },
        { name = "sublime",     layout = layouts.LAYOUT_TILE_TOP                },
        { name = "extra",       layout = layouts.LAYOUT_FLOATING                }
    }
}
-- }}}

-- {{{ Menu definitions
-- Set the terminal for applications that require it
menubar.utils.terminal = terminal

local awesome_menu = 
{
    { "Hotkeys",    function() return false, hotkeys_popup.show_help end    },
    { "Lock",       "xscreensaver-command -lock"                            },
    { "Restart",    awesome.restart                                         },
    { "Quit",       function() awesome.quit() end                           },
    { "Reboot",     "shutdown -r 0"                                         },
    { "Shutdown",   "shutdown -h 0"                                         }
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

function set_play_pause_icon(widget, state)
    if (state:gsub("\n", "") == "Playing") then
        spotify_song_state = 1
        widget.image = beautiful.mpd_pause
    else
        spotify_song_state = 0
        widget.image = beautiful.mpd_play
    end
end

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
    awful.util.spawn("sp play-pause")
end

function spotify_previous()
    awful.util.spawn("sp prev")
end

function spotify_stop()
    awful.util.spawn("sp stop")
end
-- }}}

-- {{{ Auto start applications
awful.spawn("xrandr --output HDMI-0 --pos 0x620 --output DP-2 --pos 2560x620 --primary --output DP-0.8 --rotate right --pos 5120x0")

function startup_programs()
    awful.spawn("blueman-applet")
    awful.spawn("code")
    awful.spawn("subl")
    awful.spawn("chromium-browser")
    awful.spawn("slack")
    awful.spawn("xscreensaver -no-splash")
    awful.spawn("xterm")
    awful.spawn("xterm")
    awful.spawn("xterm")
end
-- }}}

-- {{{ Widgets definitions
-- Quake console
quake = lain.util.quake(
    {
        app         = terminal,
        followtag   = true,
        height      = 0.5,
        onlyone     = true
    }
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
                -- Without this, the following
                -- :isvisible() makes no sense
                c.minimized = false
                if not c:isvisible() and c.first_tag then
                    c.first_tag:view_only()
                end
                -- This will also un-minimize
                -- the client, if needed
                client.focus = c
                c:raise()
            end
        end
    ),

    awful.button(
        { },
        3,
        function ()
            local instance = nil
            return function ()
                if instance and instance.wibox.visible then
                    instance:hide()
                    instance = nil
                else
                    instance = awful.menu.clients({ theme = { width = 250 } })
                end
            end
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
clock_widget.bgimage=beautiful.widget_display

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
cpu_widget.bgimage=beautiful.widget_display

-- Memory widget
local mem_icon = wibox.widget.imagebox(beautiful.widget_mem)
local mem = lain.widget.mem({
    settings =
        function()
            widget:set_markup(" " .. mem_now.perc .. "%" .. " ")
        end
})
local mem_widget = wibox.container.background(mem.widget)
mem_widget.bgimage=beautiful.widget_display

-- Ssd widget
local ssd_icon = wibox.widget.imagebox(beautiful.widget_ssd)
local ssd = lain.widget.fs({
    followtag = true,
    settings = function()
        widget:set_markup(string.format(" %d%% ", fs_now["/home"].percentage))
    end
})
local ssd_widget = wibox.container.background(ssd.widget)
ssd_widget.bgimage=beautiful.widget_display

-- Network widget
local netdl_icon = wibox.widget.imagebox(beautiful.widget_netdl)
local netup_icon = wibox.widget.imagebox(beautiful.widget_netul)
local netdl = wibox.widget.textbox()
local netup = wibox.widget.textbox()
local net = lain.widget.net({
    settings = function()
        netdl:set_markup(string.format(" %.1f Kb ", net_now.received))
        netup:set_markup(string.format(" %.1f Kb ", net_now.sent))
    end
})
local netdl_widget = wibox.container.background(netdl)
netdl_widget.bgimage=beautiful.widget_display
local netup_widget = wibox.container.background(netup)
netup_widget.bgimage=beautiful.widget_display

-- Music widget
local next_icon = wibox.widget.imagebox(beautiful.mpd_nex)
local play_pause_icon = wibox.widget.imagebox(beautiful.mpd_play)
local prev_icon = wibox.widget.imagebox(beautiful.mpd_prev)
local stop_icon = wibox.widget.imagebox(beautiful.mpd_stop)
local spotify_text = wibox.widget.textbox()
spotify_text.align = "center"
spotify_text.forced_width = 256
local spotify_widget = wibox.container.background(spotify_text)
spotify_widget.bgimage=beautiful.widget_display

next_icon:buttons(gears.table.join(awful.button({ }, 1, function() spotify_next() end)))
play_pause_icon:buttons(gears.table.join(awful.button({ }, 1, function() spotify_play_pause() end)))
prev_icon:buttons(gears.table.join(awful.button({ }, 1, function() spotify_previous() end)))
stop_icon:buttons(gears.table.join(awful.button({ }, 1, function() spotify_stop() end)))

play_pause_icon:connect_signal(
    "button::press",
    function(x, y, button, mods, find_widgets_result)
        awful.spawn.easy_async("sp status", 
            function(stdout, stderr, exitreason, exitcode)
                set_play_pause_icon(play_pause_icon, stdout)
            end
        )
    end
)

spotify_text:buttons(awful.util.table.join(
    awful.button(
        {}, 
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
        {}, 
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
        set_play_pause_icon(widget, stdout) 
    end, 
    play_pause_icon
)

-- Volume widget
local volume_icon = wibox.widget.imagebox(beautiful.widget_volume)
local device_bluetooth = "CC:98:8B:7F:F9:CE"
local device_front = "front:0"
local volume = lain.widget.pulse{
    settings = 
    function()
        if volume_now.device == device_bluetooth or volume_now.device == device_front then
            widget:set_markup(lain.util.markup(beautiful.fg_focus, " " .. volume_now.left .. "%" .. (volume_now.muted == "yes" and " [M]" or "") .. " "))
        else
            widget:set_markup(lain.util.markup(beautiful.fg_urgent, "0%"))
        end
    end
}
local volume_widget = wibox.container.background(volume.widget)
volume_widget.bgimage=beautiful.widget_display

volume.widget:buttons(awful.util.table.join(
    awful.button(
        {}, 
        1, 
        function()
            awful.spawn("pavucontrol")
        end
    ),

    awful.button(
        {}, 
        2, 
        function()
            os.execute(string.format("pactl set-sink-mute %d toggle", volume.device))
            volume.update()
        end
    ),

    awful.button(
        {}, 
        3, 
        function()
            local value = volume.device == device_bluetooth and 100 or 20
            os.execute(string.format("pactl set-sink-volume %d %d%%", volume.device, value))
            volume.update()
        end
    ),

    awful.button(
        {}, 
        4, 
        function()
            os.execute(string.format("pactl set-sink-volume %d +1%%", volume.device))
            volume.update()
        end
    ),

    awful.button(
        {}, 
        5, 
        function()
            os.execute(string.format("pactl set-sink-volume %d -1%%", volume.device))
            volume.update()
        end
    )
))

function set_widgets(s)
    -- Prompt box
    s.mypromptbox =
        awful.widget.prompt({
            prompt = " Execute: "
        })

    -- Layout box
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(
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
    s.tag_list = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Task list
    s.task_list = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

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
            stop_icon,
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
            -- Prompt box
            s.mypromptbox,
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
            s.mylayoutbox,
        },
    }

    s.bottom_wibox = awful.wibar({ position = "bottom", screen = s, height = 22, bg = beautiful.panel, fg = beautiful.fg_normal })
    s.bottom_wibox:setup {
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
    awful.button({ }, 3, function () main_menu:toggle() end),
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
        function () awful.screen.focused().mypromptbox:run() end,
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
        function () awful.tag.incmwfact( 0.05) end,
        { description = "increase width", group = "layout" }
    ),

    awful.key(
        { modkey },
        "h",
        function () awful.tag.incmwfact(-0.05) end,
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
        { modkey },
        "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "back program", group = "program" }
    ),

    awful.key(
        { modkey },
        "j",
        function () awful.client.focus.byidx( 1) end,
        { description = "previous program", group = "program" }
    ),

    awful.key(
        { modkey },
        "k",
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
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "fullscreen", group = "program" }
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
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

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
            type = { "dialog" }
        },
        properties =
        {
            floating = true,
            titlebars_enabled = true
        }
    },

    {
        rule =
        {
            class = "[Xx][Tt]erm"
        },
        properties =
        {
            screen = screens.SCREEN_THREE <= screen.count() and screens.SCREEN_THREE or awful.screen.preferred,
            tag = tags.names[tags.TAG_TERMINAL]
        }
    },

    {
        rule =
        {
            class = "[Ss]ublime"
        },
        properties =
        {
            screen = screens.SCREEN_THREE <= screen.count() and screens.SCREEN_THREE or awful.screen.preferred,
            tag = tags.names[tags.TAG_SUBLIME]
        }
    },

    {
        rule =
        {
            class = "[Cc]ode"
        },
        properties =
        {
            maximized_horizontal = true,
            maximized_vertical = true,
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_VSCODE]
        }
    },

    {
        rule =
        {
            class = "[Rr]ider"
        },
        properties =
        {
            maximized_horizontal = true,
            maximized_vertical = true,
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_VSCODE]
        }
    },

    {
        rule =
        {
            class = "[Mm]eld"
        },
        properties =
        {
            maximized_horizontal = true,
            maximized_vertical = true,
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_DEV]
        }
    },

    {
        rule =
        {
            class = "[Pp]4v"
        },
        properties =
        {
            maximized_horizontal = true,
            maximized_vertical = true,
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_DEV]
        }
    },

    {
        rule =
        {
            class = "[Gg]itk"
        },
        properties =
        {
            maximized_horizontal = true,
            maximized_vertical = true,
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_DEV]
        }
    },

    {
        rule =
        {
            class = "[Tt]hg"
        },
        properties =
        {
            maximized_horizontal = true,
            maximized_vertical = true,
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_DEV]
        }
    },

    {
        rule =
        {
            class = "[Tt]ortoise[Hh]g"
        },
        properties =
        {
            maximized_horizontal = true,
            maximized_vertical = true,
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_DEV]
        }
    },

    {
        rule =
        {
            class = "[Cc]aja"
        },
        properties =
        {
            floating = true,
            screen = screens.SCREEN_ONE <= screen.count() and screens.SCREEN_ONE or awful.screen.preferred,
            tag = tags.names[tags.TAG_EXTRA],
            titlebars_enabled = true
        }
    },

    {
        rule =
        {
            class = "[Uu]nity"
        },
        properties =
        {
            floating = true,
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_UNITY],
            titlebars_enabled = true
        }
    },

    {
        rule =
        {
            class = "[Uu]nity[Hh]elper"
        },
        properties =
        {
            floating = true,
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_UNITY],
            titlebars_enabled = true
        }
    },

    {
        rule =
        {
            class = "[Uu]nity[Ss]hader[Cc]omp"
        },
        properties =
        {
            floating = true,
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_UNITY],
            titlebars_enabled = true
        }
    },

    {
        rule =
        {
            class = "[Ee]vince"
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
            class = "[Cc]hromium"
        },
        properties =
        {
            maximized_horizontal = true,
            maximized_vertical = true,
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_WEB_UNITY]
        }
    },

    {
        rule =
        {
            class = "[Ss]lack"
        },
        properties =
        {
            maximized_horizontal = true,
            maximized_vertical = true,
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_SLACK]
        }
    },

    {
        rule =
        {
            class = "[Ss]potify"
        },
        properties =
        {
            maximized_horizontal = true,
            maximized_vertical = true,
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_MUSIC]
        }
    },

    {
        rule =
        {
            class = "[Ss]team"
        },
        properties =
        {
            floating = true,
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_EXTRA],
            titlebars_enabled = true
        }
    },
    
    {
        rule =
        {
            class = "[Vv]irtual[Bb]ox"
        },
        properties =
        {
            screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
            tag = tags.names[tags.TAG_EXTRA]
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

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
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
        set_widgets(s)
    end
)
-- }}}
