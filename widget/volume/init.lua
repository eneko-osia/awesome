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

    local device_type = args.device_type or "sink"
    local icons = args.icons or
        {
            high = nil,
            low = nil,
            medium = nil,
            muted = nil
        }
    local info = {}
    local timeout = args.timeout or 2
    local widget_volume = wibox.widget(
        {
            {
                {
                    {
                        id = "icon",
                        widget = wibox.widget.imagebox(icons.muted)
                    },
                    layout = wibox.container.margin(_, beautiful_dpi(4), beautiful_dpi(1), beautiful_dpi(3), beautiful_dpi(3))
                },
                {
                    {
                        {
                            align  = "center",
                            forced_width = beautiful_dpi(36),
                            id = "text",
                            text = "N/A",
                            valign = "center",
                            widget = wibox.widget.textbox
                        },
                        bg = beautiful.bg_focus,
                        shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(2)) end,
                        widget = wibox.container.background,
                    },
                    layout = wibox.container.margin(_, beautiful_dpi(3), beautiful_dpi(3), beautiful_dpi(3), beautiful_dpi(3))
                },
                layout = wibox.layout.fixed.horizontal
            },
            bg = beautiful.bg_reset,
            shape = gears.shape.rectangle,
            widget = wibox.container.background
        }
    )

    -- methods
    local function update_widget()
        local icon_widget = widget_volume:get_children_by_id("icon")[1]
        local text_widget = widget_volume:get_children_by_id("text")[1]
        if info.muted == "yes" then
            icon_widget:set_image(icons.muted)
            text_widget:set_markup(string.format(" <s>%d%%</s> ", info.volume))
        else
            if info.volume == 0 then
                icon_widget:set_image(icons.muted)
            elseif info.volume > 70 then
                icon_widget:set_image(icons.high)
            elseif info.volume > 30 then
                icon_widget:set_image(icons.medium)
            else
                icon_widget:set_image(icons.low)
            end
            text_widget:set_markup(string.format(" %d%% ", info.volume))
        end
    end

    local function update()
        awful.spawn.easy_async_with_shell(
            string.format("pacmd list-%ss | sed -n -e '/*/,$!d' -e '/index/p' -e '/volume:/p' -e '/muted:/p'", device_type),
            function(stdout, _, _, _)
                info =
                    {
                        index = tonumber(string.match(stdout, "index: (%S+)")) or nil,
                        muted = string.match(stdout, "muted: (%S+)") or "yes",
                        volume = tonumber(string.match(stdout, ":.-(%d+)%%")) or 0
                    }
                update_widget()
            end
        )
    end

    function widget_volume:down()
        if info.index ~= nil then
            awful.spawn.easy_async(
                string.format("pactl set-%s-volume %d -1%%", device_type, info.index),
                function(_, _, _, _)
                    update()
                end
            )
        end
    end

    function widget_volume:mute()
        if info.index ~= nil then
            awful.spawn.easy_async(
                string.format("pactl set-%s-mute %d toggle", device_type, info.index),
                function(_, _, _, _)
                    update()
                end
            )
        end
    end

    function widget_volume:set(value)
        if info.index ~= nil then
            awful.spawn.easy_async(
                string.format("pactl set-%s-volume %d %d%%", device_type, info.index, value),
                function(_, _, _, _)
                    update()
                end
            )
        end
    end

    function widget_volume:up()
        if info.index ~= nil then
            awful.spawn.easy_async(
                string.format("pactl set-%s-volume %d +1%%", device_type, info.index),
                function(_, _, _, _)
                    update()
                end
            )
        end
    end

    -- bindings
    widget_volume:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                _,
                function()
                    awful.spawn("pavucontrol")
                end
            ),

            awful.button(
                {},
                2,
                _,
                function()
                    widget_volume:mute()
                end
            ),

            awful.button(
                {},
                3,
                _,
                function()
                    widget_volume:set(100)
                end
            ),

            awful.button(
                {},
                4,
                _,
                function()
                    widget_volume:up()
                end
            ),

            awful.button(
                {},
                5,
                _,
                function()
                    widget_volume:down()
                end
            )
        )
    )

    -- signals
    widget_volume:connect_signal(
        "button::press",
        function(c)
            c:set_bg(beautiful.bg_focus)
        end
    )

    widget_volume:connect_signal(
        "button::release",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )

    widget_volume:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )

    widget_volume:connect_signal(
        "mouse::leave",
        function(c)
            c:set_bg(beautiful.bg_reset)
        end
    )

    -- timers
    gears_timer(
        {
            timeout = timeout,
            autostart = true,
            call_now = true,
            callback = update
        }
    )

    return widget_volume
end
-- }}}

return factory
