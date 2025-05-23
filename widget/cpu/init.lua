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

    local icons = args.icons or
        {
            logo = nil
        }
    local info = {}
    local popup = awful.popup(
        {
            border_color = beautiful.bg_focus,
            border_width = beautiful_dpi(2),
            offset = { y = beautiful_dpi(2) },
            ontop = true,
            shape = gears.shape.rounded_rect,
            visible = false,
            widget =
                {
                    {
                        {
                            {
                                id = "row_container",
                                layout = wibox.layout.fixed.vertical,
                                spacing = beautiful_dpi(5)
                            },
                            layout = wibox.container.margin(_, beautiful_dpi(5), beautiful_dpi(5), beautiful_dpi(5), beautiful_dpi(5))
                        },
                        layout = wibox.layout.fixed.horizontal
                    },
                    bg = beautiful.bg_reset,
                    shape = gears.shape.rectangle,
                    widget = wibox.container.background
                }
        }
    )
    local terminal = args.terminal or "xterm"
    local timeout = args.timeout or 2
    local widget = wibox.widget(
        {
            {
                {
                    {
                        id = "icon",
                        widget = wibox.widget.imagebox(icons.logo)
                    },
                    id = "icon_container",
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
    local function create_popup_row(title)
        return wibox.widget(
            {
                {
                    {
                        {
                            {
                                align  = "center",
                                forced_height = beautiful_dpi(20),
                                forced_width = beautiful_dpi(24),
                                text = string.format("%s", title),
                                valign = "center",
                                widget = wibox.widget.textbox
                            },
                            bg = beautiful.bg_focus,
                            shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(5)) end,
                            widget = wibox.container.background
                        },
                        layout = wibox.container.margin(_, _, _, _, _)
                    },
                    {
                        {
                            {
                                align  = "center",
                                forced_height = beautiful_dpi(20),
                                forced_width = beautiful_dpi(36),
                                text = "N/A",
                                valign = "center",
                                widget = wibox.widget.textbox
                            },
                            bg = beautiful.bg_focus,
                            shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(5)) end,
                            widget = wibox.container.background
                        },
                        layout = wibox.container.margin(_, beautiful_dpi(3), _, _, _)
                    },
                    {
                        {
                            {
                                background_color = beautiful.bg_focus,
                                color = string.format("linear:0,0:150,0:0,%s:0.5,%s:1,%s", "#00FF00", "#FFFF00", "#FF0000"),
                                forced_height = beautiful_dpi(20),
                                forced_width = beautiful_dpi(150),
                                margins = beautiful_dpi(1),
                                max_value = 100,
                                paddings = beautiful_dpi(6),
                                value = 0,
                                widget = wibox.widget.progressbar
                            },
                            bg = beautiful.bg_focus,
                            shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(5)) end,
                            widget = wibox.container.background
                        },
                        layout = wibox.container.margin(_, beautiful_dpi(3), _, _, _)
                    },
                    layout = wibox.layout.fixed.horizontal
                },
                bg = beautiful.bg_reset,
                shape = gears.shape.rectangle,
                widget = wibox.container.background
            }
        )
    end

    local function update_popup(cpu_info)
        local function _set_text(container, index, value)
            local widget = container:get_children()[index]:get_children()[1]:get_children()[1]
            widget:set_markup(value)
        end

        local function _set_value(container, index, value)
            local widget = container:get_children()[index]:get_children()[1]:get_children()[1]
            widget:set_value(value)
        end

        local rows_container_widget = cpu_info.popup.row:get_children()[1]
        local percentage = math.floor(((cpu_info.active / cpu_info.total) * 100) + 0.5)
        if percentage > 80 then
            _set_text(rows_container_widget, 2, string.format("<span foreground='%s'> %d%% </span>", beautiful.fg_urgent, percentage))
        elseif percentage > 40 then
            _set_text(rows_container_widget, 2, string.format("<span foreground='%s'> %d%% </span>", beautiful.fg_focus, percentage))
        else
            _set_text(rows_container_widget, 2, string.format("<span foreground='%s'> %d%% </span>", beautiful.fg_normal, percentage))
        end
        _set_value(rows_container_widget, 3, percentage)
    end

    local function update_widget()
        local text_widget = widget:get_children_by_id("text")[1]
        text_widget:set_markup(string.format(" %d%% ", math.floor(((info[0].active / info[0].total) * 100) + 0.5)))
    end

    local function update()
        awful.spawn.easy_async(
            string.format("grep '^cpu.' /proc/stat"),
            function(stdout, _, _, _)
                local i = 0
                for line in stdout:gmatch("[^\r\n]+") do
                    -- read data from command results
                    local name, user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice = string.match(line, "(%w+)%s+(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)")
                    if not info[i] then
                        -- add new cpu info since there isn't any
                        info[i] =
                            {
                                name = name,
                                popup = {}
                            }

                        -- do not add popup for global cpu
                        if i ~= 0 then
                            local cpu_info = info[i]

                            -- create popup row
                            cpu_info.popup.row = create_popup_row(string.gsub(name, "cpu", ""))

                            -- add popup row to layout
                            popup:get_widget():get_children_by_id("row_container")[1]:add(cpu_info.popup.row)
                        end
                    end

                    local cpu_info = info[i]

                    -- continue since it is the same cpu
                    if name == cpu_info.name then
                        -- calculate stats values
                        local total = user + nice + system + idle + iowait + irq + softirq + steal
                        local active = total - (idle + iowait)
                        local prev_active = cpu_info and cpu_info.prev_active or 0
                        local prev_total = cpu_info and cpu_info.prev_total or 0

                        -- update cpu stats
                        cpu_info.active = active - prev_active
                        cpu_info.total = total - prev_total
                        cpu_info.prev_active = active
                        cpu_info.prev_total = total

                        -- update popup
                        if i ~= 0 and popup.visible then
                            update_popup(cpu_info)
                        end

                        -- continue
                        i = i + 1
                    end
                end

                -- update widget
                update_widget()
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

            for i, v in pairs(info) do
                if i ~= 0 then
                    update_popup(v)
                end
            end
            popup:move_next_to(mouse.current_widget_geometry)
            popup.visible = true
        end
    )

    widget:connect_signal(
        "mouse::leave",
        function(c)
            popup.visible = false
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
