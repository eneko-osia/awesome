-- {{{ Standard libraries
local awful     = require("awful")
local beautiful = require("beautiful")
local calendar  = require("calendar")
local dpi       = require("beautiful.xresources").apply_dpi
local gears     = require("gears")
local wibox     = require("wibox")
-- }}}

-- {{{ Factory
local function factory(args)
    local args = args or {}

    local icons = args.icons or {
        logo = nil
    }

    local clock = {
        widget = wibox.widget({
            {
                {
                    {
                        widget = wibox.widget.imagebox(icons.logo)
                    },
                    layout = wibox.container.margin(_, _, 2, _, _)
                },
                {
                    {
                        {
                            align  = "center",
                            forced_width = dpi(128),
                            text = "N/A",
                            valign = "center",
                            widget = wibox.widget.textclock(" %a %d %b %H:%M:%S ", 1)
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

    -- Calendar widget
    local text_widget_container = clock.widget:get_children()[1]:get_children()[2]:get_children()[1]
    local text_widget = text_widget_container:get_children()[1]
    calendar({}):attach(text_widget)

    return clock
end
-- }}}

return factory
