-- {{{ LuaRocks
pcall(require, "luarocks.loader")
-- }}}

-- {{{ Standard libraries
local awful                 = require("awful")
                              require("awful.autofocus")
local awful_hotkeys_popup   = require("awful.hotkeys_popup")
                              require("awful.hotkeys_popup.keys")
local beautiful             = require("beautiful")
local gears                 = require("gears")
local lain                  = require("lain")
local menu                  = require("menu")
local menubar               = require("menubar")
local naughty               = require("naughty")
local wibox                 = require("wibox")
local widget_battery        = require("widget.battery")
local widget_clock          = require("widget.clock")
local widget_cpu            = require("widget.cpu")
local widget_file_system    = require("widget.file_system")
local widget_memory         = require("widget.memory")
local widget_network        = require("widget.network")
local widget_spotify        = require("widget.spotify")
local widget_volume         = require("widget.volume")
local widget_vpn            = require("widget.vpn")
-- }}}

-- {{{ Variable definitions
local MOD_KEY               = "Mod4"
local SHIFT_KEY             = "Shift"
local TERMINAL              = "xterm"

local MOUSE_LEFT_BUTTON     = 1
local MOUSE_MIDDLE_BUTTON   = 2
local MOUSE_RIGHT_BUTTON    = 3
local MOUSE_UP_BUTTON       = 4
local MOUSE_DOWN_BUTTON     = 5
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
    awesome.connect_signal(
        "debug::error",
        function (err)
            if (in_error) then return end
            in_error = true

            naughty.notify(
                {
                    preset = naughty.config.presets.critical,
                    title = "Unexpected error",
                    text = tostring(err)
                }
            )
            in_error = false
        end
    )
end
-- }}}

-- {{{ Themes definitions
function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if (type(wallpaper) == "function") then
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
                awful.layout.suit.magnifier
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
                        selected = ((s.index == screens.SCREEN_ONE) and (i == 1)) or ((s.index == screens.SCREEN_TWO) and (i == 2))
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
                { name = "terminal",    layout = layouts.LAYOUT_TILE_LEFT   },
                { name = "web",         layout = layouts.LAYOUT_TILE_LEFT   },
                { name = "dev",         layout = layouts.LAYOUT_MAX         },
                { name = "parsec",      layout = layouts.LAYOUT_MAX         },
                { name = "chat",        layout = layouts.LAYOUT_TILE_LEFT   },
                { name = "zoom",        layout = layouts.LAYOUT_TILE_LEFT   },
                { name = "extra",       layout = layouts.LAYOUT_FLOATING    }
            },

        [screens.SCREEN_TWO] =
            {
                { name = "terminal",    layout = layouts.LAYOUT_TILE_LEFT   },
                { name = "web",         layout = layouts.LAYOUT_TILE_LEFT   },
                { name = "dev",         layout = layouts.LAYOUT_MAX         },
                { name = "music",       layout = layouts.LAYOUT_TILE_LEFT   },
                { name = "chat",        layout = layouts.LAYOUT_TILE_LEFT   },
                { name = "zoom",        layout = layouts.LAYOUT_TILE_LEFT   },
                { name = "extra",       layout = layouts.LAYOUT_FLOATING    }
            }
    }
-- }}}

-- {{{ Menu definitions
-- Set the terminal for applications that require it
menubar.utils.terminal = TERMINAL

local awesome_menu =
    {
        { "Hotkeys",    function() awful_hotkeys_popup.show_help(nil, awful.screen.focused()) end   },
        { "Lock",       "xscreensaver-command -lock"                                                },
        { "Restart",    awesome.restart                                                             },
        { "Quit",       function() awesome.quit() end                                               },
        { "Reboot",     "shutdown -r now"                                                           },
        { "Shutdown",   "shutdown -h now"                                                           }
    }

local main_menu_items =
    {
        { "awesome", awesome_menu, beautiful.awesome_icon }
    }
for _, entry in ipairs(xdgmenu) do
    table.insert(main_menu_items, entry)
end
local main_menu = awful.menu({ items = main_menu_items })
local launcher_menu = awful.widget.launcher(
    {
        image = beautiful.awesome_icon,
        menu =  main_menu
    }
)
-- }}}

