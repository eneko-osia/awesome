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
    args = args or {}

    local icons = args.icons or
    {
        logo = nil
    }
    local info = {}
    local mount_default = args.mount_default or "/"
    local mounts = args.mounts or
        {
            "/",
            "/home"
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
    local file_system = wibox.widget(
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
        local rows =
        {
            layout = wibox.layout.fixed.vertical,
            spacing = beautiful_dpi(5)
        }

        for k, v in pairs(mounts) do
            local row = wibox.widget(
                {
                    {
                        {
                            {
                                {
                                    align  = "left",
                                    forced_height = beautiful_dpi(20),
                                    forced_width = beautiful_dpi(64),
                                    text = string.format(" %s", info[v].mount),
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
                                    text = string.format("%d%%", info[v].percentage),
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
                                    value = info[v].percentage,
                                    widget = wibox.widget.progressbar
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
                                    align  = "center",
                                    forced_height = beautiful_dpi(20),
                                    forced_width = beautiful_dpi(128),
                                    text = string.format("%d / %d GiB", math.floor(info[v].used / 1024 / 1024), math.floor(info[v].size / 1024 / 1024)),
                                    valign = "center",
                                    widget = wibox.widget.textbox
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
            table.insert(rows, row)
        end

        popup:setup(
            {
                {
                    {
                        rows,
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
        local text_widget = file_system:get_children_by_id("text")[1]
        text_widget:set_markup(string.format(" %d%% ", info[mount_default].percentage))
    end

    local function update()
        awful.spawn.easy_async_with_shell(
            string.format("df | tail -n +2"),
            function(stdout, _, _, _)
                for line in stdout:gmatch("[^\r\n]+") do
                    local device, size, used, available, percentage, mount = line:match("([%p%w]+)%s+([%d%w]+)%s+([%d%w]+)%s+([%d%w]+)%s+([%d]+)%%%s+([%p%w]+)")
                    info[mount] =
                        {
                            available = tonumber(available),
                            device = device,
                            mount = mount,
                            percentage = tonumber(percentage),
                            size = tonumber(size),
                            used = tonumber(used)
                        }
                end
                if popup.visible then
                    update_popup()
                end
                update_widget()
            end
        )
    end

    -- signals
    file_system:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)

            update_popup()
            popup:move_next_to(mouse.current_widget_geometry)
            popup.visible = true
        end
    )
    file_system:connect_signal(
        "mouse::leave",
        function(c)
            popup.visible = false
            c:set_bg(beautiful.bg_reset)
        end
    )

    -- timers
    gears_timer(
        {
            timeout = 60,
            autostart = true,
            call_now = true,
            callback = update
        }
    )

    return file_system
end
-- }}}

return factory
