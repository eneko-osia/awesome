-- {{{ Standard libraries
local awful     = require("awful")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi
local gears     = require("gears")
local lain      = require("lain")
local naughty   = require("naughty")
local timer     = require("gears.timer")
local watch     = require("awful.widget.watch")
local wibox     = require("wibox")
-- }}}

-- {{{ Factory
local function factory(args)
    local args = args or {}

    local icons = args.icons or {
        netdl = nil,
        netup = nil,
        vpn_connected = nil,
        vpn_diconnected = nil
    }
    local notification = nil
    local notification_text = "N/A"

    local network = {
        vpn_connected = false,
        widget = wibox.widget({
            {

                {
                    {
                        {
                            widget = wibox.widget.imagebox(icons.vpn_diconnected)
                        },
                        layout = wibox.container.margin(_, 4, 4, 3, 3)
                    },
                    bg = beautiful.bg_reset,
                    shape = gears.shape.rectangle,
                    widget = wibox.container.background,
                },
                {
                    {
                        widget = wibox.widget.imagebox(icons.netdl)
                    },
                    layout = wibox.container.margin(_, _, 2, _, _)
                },
                {
                    {
                        {
                            align  = "center",
                            forced_width = dpi(64),
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
                {
                    {
                        {
                            align  = "center",
                            forced_width = dpi(64),
                            text = "N/A",
                            valign = "center",
                            widget = wibox.widget.textbox
                        },
                        bg = beautiful.bg_focus,
                        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 2) end,
                        widget = wibox.container.background,
                    },
                    layout = wibox.container.margin(_, _, 2, 3, 3)
                },
                {
                    {
                        widget = wibox.widget.imagebox(icons.netup)
                    },
                    layout = wibox.container.margin(_, _, 2, _, _)
                },
                layout = wibox.layout.fixed.horizontal
            },
            bg = beautiful.bg_reset,
            shape = gears.shape.rectangle,
            widget = wibox.container.background
        })
    }

    -- lain widget creation
    local lain_network = lain.widget.net({
        settings =
            function()
                local netdl_text_widget_container = widget:get_children()[1]:get_children()[3]:get_children()[1]
                local netdl_text_widget = netdl_text_widget_container:get_children()[1]
                if (netdl_text_widget ~= nil) then
                    if (tonumber(net_now.received) > 1024.0) then
                        netdl_text_widget:set_markup(string.format(" %.1f Mb ", tonumber(net_now.received) / 1024))
                    else
                        netdl_text_widget:set_markup(string.format(" %.1f Kb ", net_now.received))
                    end
                end

                local netup_text_widget_container = widget:get_children()[1]:get_children()[4]:get_children()[1]
                local netup_text_widget = netup_text_widget_container:get_children()[1]
                if (netup_text_widget ~= nil) then
                    if (tonumber(net_now.sent) > 1024.0) then
                        netup_text_widget:set_markup(string.format(" %.1f Mb ", tonumber(net_now.sent) / 1024))
                    else
                        netup_text_widget:set_markup(string.format(" %.1f Kb ", net_now.sent))
                    end
                end
            end,
        widget = network.widget
    })

    -- methods
    function network:vpn_connect()
        if not network.vpn_connected then
            awful.spawn.easy_async(
                "nordvpn c",
                function(stdout)
                    update_vpn_status_async()
                end
            )
        end
    end

    function network:vpn_disconnect()
        if network.vpn_connected then
            awful.spawn.easy_async(
                "nordvpn d",
                function(stdout)
                    update_vpn_status_async()
                end
            )
        end
    end

    function network:vpn_toggle()
        if network.vpn_connected then
            network:vpn_disconnect()
        else
            network:vpn_connect()
        end
    end

    local function update_vpn_status_async()
        awful.spawn.easy_async(
            "nordvpn status",
            function(stdout, _, _, _)
                local vpn_state = string.match(stdout, "Status: (%a+)")
                if vpn_state ~= nil and vpn_state:lower() == "connected" then
                    network.vpn_connected = true
                else
                    network.vpn_connected = false
                end

                local vpn_icon_widget_container = network.widget:get_children()[1]:get_children()[1]
                local vpn_icon_widget = vpn_icon_widget_container:get_children()[1]:get_children()[1]
                if (vpn_icon_widget ~= nil) then
                    if network.vpn_connected then
                        vpn_icon_widget.image = icons.vpn_connected
                    else
                        vpn_icon_widget.image = icons.vpn_diconnected
                    end
                end

                notification_text = stdout
                if notification ~= nil then
                    naughty.replace_text(notification, "VPN State", notification_text)
                end
            end
        )
    end

    -- bindings
    local vpn_icon_widget_container = network.widget:get_children()[1]:get_children()[1]
    vpn_icon_widget_container:buttons(gears.table.join(
        awful.button(
            {},
            1,
            function()
                network:vpn_toggle()
            end
        )
    ))

    -- signals
    vpn_icon_widget_container:connect_signal(
        'mouse::enter',
        function(c)
            c:set_bg(beautiful.bg_normal)

            naughty.destroy(notification)
            notification = naughty.notify(
                {
                    title = "VPN State",
                    text = notification_text
                })
        end
    )
    vpn_icon_widget_container:connect_signal(
        'mouse::leave',
        function(c)
            c:set_bg(beautiful.bg_reset)

            naughty.destroy(notification)
            notification = nil
        end
    )

    -- timers
    timer (
        {
            timeout = 5,
            autostart = true,
            call_now = true,
            callback =
                function()
                    update_vpn_status_async()
                end
        }
    )

    return network
end
-- }}}

return factory
