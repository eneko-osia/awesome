-- {{{ Standard libraries
local awful     = require("awful")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi
local gears     = require("gears")
local lain      = require("lain")
local wibox     = require("wibox")
-- }}}

-- {{{ Factory
local function factory(args)
    local args = args or {}

    local device = args.device or nil
    local icons = args.icons or {
        high = nil,
        low = nil,
        medium = nil,
        muted = nil
    }

    local volume = {
        widget = wibox.widget({
            {
                {
                    {
                        widget = wibox.widget.imagebox(icons.muted)
                    },
                    layout = wibox.container.margin(_, 4, 4, 3, 3)
                },
                {
                    {
                        {
                            align  = "center",
                            forced_width = dpi(36),
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
        })
    }

    -- lain widget creation
    local pulse = lain.widget.pulse({
        devicetype = device,
        settings =
            function()
                local icon_widget_container = widget:get_children()[1]:get_children()[1]
                local icon_widget = icon_widget_container:get_children()[1]
                local text_widget_container = widget:get_children()[1]:get_children()[2]:get_children()[1]
                local text_widget = text_widget_container:get_children()[1]
                if (icon_widget ~= nil and text_widget ~= nil) then
                    if (volume_now.muted == "yes") then
                        icon_widget:set_image(icons.muted)
                        text_widget:set_markup(lain.util.markup.strike(" " .. volume_now.left .. "% "))
                    else
                        if (volume_now.left ~= "N/A") then
                            local volume_number = tonumber(volume_now.left)
                            if (volume_number > 70) then
                                icon_widget:set_image(icons.high)
                            elseif (volume_number > 30) then
                                icon_widget:set_image(icons.medium)
                            else
                                icon_widget:set_image(icons.low)
                            end
                        end
                        text_widget:set_markup(" " .. volume_now.left .. "% ")
                    end
                end
            end,
        widget = volume.widget
    })

    -- methods
    function volume:down()
        if pulse.device ~= nil then
            os.execute(string.format("pactl set-" .. device .. "-volume %d -1%%", pulse.device))
            pulse.update()
        end
    end

    function volume:mute()
        if pulse.device ~= nil then
            os.execute(string.format("pactl set-" .. device .. "-mute %d toggle", pulse.device))
            pulse.update()
        end
    end

    function volume:set(value)
        if pulse.device ~= nil then
            os.execute(string.format("pactl set-" .. device .. "-volume %d %d%%", pulse.device, value))
            pulse.update()
        end
    end

    function volume:up()
        if pulse.device ~= nil then
            os.execute(string.format("pactl set-" .. device .. "-volume %d +1%%", pulse.device))
            pulse.update()
        end
    end

    -- bindings
    volume.widget:buttons(gears.table.join(
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
            function() volume:mute() end
        ),

        awful.button(
            {},
            3,
            function() volume:set(100) end
        ),

        awful.button(
            {},
            4,
            function() volume:up() end
        ),

        awful.button(
            {},
            5,
            function() volume:down() end
        )
    ))

    -- signals
    volume.widget:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )
    volume.widget:connect_signal(
        "mouse::leave",
        function(c)
            c:set_bg(beautiful.bg_reset)
        end
    )

    return volume
end
-- }}}

return factory