-- {{{ Startup programs
function startup_programs()
    awful.spawn("discord")
    awful.spawn("firefox")
    awful.spawn("slack")
    awful.spawn("steam")
    awful.spawn("zoom")
end
-- }}}

-- {{{ Widgets definitions
-- Quake console
quake = lain.util.quake(
    {
        app         = TERMINAL,
        extra       = "-fg white -bg black",
        followtag   = true,
        height      = 0.5
    }
)

-- Menu bar buttons
local menu_bar_buttons = gears.table.join(
    awful.button(
        {},
        MOUSE_RIGHT_BUTTON,
        function ()
            awful.menu.client_list({ theme = { width = 250 } })
        end
    )
)

-- Tag list buttons
local taglist_buttons = gears.table.join(
    awful.button(
        {},
        MOUSE_LEFT_BUTTON,
        function(t) t:view_only() end
    ),

    awful.button(
        { MOD_KEY },
        MOUSE_LEFT_BUTTON,
        function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end
    ),

    awful.button(
        {},
        MOUSE_RIGHT_BUTTON,
        awful.tag.viewtoggle
    ),

    awful.button(
        { MOD_KEY },
        MOUSE_RIGHT_BUTTON,
        function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end
    ),

    awful.button(
        {},
        MOUSE_UP_BUTTON,
        function(t)
            awful.tag.viewnext(t.screen)
        end
    ),

    awful.button(
        {},
        MOUSE_DOWN_BUTTON,
        function(t) awful.tag.viewprev(t.screen) end
    )
)

-- Task list buttons
local tasklist_buttons = gears.table.join(
    awful.button(
        {},
        MOUSE_LEFT_BUTTON,
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
        {},
        MOUSE_MIDDLE_BUTTON,
        function(c)
            c:kill()
        end
    ),

    awful.button(
        {},
        MOUSE_RIGHT_BUTTON,
        function ()
            awful.menu.client_list({ theme = { width = 250 } })
        end
    ),

    awful.button(
        {},
        MOUSE_UP_BUTTON,
        function ()
            awful.client.focus.byidx(1)
        end
    ),

    awful.button(
        {},
        MOUSE_DOWN_BUTTON,
        function ()
            awful.client.focus.byidx(-1)
        end
    )
)

-- Separators
local spr       = wibox.widget.imagebox(beautiful.spr)
local spr4px    = wibox.widget.imagebox(beautiful.spr4px)

-- Battery widget
local battery_widget = widget_battery(
    {
        icons =
            {
                ac = beautiful.widget.ac,
                battery = 
                    {
                        charging = 
                            {
                                empty = beautiful.widget.battery_charging_empty,
                                full = beautiful.widget.battery_charging_full,
                                good = beautiful.widget.battery_charging_good,
                                low = beautiful.widget.battery_charging_low
                            },
                        empty = beautiful.widget.battery_empty,
                        full = beautiful.widget.battery_full,
                        good = beautiful.widget.battery_good,
                        low = beautiful.widget.battery_low
                    },
                logo = beautiful.widget.ac
            },
        timeout = 2
    }
)

-- Clock widget
local clock_widget = widget_clock(
    {
        icons =
            {
                logo = beautiful.widget.clock
            }
    }
)

-- Cpu widget
local cpu_widget = widget_cpu(
    {
        icons =
            {
                logo = beautiful.widget.cpu
            },
        terminal = TERMINAL,
        timeout = 2
    }
)

-- File system widget
local file_system_widget = widget_file_system(
    {
        icons =
            {
                logo = beautiful.widget.ssd
            },
        mount_default = "/home",
        mounts =
            {
                "/",
                "/home",
                "/mnt/data",
                "/mnt/games",
                "/mnt/usb"
            },
        timeout = 30
    }
)

-- Keyboard widget
local keyboard_widget = awful.widget.keyboardlayout()

-- Memory widget
local memory_widget = widget_memory(
    {
        icons =
            {
                logo = beautiful.widget.mem
            },
        terminal = TERMINAL,
        timeout = 2
    }
)

-- Microphone widget
local microphone_widget = widget_volume(
    {
        device_type = "source",
        icons =
            {
                high = beautiful.widget.microphone_high,
                low = beautiful.widget.microphone_low,
                medium = beautiful.widget.microphone_medium,
                muted = beautiful.widget.microphone_muted
            },
        timeout = 2
    }
)

-- Network widget
local network_widget = widget_network(
    {
        icons =
            {
                eth = beautiful.widget.eth,
                netdl = beautiful.widget.netdl,
                netup = beautiful.widget.netul,
                wifi = beautiful.widget.wifi,
                wifi_excellent = beautiful.widget.wifi_excellent,
                wifi_very_good = beautiful.widget.wifi_very_good,
                wifi_good = beautiful.widget.wifi_good,
                wifi_weak = beautiful.widget.wifi_weak,
                wifi_none = beautiful.widget.wifi_none
            },
        timeout = 2
    }
)

-- Spotify widget
local spotify_widget = widget_spotify(
    {
        icons =
            {
                logo = beautiful.mpd_spotify,
                next = beautiful.mpd_next,
                pause = beautiful.mpd_pause,
                play = beautiful.mpd_play,
                prev = beautiful.mpd_prev
            }
    }
)

-- Volume widget
local volume_widget = widget_volume(
    {
        device_type = "sink",
        icons =
            {
                high = beautiful.widget.volume_high,
                low = beautiful.widget.volume_low,
                medium = beautiful.widget.volume_medium,
                muted = beautiful.widget.volume_muted
            },
        timeout = 2
    }
)

-- Vpn widget
local vpn_widget = widget_vpn(
    {
        icons =
            {
                connected = beautiful.widget.vpn_connected,
                diconnected = beautiful.widget.vpn_disconnected
            },
        timeout = 2
    }
)

function set_widgets(s)
    -- Prompt box
    s.promptbox =
        awful.widget.prompt(
            {
                prompt = " Execute: "
            }
        )

    -- Layout box
    s.layoutbox = awful.widget.layoutbox(s)
    s.layoutbox:buttons(
        gears.table.join(
            awful.button(
                {},
                MOUSE_LEFT_BUTTON,
                function () awful.layout.inc( 1) end
            ),

            awful.button(
                {},
                MOUSE_RIGHT_BUTTON,
                function () awful.layout.inc(-1) end
            ),

            awful.button(
                {},
                MOUSE_UP_BUTTON,
                function () awful.layout.inc( 1) end
            ),

            awful.button(
                {},
                MOUSE_DOWN_BUTTON,
                function () awful.layout.inc(-1) end
            )
        )
    )

    -- Tag list
    s.tag_list = awful.widget.taglist(
        {
            screen  = s,
            filter  = awful.widget.taglist.filter.all,
            buttons = taglist_buttons
        }
    )

    -- Task list
    s.task_list = awful.widget.tasklist(
        {
            screen  = s,
            filter  = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons
        }
    )

    -- Wibox
    s.top_wibox = awful.wibar({ position = "top", screen = s, height = 22, bg = beautiful.panel, fg = beautiful.fg_normal })
    if (s == screen.primary) or (1 == screen.count()) then
        s.top_wibox:setup(
            {
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
                    spotify_widget,
                    -- Separator
                    spr,
                    spr4px,
                    spr,
                    -- Volume
                    volume_widget,
                    -- Separator
                    spr,
                    -- Microphone
                    microphone_widget,
                    -- Separator
                    spr,
                    spr4px,
                    spr
                },
                {
                    -- Middle widget
                    layout = wibox.layout.fixed.horizontal
                },
                {
                    -- Right widgets
                    layout = wibox.layout.fixed.horizontal,
                    -- Separator
                    spr,
                    spr4px,
                    spr,
                    -- Cpu
                    cpu_widget,
                    -- Separator
                    spr,
                    -- Memory
                    memory_widget,
                    -- Separator
                    spr,
                    -- File system widget
                    file_system_widget,
                    -- Separator
                    spr,
                    -- Battery widget
                    battery_widget,
                    -- Separator
                    spr,
                    spr4px,
                    spr,
                    -- Network
                    network_widget,
                    -- Separator
                    spr,
                    -- Vpn
                    vpn_widget,
                    -- Separator
                    spr,
                    spr4px,
                    spr,
                    -- Keyboard
                    keyboard_widget,
                    -- Separator
                    spr,
                    -- Clock
                    clock_widget,
                    -- Separator
                    spr,
                    spr4px,
                    spr,
                    -- Layout box
                    s.layoutbox
                }
            }
        )
    else
        s.top_wibox:setup(
            {
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
                    spotify_widget,
                    -- Separator
                    spr,
                    spr4px,
                    spr,
                    -- Volume
                    volume_widget,
                    -- Separator
                    spr,
                    -- Microphone
                    microphone_widget,
                    -- Separator
                    spr,
                    spr4px,
                    spr
                },
                {
                    -- Middle widget
                    layout = wibox.layout.fixed.horizontal
                },
                {
                    -- Right widgets
                    layout = wibox.layout.fixed.horizontal,
                    -- Separator
                    spr,
                    spr4px,
                    spr,
                    -- Cpu
                    cpu_widget,
                    -- Separator
                    spr,
                    -- Memory
                    memory_widget,
                    -- Separator
                    spr,
                    -- File system widget
                    file_system_widget,
                    -- Separator
                    spr,
                    -- Battery widget
                    battery_widget,
                    -- Separator
                    spr,
                    spr4px,
                    spr,
                    -- Network
                    network_widget,
                    -- Separator
                    spr,
                    -- Vpn
                    vpn_widget,
                    -- Separator
                    spr,
                    spr4px,
                    spr,
                    -- Keyboard
                    keyboard_widget,
                    -- Separator
                    spr,
                    -- Clock
                    clock_widget,
                    -- Separator
                    spr,
                    spr4px,
                    spr,
                    -- Layout box
                    s.layoutbox
                }
            }
        )
    end

    -- Bottom box
    s.bottom_wibox = awful.wibar({ position = "bottom", screen = s, height = 22, bg = beautiful.panel, fg = beautiful.fg_normal })
    if (s == screen.primary) or (1 == screen.count()) then
        s.bottom_wibox:setup(
            {
                buttons = menu_bar_buttons,
                layout = wibox.layout.align.horizontal,
                {
                    -- Left widgets
                    layout = wibox.layout.fixed.horizontal,
                    -- Launcher menu
                    launcher_menu,
                    -- Separator
                    spr,
                    spr4px
                },
                {
                    -- Middle widget
                    layout = wibox.layout.fixed.horizontal,
                    -- Task list
                    s.task_list
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
                    spr4px
                }
            }
        )
    else
        s.bottom_wibox:setup(
            {
                buttons = menu_bar_buttons,
                layout = wibox.layout.align.horizontal,
                {
                    -- Left widgets
                    layout = wibox.layout.fixed.horizontal,
                    -- Launcher menu
                    launcher_menu,
                    -- Separator
                    spr,
                    spr4px
                },
                {
                    -- Middle widget
                    layout = wibox.layout.fixed.horizontal,
                    -- Task list
                    s.task_list
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
                    spr4px
                }
            }
        )
    end
end
-- }}}

