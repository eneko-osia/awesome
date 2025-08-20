-- {{{ Standard libraries
local awful         = require("awful")
local beautiful     = require("beautiful")
local beautiful_dpi = require("beautiful.xresources").apply_dpi
local gears         = require("gears")
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
    local music_player = args.music_player or "Feishin"
    local music_player_launcher = args.music_player_launcher or "feishin"
    local song_index = 0
    local song_state = 0
    local song_text = music_player
    local widget = wibox.widget(
        {
            {
                {
                    {
                        {
                            id = "song_icon",
                            widget = wibox.widget.imagebox(icons.logo)
                        },
                        layout = wibox.container.margin(_, beautiful_dpi(4), beautiful_dpi(1), beautiful_dpi(3), beautiful_dpi(3))
                    },
                    {
                        {
                            {
                                align  = "center",
                                forced_width = beautiful_dpi(256),
                                id = "song_text",
                                text = song_text,
                                valign = "center",
                                widget = wibox.widget.textbox
                            },
                            bg = beautiful.bg_focus,
                            shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(2)) end,
                            widget = wibox.container.background
                        },
                        layout = wibox.container.margin(_, beautiful_dpi(3), beautiful_dpi(3), beautiful_dpi(3), beautiful_dpi(3))
                    },
                    layout = wibox.layout.fixed.horizontal
                },
                bg = beautiful.bg_reset,
                id = "song_container",
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
                        id = "prev_icon",
                        widget = wibox.widget.imagebox(icons.prev)
                    },
                    layout = wibox.container.margin(_, beautiful_dpi(4), beautiful_dpi(4), beautiful_dpi(3), beautiful_dpi(3))
                },
                bg = beautiful.bg_reset,
                id = "prev_icon_container",
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
                        id = "play_pause_icon",
                        widget = wibox.widget.imagebox(icons.play)
                    },
                    layout = wibox.container.margin(_, beautiful_dpi(4), beautiful_dpi(4), beautiful_dpi(3), beautiful_dpi(3))
                },
                bg = beautiful.bg_reset,
                id = "play_pause_icon_container",
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
                        id = "next_icon",
                        widget = wibox.widget.imagebox(icons.next)
                    },
                    layout = wibox.container.margin(_, beautiful_dpi(4), beautiful_dpi(4), beautiful_dpi(3), beautiful_dpi(3))
                },
                bg = beautiful.bg_reset,
                id = "next_icon_container",
                shape = gears.shape.rectangle,
                widget = wibox.container.background
            },
            layout = wibox.layout.fixed.horizontal
        }
    )

    -- methods
    local function set_song_text(state, text, index)
        local function _set(color, text)
            local song_text_widget = widget:get_children_by_id("song_text")[1]
            song_text_widget:set_markup(string.format("<span foreground='%s'>%s</span>", color, text))
        end

        if string.match(text, "No players found") then
            _set(beautiful.fg_urgent, music_player)
        elseif string.match(text, "No player could handle this command") then
            _set(beautiful.fg_normal, "N/A")
        else
            local color = (state == 1) and beautiful.fg_focus or beautiful.fg_normal
            _set(color, string.format("%s%s", string.sub(text, index, string.len(text)), string.sub(text, 1, index - 1)))
        end
    end

    local function update()
        -- update current song text
        awful.spawn.easy_async(
            string.format("playerctl metadata --player=%s", music_player),
            function(stdout, stderr, _, _)
                local stdout_text = ""
                if stderr ~= "" then
                    stdout_text = stderr
                else
                    for line in stdout:gmatch("[^\r\n]+") do
                        local player, key, value = string.match(line, "^(%S+)%s+(%S+)%s+(.+)$")
                        if string.match(key, "xesam:albumArtist") then
                            stdout_text = value
                        elseif string.match(key, "xesam:title") then
                            stdout_text = string.format("   %s / %s   ", stdout_text, value)
                        end
                    end
                end

                if song_text ~= stdout_text then
                    song_index = 1
                    song_text = stdout_text
                end
                set_song_text(song_state, song_text, song_index)
            end
        )

        -- update current song play state
        awful.spawn.easy_async(
            string.format("playerctl status --player=%s", music_player),
            function(stdout, _, _, _)
                local function _set_play_pause_icon(icon)
                    local play_pause_icon_widget = widget:get_children_by_id("play_pause_icon")[1]
                    play_pause_icon_widget.image = icon
                end

                if string.match(stdout, "Playing") then
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

    function widget:next()
        awful.spawn.easy_async(
            string.format("playerctl next --player=%s", music_player),
            function(_, _, _, _)
                update()
            end
        )
    end

    function widget:pause()
        awful.spawn.easy_async(
            string.format("playerctl pause --player=%s", music_player),
            function(_, _, _, _)
                update()
            end
        )
    end

    function widget:play()
        awful.spawn.easy_async(
            string.format("playerctl play --player=%s", music_player),
            function(_, _, _, _)
                update()
            end
        )
    end

    function widget:play_pause()
        awful.spawn.easy_async(
            string.format("playerctl play-pause --player=%s", music_player),
            function(_, _, _, _)
                update()
            end
        )
    end

    function widget:previous()
        awful.spawn.easy_async(
            string.format("playerctl previous --player=%s", music_player),
            function(_, _, _, _)
                update()
            end
        )
    end

    -- bindings
    local next_icon_widget_container = widget:get_children_by_id("next_icon_container")[1]
    next_icon_widget_container:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                _,
                function()
                    widget:next()
                end
            )
        )
    )

    local play_pause_icon_widget_container = widget:get_children_by_id("play_pause_icon_container")[1]
    play_pause_icon_widget_container:buttons(
            gears.table.join(
            awful.button(
                {},
                1,
                _,
                function()
                    widget:play_pause()
                end
            )
        )
    )

    local prev_icon_widget_container = widget:get_children_by_id("prev_icon_container")[1]
    prev_icon_widget_container:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                _,
                function()
                    widget:previous()
                end
            )
        )
    )

    local song_text_widget = widget:get_children_by_id("song_text")[1]
    song_text_widget:buttons(
        gears.table.join(
            awful.button(
                {},
                4,
                _,
                function()
                    if song_state == 1 then
                        song_index = song_index + 1
                        if song_index > string.len(song_text) then
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
                            song_index = string.len(song_text)
                        end
                        set_song_text(song_state, song_text, song_index)
                    end
                end
            )
        )
    )

    local song_widget_container = widget:get_children_by_id("song_container")[1]
    song_widget_container:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                _,
                function()
                    if string.match(song_text, "No players found") then
                        awful.spawn.easy_async(
                            music_player_launcher,
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
        "button::press",
        function(c)
            c:set_bg(beautiful.bg_focus)
        end
    )

    next_icon_widget_container:connect_signal(
        "button::release",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )

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
        "button::press",
        function(c)
            c:set_bg(beautiful.bg_focus)
        end
    )

    play_pause_icon_widget_container:connect_signal(
        "button::release",
        function(c)
            c:set_bg(beautiful.bg_normal)
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
        "button::press",
        function(c)
            c:set_bg(beautiful.bg_focus)
        end
    )

    prev_icon_widget_container:connect_signal(
        "button::release",
        function(c)
            c:set_bg(beautiful.bg_normal)
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
        "button::press",
        function(c)
            c:set_bg(beautiful.bg_focus)
        end
    )

    song_widget_container:connect_signal(
        "button::release",
        function(c)
            c:set_bg(beautiful.bg_normal)
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
    gears.timer(
        {
            autostart = true,
            call_now = true,
            callback =
                function()
                    -- update song index if playing
                    if song_state == 1 then
                        song_index = song_index + 1
                        if song_index > string.len(song_text) then
                            song_index = 1
                        end
                    else
                        song_index = 1
                    end

                    -- call update method
                    update()
                end,
            timeout = 1
        }
    )

    return widget
end
-- }}}

return factory
