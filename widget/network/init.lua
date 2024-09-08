-- {{{ Standard libraries
local awful         = require("awful")
local beautiful     = require("beautiful")
local beautiful_dpi = require("beautiful.xresources").apply_dpi
local gears         = require("gears")
local gears_timer   = require("gears.timer")
local naughty       = require("naughty")
local wibox         = require("wibox")
-- }}}

-- {{{ Factory
local function factory(args)
    args = args or {}

    local icons = args.icons or
        {
            netdl = nil,
            netup = nil
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
            widget = {}
        }
    )
    local terminal = args.terminal or "xterm"
    local timeout = args.timeout or 2
    local widget_network = wibox.widget(
        {
            {
                {
                    {
                        id = "icon_netdl",
                        widget = wibox.widget.imagebox(icons.netdl)
                    },
                    layout = wibox.container.margin(_, _, _, _, _)
                },
                {
                    {
                        {
                            align  = "center",
                            forced_width = beautiful_dpi(64),
                            id = "text_netdl",
                            text = "0.0 B/s",
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
                            forced_width = beautiful_dpi(64),
                            id = "text_netup",
                            text = "0.0 B/s",
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
                    layout = wibox.container.margin(_, beautiful_dpi(3), _, _, _)
                },
                layout = wibox.layout.fixed.horizontal
            },
            bg = beautiful.bg_reset,
            shape = gears.shape.rectangle,
            widget = wibox.container.background
        }
    )

    -- methods
    local function convert_bytes_to_text(bytes)
        if (bytes > 1048576.0) then
            return string.format(" %.1f MiB/s ", bytes / 1048576.0)
        elseif (bytes > 1024.0) then
            return string.format(" %.1f KiB/s ", bytes / 1024.0)
        end
        return string.format(" %.1f B/s ", bytes)
    end

    local function update_popup()
        local rows =
        {
            layout = wibox.layout.fixed.vertical,
            spacing = beautiful_dpi(5)
        }
        for k, v in pairs(info) do
            if k ~= 0 then
                local row = wibox.widget(
                    {
                        {
                            {
                                {
                                    {
                                        align  = "left",
                                        forced_height = beautiful_dpi(20),
                                        forced_width = beautiful_dpi(64),
                                        text = string.format(" %s", v.interface),
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
                                        text = convert_bytes_to_text(v.received),
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
                                        text = convert_bytes_to_text(v.sent),
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
        local netdl_text_widget = widget_network:get_children_by_id("text_netdl")[1]
        netdl_text_widget:set_markup(convert_bytes_to_text(info[0].received))

        local netup_text_widget = widget_network:get_children_by_id("text_netup")[1]
        netup_text_widget:set_markup(convert_bytes_to_text(info[0].sent))
    end

    local function update()

        -- reset the request completed flag
        for k, v in pairs(info) do
            v.request_completed = (k == 0)
        end

        -- request data for each interface
        for k, v in pairs(info) do
            if k ~= 0 then
                awful.spawn.easy_async(
                    string.format("cat /sys/class/net/%s/carrier /sys/class/net/%s/operstate /sys/class/net/%s/statistics/rx_bytes /sys/class/net/%s/statistics/tx_bytes", v.interface, v.interface, v.interface, v.interface),
                    function(stdout, _, _, _)

                        local carrier = 0
                        local received = 0
                        local sent = 0
                        local state = 0

                        local i = 0
                        for w in stdout:gmatch("[^\r\n]+") do
                            if     i == 0 then carrier = w
                            elseif i == 1 then state = w
                            elseif i == 2 then received = w
                            elseif i == 3 then sent = w
                            end
                            i = i + 1
                        end

                        local prev_received = v.prev_received or 0
                        local prev_sent = v.prev_sent or 0

                        v.received = (received - prev_received) / timeout
                        v.sent     = (sent - prev_sent) / timeout
                        v.prev_received = received
                        v.prev_sent = sent
                        v.request_completed = true

                        -- check if all requests are completed
                        local requests_completed = true
                        local total_received = 0
                        local total_sent = 0
                        for j, w in pairs(info) do
                            if j ~= 0 then
                                total_received = total_received + w.received
                                total_sent = total_sent + w.sent
                            end
                            requests_completed = requests_completed and w.request_completed
                            if not requests_completed then
                                break
                            end
                        end

                        if requests_completed then
                            info[0].received = total_received
                            info[0].sent = total_sent
                            if popup.visible then
                                update_popup()
                            end
                            update_widget()
                        end
                    end
                )
            end
        end
    end

    -- bindings
    widget_network:buttons(
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
    widget_network:connect_signal(
        "button::press",
        function(c)
            c:set_bg(beautiful.bg_focus)
        end
    )

    widget_network:connect_signal(
        "button::release",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )

    widget_network:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)

            update_popup()
            popup:move_next_to(mouse.current_widget_geometry)
            popup.visible = true
        end
    )

    widget_network:connect_signal(
        "mouse::leave",
        function(c)
            popup.visible = false
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

    -- initialize interfaces
    awful.spawn.easy_async(
        "ip link",
        function(stdout, _, _, _)

            info[0] =
                {
                    interface = "all",
                    received = 0,
                    sent = 0
                }

            local i = 1
            for ip_link_line in stdout:gmatch("[^\r\n]+") do
                local interface = ip_link_line:match("(%w+): <")
                if interface then
                    if interface ~= "lo" then
                        info[i] =
                            {
                                interface = interface,
                                received = 0,
                                sent = 0
                            }
                        i = i + 1
                    end
                end
            end
        end
    )

    return widget_network
end
-- }}}

return factory
