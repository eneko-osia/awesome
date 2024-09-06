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
    local args = args or {}

    local device_index = -1
    local device_type = args.device_type or "sink"
    local icons = args.icons or
        {
            high = nil,
            low = nil,
            medium = nil,
            muted = nil
        }

    local volume = wibox.widget(
        {
            {
                {
                    {
                        id = "icon",
                        widget = wibox.widget.imagebox(icons.muted)
                    },
                    layout = wibox.container.margin(_, 4, 4, 3, 3)
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
        }
    )

    -- methods
    local function update()
        awful.spawn.easy_async_with_shell(
            string.format("pacmd list-%ss | sed -n -e '/*/,$!d' -e '/index/p' -e '/volume:/p' -e '/muted:/p'", device_type),
            function(stdout, _, _, _)
                device_index = tonumber(string.match(stdout, "index: (%S+)")) or nil
                local muted = string.match(stdout, "muted: (%S+)") or "yes"
                local vol = tonumber(string.match(stdout, ":.-(%d+)%%")) or 0

                local icon_widget = volume:get_children_by_id("icon")[1]
                local text_widget = volume:get_children_by_id("text")[1]
                if muted == "yes" then
                    icon_widget:set_image(icons.muted)
                    text_widget:set_markup(string.format(" <s>%d%%</s> ", vol))
                else
                    if vol == 0 then
                        icon_widget:set_image(icons.muted)
                    elseif vol > 70 then
                        icon_widget:set_image(icons.high)
                    elseif vol > 30 then
                        icon_widget:set_image(icons.medium)
                    else
                        icon_widget:set_image(icons.low)
                    end
                    text_widget:set_markup(string.format(" %d%% ", vol))
                end
            end
        )
    end

    function volume:down()
        if device_index ~= nil then
            awful.spawn.easy_async(
                string.format("pactl set-%s-volume %d -1%%", device_type, device_index),
                function(_, _, _, _)
                    update()
                end
            )
        end
    end

    function volume:mute()
        if device_index ~= nil then
            awful.spawn.easy_async(
                string.format("pactl set-%s-mute %d toggle", device_type, device_index),
                function(_, _, _, _)
                    update()
                end
            )
        end
    end

    function volume:set(value)
        if device_index ~= nil then
            awful.spawn.easy_async(
                string.format("pactl set-%s-volume %d %d%%", device_type, device_index, value),
                function(_, _, _, _)
                    update()
                end
            )
        end
    end

    function volume:up()
        if device_index ~= nil then
            awful.spawn.easy_async(
                string.format("pactl set-%s-volume %d +1%%", device_type, device_index),
                function(_, _, _, _)
                    update()
                end
            )
        end
    end

    -- bindings
    volume:buttons(
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
                    volume:mute()
                end
            ),

            awful.button(
                {},
                3,
                _,
                function()
                    volume:set(100)
                end
            ),

            awful.button(
                {},
                4,
                _,
                function()
                    volume:up()
                end
            ),

            awful.button(
                {},
                5,
                _,
                function()
                    volume:down()
                end
            )
        )
    )

    -- signals
    volume:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )
    volume:connect_signal(
        "mouse::leave",
        function(c)
            c:set_bg(beautiful.bg_reset)
        end
    )

    -- timers
    gears_timer(
        {
            timeout = 5,
            autostart = true,
            call_now = true,
            callback = update
        }
    )

    return volume
end
-- }}}

return factory
