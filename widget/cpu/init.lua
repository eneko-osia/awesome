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

    local cpu_info = {}
    local icons = args.icons or
        {
            logo = nil
        }
    local popup = awful.popup(
        {
            border_color = beautiful.bg_focus,
            border_width = 2,
            offset = { y = 2 },
            ontop = true,
            shape = gears.shape.rounded_rect,
            visible = false,
            widget = {}
        }
    )
    local terminal = args.terminal or "xterm"

    local cpu = wibox.widget(
        {
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
                            forced_width = beautiful_dpi(36),
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
        awful.spawn.easy_async(
            string.format("grep '^cpu.' /proc/stat"),
            function(stdout, _, _, _)
                local i = 0
                for cpu_line in stdout:gmatch("[^\r\n]+") do
                    local name, user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice = cpu_line:match('(%w+)%s+(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)')
                    local total = user + nice + system + idle + iowait + irq + softirq + steal
                    local active = total - (idle + iowait)

                    local prev_info = cpu_info[i] or
                        {
                            prev_active = 0,
                            prev_total = 0
                        }
                    local total_delta = total - prev_info.prev_total
                    local active_delta = active - prev_info.prev_active
                    local usage = math.ceil(math.abs((active_delta / total_delta) * 100))
                    cpu_info[i] =
                        {
                            name = name:gsub("cpu", ""),
                            prev_active = active,
                            prev_total = total,
                            usage = usage
                        }
                    i = i + 1
                end
            end
        )

        if cpu_info[0] then
            -- popup definition
            local cpu_rows =
            {
                layout = wibox.layout.fixed.vertical,
                spacing = 8
            }
            for k, v in pairs(cpu_info) do
                if k ~= 0 then
                    local cpu_row = wibox.widget(
                        {
                            {
                                {
                                    {
                                        resize = false,
                                        widget = wibox.widget.imagebox(icons.logo)
                                    },
                                    layout = wibox.container.margin(_, _, _, _, _)
                                },
                                {
                                    {
                                        {
                                            align  = "center",
                                            forced_height = beautiful_dpi(20),
                                            forced_width = beautiful_dpi(24),
                                            text = string.format("%s", v.name),
                                            valign = "center",
                                            widget = wibox.widget.textbox
                                        },
                                        bg = beautiful.bg_focus,
                                        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 2) end,
                                        widget = wibox.container.background
                                    },
                                    layout = wibox.container.margin(_, _, 4, _, _)
                                },
                                -- {
                                --     {
                                --         {
                                --             align  = "center",
                                --             forced_height = beautiful_dpi(20),
                                --             forced_width = beautiful_dpi(36),
                                --             text = string.format("%s%%", v.usage),
                                --             valign = "center",
                                --             widget = wibox.widget.textbox
                                --         },
                                --         bg = beautiful.bg_focus,
                                --         shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 2) end,
                                --         widget = wibox.container.background
                                --     },
                                --     layout = wibox.container.margin(_, _, 4, _, _)
                                -- },
                                {
                                    {
                                        {
                                            background_color = beautiful.bg_focus,
                                            color = string.format("linear:0,0:150,0:0,%s:0.5,%s:1,%s", "#00FF00", "#FFFF00", "#FF0000"),
                                            forced_height = beautiful_dpi(20),
                                            forced_width = beautiful_dpi(150),
                                            margins = 1,
                                            max_value = 100,
                                            paddings = 6,
                                            value = v.usage,
                                            widget = wibox.widget.progressbar
                                        },
                                        bg = beautiful.bg_focus,
                                        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 2) end,
                                        widget = wibox.container.background
                                    },
                                    layout = wibox.container.margin(_, _, _, _, _)
                                },
                                layout = wibox.layout.fixed.horizontal
                            },
                            bg = beautiful.bg_reset,
                            shape = gears.shape.rectangle,
                            widget = wibox.container.background
                        }
                    )
                    table.insert(cpu_rows, cpu_row)
                end
            end

            -- popup setup
            popup:setup(
                {
                    {
                        {
                            cpu_rows,
                            layout = wibox.container.margin(_, 10, 10, 10, 10)
                        },
                        layout = wibox.layout.fixed.horizontal
                    },
                    bg = beautiful.bg_reset,
                    shape = gears.shape.rectangle,
                    widget = wibox.container.background
                }
            )

            -- widget
            local text_widget_container = cpu:get_children()[1]:get_children()[2]:get_children()[1]
            local text_widget = text_widget_container:get_children()[1]
            if text_widget ~= nil then
                text_widget:set_markup(string.format(" %s%% ", cpu_info[0].usage))
            end
        end
    end

    -- bindings
    cpu:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                _,
                function()
                    awful.spawn.easy_async(
                        string.format("%s -e htop", terminal),
                        function(stdout)
                        end
                    )
                end
            )
        )
    )

    -- signals
    cpu:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)
            popup:move_next_to(mouse.current_widget_geometry)
            popup.visible = true
        end
    )
    cpu:connect_signal(
        "mouse::leave",
        function(c)
            popup.visible = false
            c:set_bg(beautiful.bg_reset)
        end
    )

    -- timers
    gears_timer(
        {
            timeout = 2,
            autostart = true,
            call_now = true,
            callback = update
        }
    )

    return cpu
end
-- }}}

return factory
