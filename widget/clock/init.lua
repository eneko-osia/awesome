-- {{{ Standard libraries
local awful         = require("awful")
local beautiful     = require("beautiful")
local beautiful_dpi = require("beautiful.xresources").apply_dpi
local calendar      = require("calendar")
local gears         = require("gears")
local wibox         = require("wibox")
-- }}}

-- {{{ Factory
local function factory(args)
    args = args or {}

    local icons = args.icons or
        {
            logo = nil
        }

    local clock = wibox.widget(
        {
            {
                {
                    {
                        widget = wibox.widget.imagebox(icons.logo)
                    },
                    layout = wibox.container.margin(_, _, _, _, _)
                },
                {
                    {
                        {
                            align  = "center",
                            forced_width = beautiful_dpi(128),
                            id = "text",
                            text = "N/A",
                            valign = "center",
                            widget = wibox.widget.textclock(" %a %d %b %H:%M:%S ", 1)
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

    -- Calendar widget
    calendar({}):attach(clock:get_children_by_id("text")[1])

    return clock
end
-- }}}

return factory
