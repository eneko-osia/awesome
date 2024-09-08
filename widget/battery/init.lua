-- {{{ Standard libraries
local awful     = require("awful")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi
local gears     = require("gears")
local naughty   = require("naughty")
local lain      = require("lain")
local wibox     = require("wibox")
-- }}}

-- {{{ Factory
local function factory(args)
    args = args or {}

    local icons = args.icons or {
        ac = nil,
        empty = nil,
        full = nil,
        logo = nil,
        low = nil
    }
    local notification = nil
    local notification_text = "N/A"
    local widget_battery = wibox.widget({
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
        }
    )

    -- lain widget creation
    local lain_battery = lain.widget.bat({
        notify = "on",
        full_notify = "on",
        settings = function()
            local icon_widget_container = widget:get_children()[1]:get_children()[1]
            local icon_widget = icon_widget_container:get_children()[1]
            local text_widget_container = widget:get_children()[1]:get_children()[2]:get_children()[1]
            local text_widget = text_widget_container:get_children()[1]
            if (icon_widget ~= nil and text_widget ~= nil) then
                if bat_now.ac_status == "N/A" or bat_now.ac_status == 1 then
                    icon_widget:set_image(icons.ac)
                    if bat_now.perc ~= "N/A" then
                        notification_text = " " .. bat_now.time .. " "
                        text_widget:set_markup(" " .. bat_now.perc .. "%" .. " ")
                    else
                        notification_text = " " .. bat_now.time .. " "
                        text_widget:set_markup(" 100% ")
                    end
                elseif bat_now.perc ~= "N/A" then
                    local bat_perc_number = tonumber(bat_now.perc)
                    if bat_now.ac_status == 1 or bat_perc_number == 100 then
                        icon_widget:set_image(icons.ac)
                        notification_text = " " .. bat_now.time .. " "
                        text_widget:set_markup(" " .. bat_now.perc .. "%" .. " ")
                    elseif bat_perc_number > 50 then
                        icon_widget:set_image(icons.full)
                        notification_text = " " .. bat_now.time .. " "
                        text_widget:set_markup(" " .. bat_now.perc .. "%" .. " ")
                    elseif bat_perc_number > 15 then
                        icon_widget:set_image(icons.low)
                        notification_text = " " .. bat_now.time .. " "
                        text_widget:set_markup(lain.util.markup(beautiful.fg_focus, " " .. bat_now.perc .. "%" .. " "))
                    else
                        icon_widget:set_image(icons.empty)
                        notification_text = " " .. bat_now.time .. " "
                        text_widget:set_markup(lain.util.markup(beautiful.fg_urgent, " " .. bat_now.perc .. "%" .. " "))
                    end
                else
                    icon_widget:set_image(icons.empty)
                    notification_text = " " .. bat_now.time .. " "
                    text_widget:set_markup(lain.util.markup(beautiful.fg_urgent, " " .. bat_now.perc .. "%" .. " "))
                end
            end
        end,
        widget = widget_battery
    })

    -- signals
    widget_battery:connect_signal(
        'mouse::enter',
        function()
            naughty.destroy(notification)
            notification = naughty.notify(
                {
                    title = "Battery time",
                    text = notification_text
                })
        end
    )
    widget_battery:connect_signal(
        'mouse::leave',
        function()
            naughty.destroy(notification)
            notification = nil
        end
    )

    return widget_battery
end
-- }}}

return factory
