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
    local mount_default = args.mount_default or "/"
    local mounts = args.mounts or { "/" }
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
    local timeout = args.timeout or 2
    local widget = wibox.widget(
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
    local function create_popup_row(title)
        return wibox.widget(
            {
                {
                    {
                        {
                            {
                                align  = "left",
                                forced_height = beautiful_dpi(20),
                                forced_width = beautiful_dpi(128),
                                text = string.format(" %s", title),
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
                    {
                        {
                            {
                                align  = "center",
                                forced_height = beautiful_dpi(20),
                                forced_width = beautiful_dpi(128),
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
                    layout = wibox.layout.fixed.horizontal
                },
                bg = beautiful.bg_reset,
                shape = gears.shape.rectangle,
                widget = wibox.container.background
            }
        )
    end

    local function update_popup(fs_info)
        local function _set_text(container, index, value)
            local widget = container:get_children()[index]:get_children()[1]:get_children()[1]
            widget:set_markup(value)
        end

        local function _set_value(container, index, value)
            local widget = container:get_children()[index]:get_children()[1]:get_children()[1]
            widget:set_value(value)
        end

        local rows_container_widget = fs_info.popup.row:get_children()[1]
        local used = math.floor((fs_info.used / 1024.0 / 1024.0) + 0.5)
        local size = math.floor((fs_info.size / 1024.0 / 1024.0) + 0.5)
        if fs_info.percentage > 80 then
            _set_text(rows_container_widget, 2, string.format("<span foreground='%s'> %d%% </span>", beautiful.fg_urgent, fs_info.percentage))
            _set_text(rows_container_widget, 4, string.format("<span foreground='%s'> %3d / %3d GiB </span>", beautiful.fg_urgent, used, size))
        elseif fs_info.percentage > 60 then
            _set_text(rows_container_widget, 2, string.format("<span foreground='%s'> %d%% </span>", beautiful.fg_focus, fs_info.percentage))
            _set_text(rows_container_widget, 4, string.format("<span foreground='%s'> %3d / %3d GiB </span>", beautiful.fg_focus, used, size))
        else
            _set_text(rows_container_widget, 2, string.format("<span foreground='%s'> %d%% </span>", beautiful.fg_normal, fs_info.percentage))
            _set_text(rows_container_widget, 4, string.format("<span foreground='%s'> %3d / %3d GiB </span>", beautiful.fg_normal, used, size))
        end
        _set_value(rows_container_widget, 3, fs_info.percentage)
    end

    local function update_widget(fs_info)
        local text_widget = widget:get_children_by_id("text")[1]
        if fs_info.percentage > 80 then
            text_widget:set_markup(string.format("<span foreground='%s'> %d%% </span>", beautiful.fg_urgent, fs_info.percentage))
        elseif fs_info.percentage > 60 then
            text_widget:set_markup(string.format("<span foreground='%s'> %d%% </span>", beautiful.fg_focus, fs_info.percentage))
        else
            text_widget:set_markup(string.format("<span foreground='%s'> %d%% </span>", beautiful.fg_normal, fs_info.percentage))
        end
    end

    local function remove_file_system_info(index)
        -- remove popup row from layout
        popup:get_widget():get_children_by_id("row_container")[1]:remove_widgets(info[index].popup.row, true)

        -- remove info about the file system
        table.remove(info, index)
    end

    local function update()

        local function is_in_mounts(mount)
            for _, v in pairs(mounts) do
                if mount == v then
                    return true
                end
            end
            return false
        end

        -- check file systems in the system
        awful.spawn.easy_async_with_shell(
            "df -k | tail -n +2",
            function(stdout, _, _, _)
                -- get devices
                local devices = {}
                for line in stdout:gmatch("[^\r\n]+") do
                    local device, size, used, available, percentage, mount = string.match(line, "([%p%w]+)%s+([%d%w]+)%s+([%d%w]+)%s+([%d%w]+)%s+([%d]+)%%%s+([%p%w]+)")
                    if is_in_mounts(mount) then
                        table.insert(devices, device)
                    end
                end

                -- check number of devices
                local need_to_remove = false
                if #devices ~= #info then
                    need_to_remove = true
                else
                    -- check all devices are the same
                    for i, device in ipairs(devices) do
                        if device ~= info[i].device then
                            need_to_remove = true
                            break
                        end
                    end
                end

                -- if devices do not match remove them all
                if need_to_remove then
                    for i = #info, 1, -1 do
                        remove_file_system_info(i)
                    end
                end

                -- iterate all file systems
                local i = 1
                for line in stdout:gmatch("[^\r\n]+") do
                    -- read data from command results
                    local device, size, used, available, percentage, mount = string.match(line, "([%p%w]+)%s+([%d%w]+)%s+([%d%w]+)%s+([%d%w]+)%s+([%d]+)%%%s+([%p%w]+)")
                    if is_in_mounts(mount) then
                        if not info[i] then
                            -- add new file system info since there isn't any
                            info[i] =
                                {
                                    device = device,
                                    mount = mount,
                                    popup =
                                        {
                                            row = create_popup_row(mount)
                                        }
                                }

                            -- add popup row to layout
                            popup:get_widget():get_children_by_id("row_container")[1]:add(info[i].popup.row)
                        end

                        local fs_info = info[i]

                        -- update file system stats
                        fs_info.available = tonumber(available)
                        fs_info.percentage = tonumber(percentage)
                        fs_info.size = tonumber(size)
                        fs_info.used = tonumber(used)

                        -- update popup
                        if popup.visible then
                            update_popup(fs_info)
                        end

                        -- update widget
                        if mount == mount_default then
                            update_widget(fs_info)
                        end

                        -- continue
                        i = i + 1
                    end
                end
            end
        )
    end

    -- signals
    widget:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)

            for _, v in pairs(info) do
                update_popup(v)
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
