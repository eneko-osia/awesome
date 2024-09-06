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
            border_width = beautiful_dpi(2),
            offset = { y = beautiful_dpi(2) },
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
                        id = "icon",
                        widget = wibox.widget.imagebox(icons.logo)
                    },
                    layout = wibox.container.margin(_, _, _, _, _)
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
    local function update_popup()
        local cpu_rows =
        {
            layout = wibox.layout.fixed.vertical,
            spacing = beautiful_dpi(5)
        }
        for k, v in pairs(cpu_info) do
            if k ~= 0 then
                local cpu_row = wibox.widget(
                    {
                        {
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
                                    shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(5)) end,
                                    widget = wibox.container.background
                                },
                                layout = wibox.container.margin(_, beautiful_dpi(3), beautiful_dpi(3), _, _)
                            },
                            {
                                {
                                    {
                                        align  = "center",
                                        forced_height = beautiful_dpi(20),
                                        forced_width = beautiful_dpi(36),
                                        text = string.format("%s%%", math.ceil(math.abs((v.active_delta / v.total_delta) * 100))),
                                        valign = "center",
                                        widget = wibox.widget.textbox
                                    },
                                    bg = beautiful.bg_focus,
                                    shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(5)) end,
                                    widget = wibox.container.background
                                },
                                layout = wibox.container.margin(_, _, beautiful_dpi(3), _, _)
                            },
                            {
                                {
                                    {
                                        background_color = beautiful.bg_focus,
                                        color = string.format("linear:0,0:150,0:0,%s:0.5,%s:1,%s", "#00FF00", "#FFFF00", "#FF0000"),
                                        forced_height = beautiful_dpi(20),
                                        forced_width = beautiful_dpi(150),
                                        margins = beautiful_dpi(1),
                                        max_value = v.total_delta,
                                        paddings = beautiful_dpi(6),
                                        value = v.active_delta,
                                        widget = wibox.widget.progressbar
                                    },
                                    bg = beautiful.bg_focus,
                                    shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(5)) end,
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
                        layout = wibox.container.margin(_, beautiful_dpi(5), beautiful_dpi(5), beautiful_dpi(5), beautiful_dpi(5))
                    },
                    layout = wibox.layout.fixed.horizontal
                },
                bg = beautiful.bg_reset,
                shape = gears.shape.rectangle,
                widget = wibox.container.background
            }
        )
    end

    local function update_widget()
        local text_widget = cpu:get_children_by_id("text")[1]
        text_widget:set_markup(string.format(" %s%% ", math.ceil(math.abs((cpu_info[0].active_delta / cpu_info[0].total_delta) * 100))))
    end

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
                    cpu_info[i] =
                        {
                            active_delta = active - prev_info.prev_active,
                            name = name:gsub("cpu", ""),
                            prev_active = active,
                            prev_total = total,
                            total_delta = total - prev_info.prev_total
                        }
                    i = i + 1
                end

                if popup.visible then
                    update_popup()
                end
                update_widget()
            end
        )
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

        update_popup()
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
