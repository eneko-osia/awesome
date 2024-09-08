-- {{{ Standard libraries
local awful         = require("awful")
local beautiful     = require("beautiful")
local beautiful_dpi = require("beautiful.xresources").apply_dpi
local gears         = require("gears")
local gears_timer   = require("gears.timer")
local wibox         = require("wibox")
-- }}}

-- {{{ Helper functions
local function create_popup_row(title)
    return wibox.widget(
        {
            {
                {
                    {
                        {
                            align  = "left",
                            forced_height = beautiful_dpi(20),
                            forced_width = beautiful_dpi(64),
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
-- }}}

-- {{{ Factory
local function factory(args)
    args = args or {}

    local icons = args.icons or
        {
            connected = nil,
            diconnected = nil
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
                                create_popup_row("country"),
                                create_popup_row("city"),
                                create_popup_row("server"),
                                create_popup_row("hostname"),
                                create_popup_row("ip"),
                                create_popup_row("technology"),
                                create_popup_row("protocol"),
                                create_popup_row("uptime"),
                                create_popup_row("transfer"),
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
    local vpn = wibox.widget(
        {
            {
                {
                    id = "icon",
                    widget = wibox.widget.imagebox(icons.diconnected)
                },
                layout = wibox.container.margin(_, beautiful_dpi(4), beautiful_dpi(4), beautiful_dpi(3), beautiful_dpi(3))
            },
            bg = beautiful.bg_reset,
            shape = gears.shape.rectangle,
            widget = wibox.container.background
        }
    )

    -- methods
    local function update_popup()
        local function _set_text(container, index, value)
            local widget = container:get_children()[index]:get_children()[1]:get_children()[2]:get_children()[1]:get_children()[1]
            widget:set_markup(value)
        end

        local popup_widget = popup:get_widget()
        local rows_container_widget = popup_widget:get_children()[1]:get_children()[1]:get_children()[1]
        _set_text(rows_container_widget, 1, info.country)
        _set_text(rows_container_widget, 2, info.city)
        _set_text(rows_container_widget, 3, info.server)
        _set_text(rows_container_widget, 4, info.hostname)
        _set_text(rows_container_widget, 5, info.ip)
        _set_text(rows_container_widget, 6, info.technology)
        _set_text(rows_container_widget, 7, info.protocol)
        _set_text(rows_container_widget, 8, info.up_time)
        _set_text(rows_container_widget, 9, info.transfer_time)
    end

    local function update_widget()
        local icon_widget = vpn:get_children_by_id("icon")[1]
        if info.connected then
            icon_widget.image = icons.connected
        else
            icon_widget.image = icons.diconnected
        end
    end

    local function update()
        awful.spawn.easy_async(
            "nordvpn status",
            function(stdout, _, _, _)
                info =
                {
                    city = string.match(stdout, "City: ([%g%s]+)") or "N/A",
                    connected = (string.match(stdout, "Status: (%a+)") == "Connected"),
                    country = string.match(stdout, "Country: ([%g%s]+)") or "N/A",
                    hostname = string.match(stdout, "Hostname: ([%g%s]+)") or "N/A",
                    ip = string.match(stdout, "IP: ([%g%s]+)") or "N/A",
                    protocol = string.match(stdout, "Current protocol: ([%g%s]+)") or "N/A",
                    server = string.match(stdout, "Server: ([%g%s]+)") or "N/A",
                    technology = string.match(stdout, "Current technology: ([%g%s]+)") or "N/A",
                    transfer_time = string.match(stdout, "Transfer: ([%g%s]+)") or "N/A",
                    up_time = string.match(stdout, "Uptime: ([%g%s]+)") or "N/A"
                }
                if popup.visible then
                    update_popup()
                end
                update_widget()
            end
        )
    end

    function vpn:connect()
        if not info.connected then
            awful.spawn.easy_async(
                "nordvpn c",
                function(stdout)
                    update()
                end
            )
        end
    end

    function vpn:disconnect()
        if info.connected then
            awful.spawn.easy_async(
                "nordvpn d",
                function(stdout)
                    update()
                end
            )
        end
    end

    function vpn:toggle()
        if info.connected then
            vpn:disconnect()
        else
            vpn:connect()
        end
    end

    -- bindings
    vpn:buttons(gears.table.join(
        awful.button(
            {},
            1,
            _,
            function()
                vpn:toggle()
            end
        )
    ))

    -- signals
    vpn:connect_signal(
        "button::press",
        function(c)
            c:set_bg(beautiful.bg_focus)
        end
    )

    vpn:connect_signal(
        "button::release",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )

    vpn:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)

            update_popup()
            popup:move_next_to(mouse.current_widget_geometry)
            popup.visible = true
        end
    )

    vpn:connect_signal(
        "mouse::leave",
        function(c)
            popup.visible = false
            c:set_bg(beautiful.bg_reset)
        end
    )

    -- timers
    gears_timer(
        {
            timeout = 5,
            autostart = true,
            call_now = true,
            callback = update
        }
    )

    return vpn
end
-- }}}

return factory