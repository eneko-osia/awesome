-- {{{ Standard libraries
local awful         = require("awful")
local beautiful     = require("beautiful")
local beautiful_dpi = require("beautiful.xresources").apply_dpi
local gears         = require("gears")
local gears_timer   = require("gears.timer")
local wibox         = require("wibox")
-- }}}

-- {{{ Factory
local function factory(args)
    args = args or {}

    local icons = args.icons or
        {
            logo = nil,
            next = nil,
            pause = nil,
            play = nil,
            prev = nil
        }
    local song_index = 0
    local song_state = 0
    local song_text = "Spotify"

    local spotify = wibox.widget(
        {
            {
                {
                    {
                        {
                            widget = wibox.widget.imagebox(icons.logo)
                        },
                        layout = wibox.container.margin(_, 4, 4, 3, 3)
                    },
                    {
                        {
                            {
                                align  = "center",
                                forced_width = beautiful_dpi(256),
                                text = song_text,
                                valign = "center",
                                widget = wibox.widget.textbox
                            },
                            bg = beautiful.bg_focus,
                            shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 2) end,
                            widget = wibox.container.background
                        },
                        layout = wibox.container.margin(_, _, 4, 3, 3)
                    },
                    layout = wibox.layout.fixed.horizontal
                },
                bg = beautiful.bg_reset,
                shape = gears.shape.rectangle,
                widget = wibox.container.background
            },
            {
                {
                    widget = wibox.widget.imagebox(beautiful.spr)
                },
                layout = wibox.container.margin(_, _, _, _, _)
            },
            {
                {
                    {
                        widget = wibox.widget.imagebox(icons.prev)
                    },
                    layout = wibox.container.margin(_, 4, 4, 3, 3)
                },
                bg = beautiful.bg_reset,
                shape = gears.shape.rectangle,
                widget = wibox.container.background
            },
            {
                {
                    widget = wibox.widget.imagebox(beautiful.spr)
                },
                layout = wibox.container.margin(_, _, _, _, _)
            },
            {
                {
                    {
                        widget = wibox.widget.imagebox(icons.play)
                    },
                    layout = wibox.container.margin(_, 4, 4, 3, 3)
                },
                bg = beautiful.bg_reset,
                shape = gears.shape.rectangle,
                widget = wibox.container.background
            },
            {
                {
                    widget = wibox.widget.imagebox(beautiful.spr)
                },
                layout = wibox.container.margin(_, _, _, _, _)
            },
            {
                {
                    {
                        widget = wibox.widget.imagebox(icons.next)
                    },
                    layout = wibox.container.margin(_, 4, 4, 3, 3)
                },
                bg = beautiful.bg_reset,
                shape = gears.shape.rectangle,
                widget = wibox.container.background
            },
            layout = wibox.layout.fixed.horizontal
        }
    )

    -- methods
    local function set_song_text(state, text, index)
        local function _set(color, text)
            local song_widget_container = spotify:get_children()[1]
            local song_text_widget_container = song_widget_container:get_children()[1]:get_children()[2]:get_children()[1]
            local song_text_widget = song_text_widget_container:get_children()[1]
            song_text_widget:set_markup(string.format("<span foreground='%s'>%s</span>", color, text))
        end

        if string.find(text, "Spotify is not running") ~= nil then
            _set(beautiful.fg_urgent, "Spotify")
        elseif string.find(text, "xesam:artist") ~= nil then
            _set(beautiful.fg_normal, "N/A")
        else
            local color = (state == 1) and beautiful.fg_focus or beautiful.fg_normal
            _set(color, string.format("%s%s", text:sub(index, text:len()), text:sub(1, index - 1)))
        end
    end

    local function update()
        awful.spawn.easy_async(
            "sp current-oneline",
            function(stdout, _, _, _)
                local text = string.format("   %s   ", stdout:sub(1, stdout:len() - 1))
                if song_text ~= text then
                    song_index = 1
                    song_text = text
                end
                set_song_text(song_state, song_text, song_index)
            end
        )

        awful.spawn.easy_async(
            "sp status",
            function(stdout, _, _, _)
                local function _set_play_pause_icon(icon)
                    local play_pause_icon_widget_container = spotify:get_children()[5]
                    local play_pause_icon_widget = play_pause_icon_widget_container:get_children()[1]:get_children()[1]
                    play_pause_icon_widget.image = icon
                end

                if stdout:gsub("\n", "") == "Playing" then
                    if song_state ~= 1 then
                        song_state = 1
                        _set_play_pause_icon(icons.pause)
                    end
                else
                    if song_state ~= 0 then
                        song_state = 0
                        _set_play_pause_icon(icons.play)
                    end
                end
            end
        )
    end

    function spotify:next()
        awful.spawn.easy_async(
            "sp next",
            function(_, _, _, _)
                update()
            end
        )
    end

    function spotify:pause()
        awful.spawn.easy_async(
            "sp pause",
            function(_, _, _, _)
                update()
            end
        )
    end

    function spotify:play()
        awful.spawn.easy_async(
            "sp play",
            function(_, _, _, _)
                update()
            end
        )
    end

    function spotify:play_pause()
        self:play()
    end

    function spotify:previous()
        awful.spawn.easy_async(
            "sp prev",
            function(_, _, _, _)
                update()
            end
        )
    end

    -- bindings
    local next_icon_widget_container = spotify:get_children()[7]
    next_icon_widget_container:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                _,
                function()
                    spotify:next()
                end
            )
        )
    )

    local play_pause_icon_widget_container = spotify:get_children()[5]
    play_pause_icon_widget_container:buttons(
            gears.table.join(
            awful.button(
                {},
                1,
                _,
                function()
                    spotify:play_pause()
                end
            )
        )
    )

    local prev_icon_widget_container = spotify:get_children()[3]
    prev_icon_widget_container:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                _,
                function()
                    spotify:previous()
                end
            )
        )
    )

    local song_widget_container = spotify:get_children()[1]
    local song_text_widget_container = song_widget_container:get_children()[1]:get_children()[2]:get_children()[1]
    local song_text_widget = song_text_widget_container:get_children()[1]
    song_text_widget:buttons(
        gears.table.join(
            awful.button(
                {},
                4,
                _,
                function()
                    if song_state == 1 then
                        song_index = song_index + 1
                        if song_index > song_text:len() then
                            song_index = 1
                        end
                        set_song_text(song_state, song_text, song_index)
                    end
                end
            ),

            awful.button(
                {},
                5,
                _,
                function()
                    if song_state == 1 then
                        song_index = song_index - 1
                        if song_index <= 0 then
                            song_index = song_text:len()
                        end
                        set_song_text(song_state, song_text, song_index)
                    end
                end
            )
        )
    )

    song_widget_container:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                _,
                function()
                    if string.find(song_text, "Spotify is not running") ~= nil then
                        awful.spawn.easy_async(
                            "spotify",
                            function(_, _, _, _)
                            end
                        )
                    end
                end
            )
        )
    )

    -- signals
    next_icon_widget_container:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )
    next_icon_widget_container:connect_signal(
        "mouse::leave",
        function(c)
            c:set_bg(beautiful.bg_reset)
        end
    )

    play_pause_icon_widget_container:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )
    play_pause_icon_widget_container:connect_signal(
        "mouse::leave",
        function(c)
            c:set_bg(beautiful.bg_reset)
        end
    )

    prev_icon_widget_container:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )
    prev_icon_widget_container:connect_signal(
        "mouse::leave",
        function(c)
            c:set_bg(beautiful.bg_reset)
        end
    )

    song_widget_container:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )
    song_widget_container:connect_signal(
        "mouse::leave",
        function(c)
            c:set_bg(beautiful.bg_reset)
        end
    )

    -- timers
    gears_timer(
        {
            timeout = 1,
            autostart = true,
            call_now = true,
            callback =
                function()
                    -- update song index if playing
                    if song_state == 1 then
                        song_index = song_index + 1
                        if song_index > song_text:len() then
                            song_index = 1
                        end
                    else
                        song_index = 1
                    end

                    -- call update method
                    update()
                end
        }
    )

    return spotify
end
-- }}}

return factory