-- {{{ Mouse bindings definitions
root.buttons(
    gears.table.join(
        awful.button({}, MOUSE_LEFT_BUTTON, function () main_menu:hide() end),
        awful.button({}, MOUSE_RIGHT_BUTTON, function () main_menu:show() end)
    )
)
-- }}}

-- {{{ Key bindings definitions
local globalkeys = gears.table.join(

    -- General

    awful.key(
        { MOD_KEY, SHIFT_KEY },
        "/",
        awful_hotkeys_popup.show_help,
        { description = "show help", group="awesome" }
    ),

    awful.key(
        { MOD_KEY },
        "w",
        function () main_menu:show() end,
        { description = "show main menu", group = "awesome" }
    ),

    awful.key(
        { MOD_KEY, SHIFT_KEY },
        "r",
        awesome.restart,
        { description = "reload awesome", group = "awesome" }
    ),

    awful.key(
        { MOD_KEY, SHIFT_KEY },
        "q",
        awesome.quit,
        { description = "quit awesome", group = "awesome" }
    ),

    awful.key(
        { MOD_KEY },
        "q",
        function () awful.spawn("xscreensaver-command -lock") end,
        { description = "lock awesome", group = "awesome" }
    ),

    -- Launcher

    awful.key(
        { MOD_KEY, SHIFT_KEY },
        "Return",
        function () startup_programs() end,
        { description = "startup programs", group = "launcher" }
    ),

    awful.key(
        { MOD_KEY },
        "Return",
        function () awful.spawn(TERMINAL) end,
        { description = "terminal", group = "launcher" }
    ),

    awful.key(
        { MOD_KEY },
        "`",
        function () quake:toggle() end,
        { description = "quake terminal", group = "launcher" }
    ),

    awful.key(
        { MOD_KEY },
        "F2",
        function () awful.screen.focused().promptbox:run() end,
        { description = "run program", group = "launcher" }
    ),

    awful.key(
        { MOD_KEY },
        "p",
        function() awful.spawn("snipping") end,
        { description = "snipping tool", group = "launcher" }
    ),

    -- Layout

    awful.key(
        { MOD_KEY },
        "l",
        function () awful.tag.incmwfact(-0.05) end,
        { description = "increase width", group = "layout" }
    ),

    awful.key(
        { MOD_KEY },
        "h",
        function () awful.tag.incmwfact( 0.05) end,
        { description = "decrease width", group = "layout" }
    ),

    awful.key(
        { MOD_KEY, SHIFT_KEY },
        "space",
        function () awful.layout.inc(-1) end,
        { description = "previous layout", group = "layout" }
    ),

    awful.key(
        { MOD_KEY },
        "space",
        function () awful.layout.inc( 1) end,
        { description = "next layout", group = "layout" }
    ),

    -- Programs

    awful.key(
        { MOD_KEY, SHIFT_KEY },
        "Tab",
        function () awful.client.focus.byidx( 1) end,
        { description = "previous program", group = "program" }
    ),

    awful.key(
        { MOD_KEY },
        "Tab",
        function () awful.client.focus.byidx(-1) end,
        { description = "next program", group = "program" }
    ),

    -- Screen

    awful.key(
        { MOD_KEY, SHIFT_KEY },
        "j",
        function () awful.screen.focus_relative( 1) end,
        { description = "previous screen", group = "screen" }
    ),

    awful.key(
        { MOD_KEY, SHIFT_KEY },
        "k",
        function () awful.screen.focus_relative(-1) end,
        { description = "next screen", group = "screen" }
    ),

    -- Spotify

    awful.key(
        { MOD_KEY },
        "s",
        function() spotify_widget:play_pause() end,
        { description = "play / pause music", group = "spotify" }
    ),

    awful.key(
        { MOD_KEY },
        "a",
        function() spotify_widget:previous() end,
        { description = "previous song", group = "spotify" }
    ),

    awful.key(
        { MOD_KEY },
        "d",
        function() spotify_widget:next() end,
        { description = "next song", group = "spotify" }
    ),

    -- Tags

    awful.key(
        { MOD_KEY },
        "Left",
        awful.tag.viewprev,
        { description = "previous tag", group = "tag" }
    ),

    awful.key(
        { MOD_KEY },
        "Right",
        awful.tag.viewnext,
        { description = "next tag", group = "tag" }
    )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key(
            { MOD_KEY },
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
            { MOD_KEY, SHIFT_KEY },
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
        {},
        MOUSE_LEFT_BUTTON,
        function (c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end
    ),

    awful.button(
        { MOD_KEY },
        MOUSE_LEFT_BUTTON,
        function (c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.move(c)
        end
    ),

    awful.button(
        { MOD_KEY },
        MOUSE_RIGHT_BUTTON,
        function (c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.resize(c)
        end
    )
)

clientkeys = gears.table.join(
    awful.key(
        { MOD_KEY },
        "F4",
        function (c) c:kill() end,
        { description = "close", group = "program" }
    ),

    awful.key(
        { MOD_KEY },
        "f",
        awful.client.floating.toggle,
        { description = "toggle floating", group = "program" }
    ),

    awful.key(
        { MOD_KEY },
        "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        { description = "(un)maximize", group = "program" }
    ),

    awful.key(
        { MOD_KEY },
        "n",
        function (c) c.minimized = true end ,
        { description = "minimize", group = "program" }
    ),

    awful.key(
        { MOD_KEY },
        "o",
        function (c) c:move_to_screen() end,
        { description = "move to screen", group = "program" }
    ),

    awful.key(
        { MOD_KEY },
        "t",
        function (c) c.ontop = not c.ontop end,
        { description = "toggle on top", group = "program" }
    )

    -- awful.key(
    --     { MOD_KEY },
    --     "e",
    --     function (c)
    --         naughty.notify(
    --             {
    --                 title = "Screens",
    --                 text = "Screens: " .. screen.count()
    --             }
    --         )
    --     end,
    --     { description = "screens", group = "program" }
    -- )
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
                    class = "[Ff]irefox"
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
                    class = "[Ff]ree[Tt]ube"
                },
            properties =
                {
                    floating = false,
                    screen = screens.SCREEN_TWO <= screen.count() and screens.SCREEN_TWO or awful.screen.preferred,
                    tag = tags.names[tags.TAG_EXTRA],
                    titlebars_enabled = false
                }
        },

        {
            rule =
                {
                    class = "[Mm]ullvad [Bb]rowser"
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
        },

        {
            rule =
                {
                    class = "[Zz]oom[Ww]ebview[Hh]ost"
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
client.connect_signal(
    "manage",
    function (c)
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- if not awesome.startup then awful.client.setslave(c) end

        if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(c)
        end
    end
)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
    "request::titlebars",
    function(c)
        local clicks = 0
        -- buttons for the titlebar
        local buttons = gears.table.join(
            awful.button(
                {},
                MOUSE_LEFT_BUTTON,
                function()
                    clicks = clicks + 1
                    if clicks == 2 then
                        c.maximized = not c.maximized
                    else
                        c:emit_signal("request::activate", "titlebar", { raise = true })
                        awful.mouse.client.move(c)
                    end

                    gears.timer.weak_start_new(250 / 1000, function() clicks = 0 end)
                end
            ),

            awful.button(
                {},
                MOUSE_MIDDLE_BUTTON,
                function()
                    c:kill()
                end
            ),

            awful.button(
                {},
                MOUSE_RIGHT_BUTTON,
                function()
                    c:emit_signal("request::activate", "titlebar", { raise = true })
                    awful.mouse.client.resize(c)
                end
            )
        )

        awful.titlebar(c):setup(
            {
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
        )
    end
)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal(
    "mouse::enter",
    function(c)
        c:emit_signal("request::activate", "mouse_enter", { raise = false })
    end
)

client.connect_signal(
    "focus",
    function(c)
        c.border_color = beautiful.border_focus
    end
)

client.connect_signal(
    "unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end
)

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal(
    "property::geometry",
    set_wallpaper
)

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
