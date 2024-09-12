-- {{{ Standard libraries
local awful         = require("awful")
local beautiful     = require("beautiful")
local beautiful_dpi = require("beautiful.xresources").apply_dpi
local gears         = require("gears")
local gears_timer   = require("gears.timer")
local wibox         = require("wibox")
-- }}}

-- {{{ Variable definitions
local STATE_DOWN    = 0
local STATE_UP      = 1
local STATE_UNKNOWN = 2
-- }}}

-- {{{ Factory
local function factory(args)
    args = args or {}

    local icons = args.icons or
        {
            eth = nil,
            netdl = nil,
            netup = nil,
            wifi = nil,
            wifi_excelent = nil,
            wifi_very_good = nil,
            wifi_good = nil,
            wifi_weak = nil,
            wifi_none = nil
        }
    local info = { interfaces = {} }
    local popup_speed = awful.popup(
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
    local widget_network = wibox.widget(
        {
            {
                {
                    layout = wibox.layout.fixed.horizontal
                },
                bg = beautiful.bg_reset,
                id = "connection_container",
                shape = gears.shape.rectangle,
                widget = wibox.container.background
            },
            {
                {
                    {
                        {
                            id = "icon_netdl",
                            widget = wibox.widget.imagebox(icons.netdl)
                        },
                        id = "icon_netdl_container",
                        layout = wibox.container.margin(_, _, _, _, _)
                    },
                    {
                        {
                            {
                                align  = "center",
                                forced_width = beautiful_dpi(80),
                                id = "text_netdl",
                                text = "0.0 b/s",
                                valign = "center",
                                widget = wibox.widget.textbox
                            },
                            bg = beautiful.bg_focus,
                            shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(2)) end,
                            widget = wibox.container.background,
                        },
                        layout = wibox.container.margin(_, beautiful_dpi(3), _, beautiful_dpi(3), beautiful_dpi(3))
                    },
                    {
                        {
                            {
                                align  = "center",
                                forced_width = beautiful_dpi(80),
                                id = "text_netup",
                                text = "0.0 b/s",
                                valign = "center",
                                widget = wibox.widget.textbox
                            },
                            bg = beautiful.bg_focus,
                            shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(2)) end,
                            widget = wibox.container.background,
                        },
                        layout = wibox.container.margin(_, beautiful_dpi(3), _, beautiful_dpi(3), beautiful_dpi(3))
                    },
                    {
                        {
                            id = "icon_netup",
                            widget = wibox.widget.imagebox(icons.netup)
                        },
                        id = "icon_netup_container",
                        layout = wibox.container.margin(_, beautiful_dpi(3), _, _, _)
                    },
                    layout = wibox.layout.fixed.horizontal
                },
                bg = beautiful.bg_reset,
                id = "speed_container",
                shape = gears.shape.rectangle,
                widget = wibox.container.background
            },
            layout = wibox.layout.fixed.horizontal
        }
    )

    -- methods
    local function convert_bytes_to_bits_per_second(bytes)
        local bits = bytes * 8
        if bits > 1000000000 then
            return string.format(" %.1f Gb/s ", math.floor((bits / 1000000000) + 0.5))
        elseif bits > 1000000 then
            return string.format(" %.1f Mb/s ", math.floor((bits / 1000000) + 0.5))
        elseif bits > 1000 then
            return string.format(" %.1f kb/s ", math.floor((bits / 1000) + 0.5))
        end
        return string.format(" %.1f b/s ", bits)
    end

    local function convert_bytes_to_to_bytes_per_second(bytes)
        if bytes > 1073741824 then
            return string.format(" %.1f GiB/s ", math.floor((bytes / 1073741824) + 0.5))
        elseif bytes > 1048576 then
            return string.format(" %.1f MiB/s ", math.floor((bytes / 1048576) + 0.5))
        elseif bytes > 1024 then
            return string.format(" %.1f KiB/s ", math.floor((bytes / 1024) + 0.5))
        end
        return string.format(" %.1f B/s ", bytes)
    end

    local function create_speed_popup_row(title)
        return wibox.widget(
            {
                {
                    {
                        {
                            {
                                align  = "left",
                                forced_height = beautiful_dpi(20),
                                forced_width = beautiful_dpi(64),
                                text = string.format(" N/A"),
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
                                forced_width = beautiful_dpi(64),
                                text = string.format(" N/A"),
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
                                align  = "center",
                                forced_height = beautiful_dpi(20),
                                forced_width = beautiful_dpi(64),
                                text = string.format(" N/A"),
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

    local function create_wifi_popup_row(title)
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
                                forced_width = beautiful_dpi(256),
                                text = string.format(" N/A"),
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

    local function create_wifi_popup()
        return awful.popup(
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
                                    create_wifi_popup_row("interface"),
                                    create_wifi_popup_row("ssid"),
                                    create_wifi_popup_row("received bitrate"),
                                    create_wifi_popup_row("sent bitrate"),
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
    end

    local function update_speed_popup(interface_info)
        local function _set_text(container, index, value)
            local widget = container:get_children()[index]:get_children()[1]:get_children()[1]
            widget:set_markup(value)
        end

        local rows_container_widget = interface_info.popup.speed_row:get_children()[1]
        _set_text(rows_container_widget, 1, string.format(" %s", interface_info.interface))
        _set_text(rows_container_widget, 2, convert_bytes_to_bits_per_second(interface_info.received))
        _set_text(rows_container_widget, 3, convert_bytes_to_bits_per_second(interface_info.sent))
        interface_info.popup.speed_row.opacity = ((interface_info.state == STATE_UP) and 1.0 or ((interface_info.state == STATE_UNKNOWN) and 0.6 or 0.2))
    end

    local function update_wifi_popup(interface_info)
        local function _set_text(container, index, value)
            local widget = container:get_children()[index]:get_children()[1]:get_children()[2]:get_children()[1]:get_children()[1]
            widget:set_markup(value)
        end

        local popup_widget = interface_info.popup.info:get_widget()
        local rows_container_widget = popup_widget:get_children_by_id("row_container")[1]
        _set_text(rows_container_widget, 1, string.format(" %s", interface_info.interface))
        _set_text(rows_container_widget, 2, interface_info.ssid)
        _set_text(rows_container_widget, 3, interface_info.received_bitrate)
        _set_text(rows_container_widget, 4, interface_info.sent_bitrate)
    end

    local function create_wifi_widget(interface_info)
        local widget = wibox.widget(
            {
                {
                    {
                        {
                            widget = wibox.widget.imagebox(icons.wifi)
                        },
                        layout = wibox.container.margin(_, beautiful_dpi(4), beautiful_dpi(4), beautiful_dpi(3), beautiful_dpi(3))
                    },
                    bg = beautiful.bg_reset,
                    id = "icon_widget_container",
                    shape = gears.shape.rectangle,
                    widget = wibox.container.background
                },
                {
                    {
                        widget = wibox.widget.imagebox(beautiful.spr)
                    },
                    layout = wibox.container.margin(_, _, _, _, _)
                },
                layout = wibox.layout.fixed.horizontal
            }
        )

        -- bindings
        local icon_widget_container = widget:get_children_by_id("icon_widget_container")[1]
        icon_widget_container:buttons(
            gears.table.join(
                awful.button(
                    {},
                    1,
                    _,
                    function()
                        awful.spawn.easy_async(
                            string.format("%s -e nmtui", terminal),
                            function(stdout)
                            end
                        )
                    end
                )
            )
        )

        -- signals
        icon_widget_container:connect_signal(
            "button::press",
            function(c)
                c:set_bg(beautiful.bg_focus)
            end
        )

        icon_widget_container:connect_signal(
            "button::release",
            function(c)
                c:set_bg(beautiful.bg_normal)
            end
        )

        icon_widget_container:connect_signal(
            "mouse::enter",
            function(c)
                c:set_bg(beautiful.bg_normal)

                update_wifi_popup(interface_info)
                interface_info.popup.info:move_next_to(mouse.current_widget_geometry)
                interface_info.popup.info.visible = true
            end
        )

        icon_widget_container:connect_signal(
            "mouse::leave",
            function(c)
                interface_info.popup.info.visible = false
                c:set_bg(beautiful.bg_reset)
            end
        )

        return widget
    end

    local function update_speed_widget()
        local netdl_text_widget = widget_network:get_children_by_id("text_netdl")[1]
        netdl_text_widget:set_markup(convert_bytes_to_bits_per_second(info.received))

        local netup_text_widget = widget_network:get_children_by_id("text_netup")[1]
        netup_text_widget:set_markup(convert_bytes_to_bits_per_second(info.sent))
    end

    local function update_wifi_widget(interface_info)
        local icon_widget_container = interface_info.widget:get_children_by_id("icon_widget_container")[1]
        if interface_info.state == STATE_UP then
            local icon_widget = icon_widget_container:get_children()[1]:get_children()[1]
            if interface_info.signal >= -30 then
                icon_widget:set_image(icons.wifi_excelent)
            elseif interface_info.signal >= -67 then
                icon_widget:set_image(icons.wifi_very_good)
            elseif interface_info.signal >= -70 then
                icon_widget:set_image(icons.wifi_good)
            elseif interface_info.signal >= -80 then
                icon_widget:set_image(icons.wifi_weak)
            else
                icon_widget:set_image(icons.wifi_none)
            end
            interface_info.widget.visible = true
        else
            interface_info.widget.visible = false
        end
    end

    local function update_connection_info(interface_info)
        if interface_info.type == "wlan" then
            if interface_info.state == STATE_UP then
                awful.spawn.easy_async(
                    string.format("iw dev %s link", interface_info.interface),
                    function(stdout, _, _, _)
                        -- get wifi connection state info
                        for line in stdout:gmatch("[^\r\n]+") do
                            interface_info.received_bitrate = line:match("rx bitrate: (.+/s)") or interface_info.received_bitrate
                            interface_info.sent_bitrate = line:match("tx bitrate: (.+/s)") or interface_info.sent_bitrate
                            interface_info.signal = tonumber(line:match("signal: (-%d+)") or interface_info.signal)
                            interface_info.ssid = line:match("SSID: (.+)") or interface_info.ssid
                        end

                        -- create popup
                        if not interface_info.popup.info then
                            interface_info.popup.info = create_wifi_popup()
                        end

                        -- create widget
                        if not interface_info.widget then
                            interface_info.widget = create_wifi_widget(interface_info)
                            local connection_container_widget = widget_network:get_children_by_id("connection_container")[1]:get_children()[1]
                            connection_container_widget:add(interface_info.widget)
                        end

                        -- update popup
                        if interface_info.popup.info.visible then
                            update_wifi_popup(interface_info)
                        end

                        -- update widget
                        update_wifi_widget(interface_info)
                    end
                )
            else
                -- update widget
                if interface_info.widget then
                    update_wifi_widget(interface_info)
                end
            end
        end
    end

    local function update_connection_state_n_stats(interface_info)
        -- check interface state
        awful.spawn.easy_async(
            string.format("cat \
                /sys/class/net/%s/carrier \
                /sys/class/net/%s/operstate \
                /sys/class/net/%s/statistics/rx_bytes \
                /sys/class/net/%s/statistics/tx_bytes",
                interface_info.interface,
                interface_info.interface,
                interface_info.interface,
                interface_info.interface),
            function(stdout, _, _, _)
                local carrier = 0
                local received = 0
                local sent = 0
                local state = 0

                -- read data from command results
                local i = 0
                for v in stdout:gmatch("[^\r\n]+") do
                    if i == 0 then
                        carrier = v
                    elseif i == 1 then
                        if carrier == 0 then
                            interface_info.state = STATE_DOWN
                        else
                            if v == "up" then
                                interface_info.state = STATE_UP
                            elseif v == "down" then
                                interface_info.state = STATE_DOWN
                            else
                                interface_info.state = STATE_UNKNOWN
                            end
                        end
                    elseif i == 2 then
                        received = v
                    elseif i == 3 then
                        sent = v
                    end
                    i = i + 1
                end

                -- calculate received and sent values
                interface_info.received = (received - (interface_info.prev_received or 0)) / timeout
                interface_info.sent = (sent - (interface_info.prev_sent or 0)) / timeout
                interface_info.prev_received = received
                interface_info.prev_sent = sent

                -- create popup row
                if not interface_info.popup.speed_row then
                    interface_info.popup.speed_row = create_speed_popup_row()
                    local popup_widget = popup_speed:get_widget():get_children_by_id("row_container")[1]
                    popup_widget:add(interface_info.popup.speed_row)
                end

                -- update popup
                if interface_info.popup.speed_row.visible then
                    update_speed_popup(interface_info)
                end

                -- calculate total received and sent
                if interface_info.state == STATE_UP then
                    local total_received = 0
                    local total_sent = 0
                    for _, v in pairs(info.interfaces) do
                        if v.state == STATE_UP then
                            total_received = total_received + v.received
                            total_sent = total_sent + v.sent
                        end
                    end
                    info.received = total_received
                    info.sent = total_sent

                    -- update widget
                    update_speed_widget()
                end
            end
        )
    end

    local function update()
        -- check network interfaces in the system
        awful.spawn.easy_async(
            "ls /sys/class/net",
            function(stdout, _, _, _)
                -- iterate all network interfaces
                local i = 1
                for interface in stdout:gmatch("[^\r\n]+") do
                    if interface ~= "lo" then
                        -- if there is already info about the interface
                        if info.interfaces[i] then
                            local interface_info = info.interfaces[i]
                            -- continue since it is the same interface
                            if interface == interface_info.interface then
                                -- check interface state and stats
                                update_connection_state_n_stats(interface_info)

                                -- check interface connection info
                                update_connection_info(interface_info)

                                -- check interface connection speed
                                i = i + 1
                            else
                                -- remove info about the interface since it is different
                                table.remove(info.interfaces, i)
                            end
                        else
                            -- add new interface info since there isn't any
                            info.interfaces[i] =
                                {
                                    interface = interface,
                                    received = 0,
                                    popup = {},
                                    sent = 0,
                                    state = STATE_DOWN
                                }
                            -- request interface type for the interface
                            local index = i
                            awful.spawn.easy_async(
                                string.format("cat /sys/class/net/%s/uevent", interface),
                                function(stdout, _, _, _)
                                    info.interfaces[index].type = stdout:match("DEVTYPE=(%w+)") or "ethernet"
                                end
                            )
                            i = i + 1
                        end
                    end
                end

                -- remove interfaces that are not in the system anymore
                for j = #info.interfaces, i, -1 do
                    -- remove widget
                    if info.interfaces[j].widget then
                        widget_network:remove_widgets(info.interfaces[j].widget, true)
                    end
                    -- remove speed row
                    if info.interfaces[j].popup.speed_row then
                        popup_speed:get_widget():get_children_by_id("row_container")[1]:remove_widgets(info.interfaces[j].popup.speed_row, true)
                    end
                    table.remove(info.interfaces, j)
                end
            end
        )
    end

    local speed_container_widget = widget_network:get_children_by_id("speed_container")[1]
    speed_container_widget:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)

            for _, v in pairs(info.interfaces) do
                if v.popup.speed_row then
                    update_speed_popup(v)
                end
            end
            popup_speed:move_next_to(mouse.current_widget_geometry)
            popup_speed.visible = true
        end
    )

    speed_container_widget:connect_signal(
        "mouse::leave",
        function(c)
            popup_speed.visible = false
            c:set_bg(beautiful.bg_reset)
        end
    )

    -- timers
    gears_timer(
        {
            timeout = timeout,
            autostart = true,
            call_now = true,
            callback = update
        }
    )

    return widget_network
end
-- }}}

return factory
