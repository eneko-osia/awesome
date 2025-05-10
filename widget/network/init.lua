-- {{{ Standard libraries
local awful         = require("awful")
local beautiful     = require("beautiful")
local beautiful_dpi = require("beautiful.xresources").apply_dpi
local gears         = require("gears")
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
            wifi_excellent = nil,
            wifi_very_good = nil,
            wifi_good = nil,
            wifi_weak = nil,
            wifi_none = nil
        }
    local info = 
        { 
            interfaces = {},
            received = 0,
            sent = 0
        }
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
    local widget = wibox.widget(
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
                                    create_wifi_popup_row("ip"),
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

    local function update_speed_popup(net_info)
        local function _set_text(container, index, value)
            local widget = container:get_children()[index]:get_children()[1]:get_children()[1]
            widget:set_markup(value)
        end

        local rows_container_widget = net_info.popup.speed_row:get_children()[1]
        _set_text(rows_container_widget, 2, convert_bytes_to_bits_per_second(net_info.received))
        _set_text(rows_container_widget, 3, convert_bytes_to_bits_per_second(net_info.sent))
        net_info.popup.speed_row.opacity = ((net_info.state == STATE_UP) and 1.0 or ((net_info.state == STATE_UNKNOWN) and 0.6 or 0.2))
    end

    local function update_wifi_popup(net_info)
        local function _set_text(container, index, value)
            local widget = container:get_children()[index]:get_children()[1]:get_children()[2]:get_children()[1]:get_children()[1]
            widget:set_markup(value)
        end

        local popup_widget = net_info.popup.wifi:get_widget()
        local rows_container_widget = popup_widget:get_children_by_id("row_container")[1]
        _set_text(rows_container_widget, 1, string.format(" %s", net_info.interface))
        _set_text(rows_container_widget, 2, net_info.ssid)
        _set_text(rows_container_widget, 3, net_info.ip)
        _set_text(rows_container_widget, 4, net_info.received_bitrate)
        _set_text(rows_container_widget, 5, net_info.sent_bitrate)
    end

    local function create_wifi_widget(net_info)
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
                    id = "icon_container",
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
        local icon_widget_container = widget:get_children_by_id("icon_container")[1]
        icon_widget_container:buttons(
            gears.table.join(
                awful.button(
                    {},
                    1,
                    _,
                    function()
                        awful.spawn.easy_async(
                            string.format("%s -e iwctl", terminal),
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

                update_wifi_popup(net_info)
                net_info.popup.wifi:move_next_to(mouse.current_widget_geometry)
                net_info.popup.wifi.visible = true
            end
        )

        icon_widget_container:connect_signal(
            "mouse::leave",
            function(c)
                net_info.popup.wifi.visible = false
                c:set_bg(beautiful.bg_reset)
            end
        )

        return widget
    end

    local function update_speed_widget()
        local netdl_text_widget = widget:get_children_by_id("text_netdl")[1]
        netdl_text_widget:set_markup(convert_bytes_to_bits_per_second(info.received))

        local netup_text_widget = widget:get_children_by_id("text_netup")[1]
        netup_text_widget:set_markup(convert_bytes_to_bits_per_second(info.sent))
    end

    local function update_wifi_widget(net_info)
        local icon_widget_container = net_info.widget:get_children_by_id("icon_container")[1]
        if net_info.state == STATE_UP then
            local icon_widget = icon_widget_container:get_children()[1]:get_children()[1]
            if net_info.signal >= -30 then
                icon_widget:set_image(icons.wifi_excellent)
            elseif net_info.signal >= -67 then
                icon_widget:set_image(icons.wifi_very_good)
            elseif net_info.signal >= -70 then
                icon_widget:set_image(icons.wifi_good)
            elseif net_info.signal >= -80 then
                icon_widget:set_image(icons.wifi_weak)
            else
                icon_widget:set_image(icons.wifi_none)
            end
            net_info.widget.visible = true
        else
            net_info.widget.visible = false
        end
    end

    local function remove_connection_info(index)
        local net_info = info.interfaces[index]
        -- remove widget
        if net_info.widget then
            widget:remove_widgets(net_info.widget, true)
        end
        -- remove speed row
        if net_info.popup.speed_row then
            popup_speed:get_widget():get_children_by_id("row_container")[1]:remove_widgets(net_info.popup.speed_row, true)
        end
        -- remove info about the interface since it is different
        table.remove(info.interfaces, index)
    end

    local function update_connection_info(net_info)
        if net_info.state == STATE_UP then
            awful.spawn.easy_async(
                string.format("ip address show %s", net_info.interface),
                function(stdout, _, _, _)
                    -- get ip info
                    net_info.ip = string.match(stdout, "inet (%d+%.%d+%.%d+%.%d+)") or "N/A"

                    -- update popup
                    if net_info.popup.wifi.visible then
                        update_wifi_popup(net_info)
                    end
                end
            )

            if net_info.type == "wlan" then
                awful.spawn.easy_async(
                    string.format("iw dev %s link", net_info.interface),
                    function(stdout, _, _, _)
                        -- get wifi connection state info
                        for line in string.gmatch(stdout, "[^\r\n]+") do
                            net_info.received_bitrate = string.match(line, "rx bitrate: (.+/s)") or net_info.received_bitrate
                            net_info.sent_bitrate = string.match(line, "tx bitrate: (.+/s)") or net_info.sent_bitrate
                            net_info.signal = tonumber(string.match(line, "signal: (-%d+)") or net_info.signal)
                            net_info.ssid = string.match(line, "SSID: (.+)") or net_info.ssid
                        end

                        -- update popup
                        if net_info.popup.wifi.visible then
                            update_wifi_popup(net_info)
                        end

                        -- update widget
                        update_wifi_widget(net_info)
                    end
                )
            end
        else
            if net_info.type == "wlan" then
                -- update widget
                if net_info.widget then
                    update_wifi_widget(net_info)
                end
            end
        end
    end

    local function update_connection_state_n_stats(net_info)
        -- check interface state
        awful.spawn.easy_async(
            string.format("cat \
                /sys/class/net/%s/carrier \
                /sys/class/net/%s/operstate \
                /sys/class/net/%s/statistics/rx_bytes \
                /sys/class/net/%s/statistics/tx_bytes",
                net_info.interface,
                net_info.interface,
                net_info.interface,
                net_info.interface),
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
                            net_info.state = STATE_DOWN
                        else
                            if v == "up" then
                                net_info.state = STATE_UP
                            elseif v == "down" then
                                net_info.state = STATE_DOWN
                            else
                                net_info.state = STATE_UNKNOWN
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
                net_info.received = (received - (net_info.prev_received or 0)) / timeout
                net_info.sent = (sent - (net_info.prev_sent or 0)) / timeout
                net_info.prev_received = received
                net_info.prev_sent = sent

                -- update popup
                if net_info.popup.speed_row.visible then
                    update_speed_popup(net_info)
                end

                -- calculate total received and sent
                if net_info.state == STATE_UP then
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
                end

                -- update widget
                update_speed_widget()
            end
        )
    end

    local function update()
        -- check network interfaces in the system
        awful.spawn.easy_async(
            "ls /sys/class/net",
            function(stdout, _, _, _)
                -- get interfaces
                local interfaces = {}
                for interface in stdout:gmatch("[^\r\n]+") do
                    if interface ~= "lo" then
                        table.insert(interfaces, interface)
                    end
                end

                -- check number of interfaces
                local need_to_remove = false
                if #interfaces ~= #info.interfaces then
                    need_to_remove = true
                else
                    -- check all interfaces are the same
                    for i, interface in ipairs(interfaces) do
                        if interface ~= info.interfaces[i].interface then
                            need_to_remove = true
                            break
                        end
                    end
                end

                -- if interfaces do not match remove them all
                if need_to_remove then
                    for i = #info.interfaces, 1, -1 do
                        remove_connection_info(i)
                    end
                end

                -- iterate all network interfaces
                for i, interface in ipairs(interfaces) do
                     if not info.interfaces[i] then
                        -- add new interface info since there isn't any
                        info.interfaces[i] =
                            {
                                interface = interface,
                                popup =
                                    {
                                        speed_row = create_speed_popup_row(interface)
                                    },
                                received = 0,
                                sent = 0,
                                state = STATE_DOWN
                            }
                        local net_info = info.interfaces[i]

                        -- add popup row to layout
                        popup_speed:get_widget():get_children_by_id("row_container")[1]:add(net_info.popup.speed_row)

                        -- request interface type
                        awful.spawn.easy_async(
                            string.format("cat /sys/class/net/%s/uevent", interface),
                            function(stdout, _, _, _)
                                net_info.type = string.match(stdout, "DEVTYPE=(%w+)") or "ethernet"
                                if net_info.type == "wlan" then
                                    -- create wifi popup
                                    net_info.popup.wifi = create_wifi_popup()

                                    -- create wifi widget
                                    net_info.widget = create_wifi_widget(net_info)
                                    local connection_container_widget = widget:get_children_by_id("connection_container")[1]:get_children()[1]
                                    connection_container_widget:add(net_info.widget)
                                end
                            end
                        )
                    end

                    local net_info = info.interfaces[i]

                    -- check interface state and stats
                    update_connection_state_n_stats(net_info)

                    -- check interface connection info
                    update_connection_info(net_info)
                end
            end
        )
    end

    -- signals
    local speed_container_widget = widget:get_children_by_id("speed_container")[1]
    speed_container_widget:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)

            for _, v in pairs(info.interfaces) do
                update_speed_popup(v)
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
