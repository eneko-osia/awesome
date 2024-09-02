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

    local icons = args.icons or {
        logo = nil
    }
    local terminal = args.terminal or "xterm"

    local cpu = {
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
    local lain_cpu = lain.widget.cpu({
        settings =
            function()
                local text_widget_container = widget:get_children()[1]:get_children()[2]:get_children()[1]
                local text_widget = text_widget_container:get_children()[1]
                if (text_widget ~= nil) then
                    text_widget:set_markup(" " .. cpu_now.usage .. "%" .. " ")
                end
            end,
        widget = cpu.widget
    })

    -- bindings

    cpu.widget:buttons(gears.table.join(
        awful.button(
            {},
            1,
            function()
                awful.spawn.easy_async(
                    terminal .." -e htop",
                    function(stdout)
                    end
                )
            end
        )
    ))

    -- signals
    cpu.widget:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )
    cpu.widget:connect_signal(
        "mouse::leave",
        function(c)
            c:set_bg(beautiful.bg_reset)
        end
    )

    return cpu
end
-- }}}

return factory
