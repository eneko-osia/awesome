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

    local device_type = args.device_type or "sink"
    local device_id = string.format("@DEFAULT_%s@", string.upper(device_type))
    local icons = args.icons or
        {
            high = nil,
            low = nil,
            medium = nil,
            muted = nil
        }
    local info = {}
    local timeout = args.timeout or 2
    local widget = wibox.widget(
        {
            {
                {
                    {
                        id = "icon",
                        widget = wibox.widget.imagebox(icons.muted)
                    },
                    id = "icon_container",
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
                        id = "text_container",
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
        local icon_widget = widget:get_children_by_id("icon")[1]
        local text_widget = widget:get_children_by_id("text")[1]
        if info.muted then
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
            string.format("pactl get-%s-volume %s ; pactl get-%s-mute %s", device_type, device_id, device_type, device_id),
            function(stdout, _, _, _)
                info =
                    {
                        muted = string.match(stdout, "Mute: yes") or false,
                        volume = tonumber(string.match(stdout, ":.-(%d+)%%")) or 0
                    }
                update_widget()
            end
        )
    end

    function widget:down()
        awful.spawn.easy_async(
            string.format("pactl set-%s-volume %s -1%%", device_type, device_id),
            function(_, _, _, _)
                update()
            end
        )
    end

    function widget:mute()
        awful.spawn.easy_async(
            string.format("pactl set-%s-mute %s toggle", device_type, device_id),
            function(_, _, _, _)
                update()
            end
        )
    end

    function widget:set(value)
        awful.spawn.easy_async(
            string.format("pactl set-%s-volume %s %d%%", device_type, device_id, value),
            function(_, _, _, _)
                update()
            end
        )
    end

    function widget:up()
        awful.spawn.easy_async(
            string.format("pactl set-%s-volume %s +1%%", device_type, device_id),
            function(_, _, _, _)
                update()
            end
        )
    end

    -- bindings
    widget:buttons(
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
                    widget:mute()
                end
            ),

            awful.button(
                {},
                3,
                _,
                function()
                    widget:set(100)
                end
            ),

            awful.button(
                {},
                4,
                _,
                function()
                    widget:up()
                end
            ),

            awful.button(
                {},
                5,
                _,
                function()
                    widget:down()
                end
            )
        )
    )

    -- signals
    widget:connect_signal(
        "button::press",
        function(c)
            c:set_bg(beautiful.bg_focus)
        end
    )

    widget:connect_signal(
        "button::release",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )

    widget:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )

    widget:connect_signal(
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
            callback = update,
            timeout = timeout
        }
    )

    return widget
end
-- }}}

return factory
