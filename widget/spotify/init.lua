-- {{{ Standard libraries
local awful     = require("awful")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi
local gears     = require("gears")
local watch     = require("awful.widget.watch")
local wibox     = require("wibox")
-- }}}

-- {{{ Factory
local function factory(args)
    args = args or {}

    local icons = args.icons or {
        logo = nil,
        next = nil,
        pause = nil,
        play = nil,
        prev = nil
    }
    local song = "Spotify"
    local song_index = 0
    local song_state = 0

    local spotify = {
        widget = wibox.widget({
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
                                    forced_width = dpi(256),
                                    text = song,
                                    valign = "center",
                                    widget = wibox.widget.textbox
                                },
                                bg = beautiful.bg_focus,
                                shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 2) end,
                                widget = wibox.container.background,
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
                    widget = wibox.container.background,
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
                    widget = wibox.container.background,
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
                    widget = wibox.container.background,
                },
                layout = wibox.layout.fixed.horizontal
            },
            bg = beautiful.bg_reset,
            shape = gears.shape.rectangle,
            widget = wibox.container.background
        })
    }

    -- methods
    function spotify:next()
        awful.spawn.easy_async("sp next",
            function(stdout, stderr, exitreason, exitcode)
            end
        )
    end

    function spotify:pause()
        awful.spawn.easy_async("sp pause",
            function(stdout, stderr, exitreason, exitcode)
            end
        )
    end

    function spotify:play()
        awful.spawn.easy_async("sp play",
            function(stdout, stderr, exitreason, exitcode)
            end
        )
    end

    function spotify:play_pause()
        self:play()
    end

    function spotify:previous()
        awful.spawn.easy_async("sp prev",
            function(stdout, stderr, exitreason, exitcode)
            end
        )
    end

    local function set_song(widget, text)
        if string.find(text, "Error: Spotify is not running.") ~= nil then
            widget:set_markup(
                "<span foreground='" .. beautiful.fg_urgent .. "'> Spotify </span>"
            )
        else
            local song_color = (song_state == 1) and beautiful.fg_focus or beautiful.fg_normal
            widget:set_markup(
                "<span foreground='" .. song_color .. "'>" ..  song:sub(song_index, song:len()) .. song:sub(1, song_index - 1) .. "</span>"
            )
        end
    end

    local function update_play_pause_icon(widget, state)
        if (state:gsub("\n", "") == "Playing") then
            song_state = 1
            widget.image = icons.pause
        else
            song_state = 0
            widget.image = icons.play
        end
    end

    local function update_song(widget, text)
        if (song ~= text) then
            song = text
            song_index = 1
        else
            if (song_state == 1) then
                song_index = song_index + 1
                if (song_index > song:len()) then
                    song_index = 1
                end
            else
                song_index = 1
            end
        end

        set_song(widget, song)
    end

    -- bindings
    local next_icon_widget_container = spotify.widget:get_children()[1]:get_children()[7]
    next_icon_widget_container:buttons(gears.table.join(
        awful.button(
            {},
            1,
            function()
                spotify:next()
            end
        )
    ))

    local play_pause_icon_widget_container = spotify.widget:get_children()[1]:get_children()[5]
    play_pause_icon_widget_container:buttons(gears.table.join(
        awful.button(
            {},
            1,
            function()
                spotify:play_pause()
            end
        )
    ))

    local prev_icon_widget_container = spotify.widget:get_children()[1]:get_children()[3]
    prev_icon_widget_container:buttons(gears.table.join(
        awful.button(
            {},
            1,
            function()
                spotify:previous()
            end
        )
    ))

    local song_text_widget_container = spotify.widget:get_children()[1]:get_children()[1]:get_children()[1]:get_children()[2]:get_children()[1]
    local song_text_widget = song_text_widget_container:get_children()[1]
    song_text_widget:buttons(gears.table.join(
        awful.button(
            {},
            4,
            function()
                if (song_state == 1) then
                    song_index = song_index + 1
                    if (song_index > song:len()) then
                        song_index = 1
                    end
                    set_song(song_text_widget, song)
                end
            end
        ),

        awful.button(
            { },
            5,
            function()
                if (song_state == 1) then
                    song_index = song_index - 1
                    if (song_index <= 0) then
                        song_index = song:len()
                    end
                    set_song(song_text_widget, song)
                end
            end
        )
    ))

    local spotify_widget_container = spotify.widget:get_children()[1]:get_children()[1]
    spotify_widget_container:buttons(gears.table.join(
        awful.button(
            {},
            1,
            function()
                if string.find(song, "Error: Spotify is not running.") ~= nil then
                    awful.spawn.easy_async(
                        "spotify",
                        function(stdout)
                        end
                    )
                end
            end
        )
    ))

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

    local play_pause_icon_widget = play_pause_icon_widget_container:get_children()[1]:get_children()[1]
    play_pause_icon_widget_container:connect_signal(
        "button::press",
        function()
            awful.spawn.easy_async(
                "sp status",
                function(stdout)
                    update_play_pause_icon(play_pause_icon_widget, stdout)
                end
            )
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

    spotify_widget_container:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )
    spotify_widget_container:connect_signal(
        "mouse::leave",
        function(c)
            c:set_bg(beautiful.bg_reset)
        end
    )

    -- watches
    watch(
        "sp current-oneline",
        1,
        function (widget, stdout)
            update_song(widget, "   " .. stdout:sub(1, stdout:len() - 1) .. "   ")
        end,
        song_text_widget
    )

    watch(
        "sp status",
        1,
        function (widget, stdout)
            update_play_pause_icon(widget, stdout)
        end,
        play_pause_icon_widget
    )

    return spotify
end
-- }}}

return factory
