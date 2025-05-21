-- {{{ Standard libraries
local awful     = require("awful")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi
local gears     = require("gears")
local naughty   = require("naughty")
local lain      = require("lain")
local wibox     = require("wibox")
-- }}}

-- {{{ Factory
local function factory(args)
    args = args or {}

    local icons = args.icons or 
        {
            ac = nil,
            empty = nil,
            full = nil,
            logo = nil,
            low = nil
        }
    local info = 
        {
            batteries = {},
            percentage = 0
        }
    local timeout = args.timeout or 2
    local widget = wibox.widget(
        {
            {
                {
                    {
                        widget = wibox.widget.imagebox(icons.logo)
                    },
                    layout = wibox.container.margin(_, 4, 4, 3, 3)
                },
                {
                    {
                        {
                            align  = "center",
                            forced_width = dpi(36),
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
    local function update_battery_widget()
        -- local netdl_text_widget = widget:get_children_by_id("text_netdl")[1]
        -- netdl_text_widget:set_markup(convert_bytes_to_bits_per_second(info.received))

        -- local netup_text_widget = widget:get_children_by_id("text_netup")[1]
        -- netup_text_widget:set_markup(convert_bytes_to_bits_per_second(info.sent))

        local icon_widget_container = widget:get_children()[1]:get_children()[1]
        local icon_widget = icon_widget_container:get_children()[1]
        local text_widget_container = widget:get_children()[1]:get_children()[2]:get_children()[1]
        local text_widget = text_widget_container:get_children()[1]
        if (icon_widget ~= nil and text_widget ~= nil) then
            if info.ac.status == true then
                icon_widget:set_image(icons.ac)
            --     if bat_now.perc ~= "N/A" then
            --         notification_text = " " .. bat_now.time .. " "
            --         text_widget:set_markup(" " .. bat_now.perc .. "%" .. " ")
            --     else
            --         notification_text = " " .. bat_now.time .. " "
            --         text_widget:set_markup(" 100% ")
            --     end
            else
                if info.percentage == 100 then
                    icon_widget:set_image(icons.ac)
                    -- notification_text = " " .. bat_now.time .. " "
                    text_widget:set_markup(" " .. info.percentage .. "%" .. " ")
                elseif info.percentage > 50 then
                    icon_widget:set_image(icons.full)
                    -- notification_text = " " .. bat_now.time .. " "
                    text_widget:set_markup(" " .. info.percentage .. "%" .. " ")
                elseif info.percentage > 15 then
                    icon_widget:set_image(icons.low)
                    -- notification_text = " " .. bat_now.time .. " "
                    text_widget:set_markup(lain.util.markup(beautiful.fg_focus, " " .. info.percentage .. "%" .. " "))
                else
                    icon_widget:set_image(icons.empty)
                    -- notification_text = " " .. bat_now.time .. " "
                    text_widget:set_markup(lain.util.markup(beautiful.fg_urgent, " " .. info.percentage .. "%" .. " "))
                end
            -- else
            --     icon_widget:set_image(icons.empty)
            --     notification_text = " " .. bat_now.time .. " "
            --     text_widget:set_markup(lain.util.markup(beautiful.fg_urgent, " " .. info.percentage .. "%" .. " "))
            end
        end
    end

    local function update_ac_state()
        awful.spawn.easy_async(
            string.format("cat /sys/class/power_supply/%s/online", info.ac.name),
            function(stdout, _, _, _)
                -- read data from command results
                info.ac.status = (tonumber(stdout) == 1)
            end
        )
    end

    local function update_battery_state(bat_info)
        awful.spawn.easy_async(
            string.format("cat \
                /sys/class/power_supply/%s/status \
                /sys/class/power_supply/%s/energy_now \
                /sys/class/power_supply/%s/energy_full",
                bat_info.name,
                bat_info.name,
                bat_info.name),
            function(stdout, _, _, _)
                -- read data from command results
                local i = 0
                for v in stdout:gmatch("[^\r\n]+") do
                    if i == 0 then
                        bat_info.status = v
                    elseif i == 1 then
                        bat_info.energy_now = tonumber(v)
                    elseif i == 2 then
                        bat_info.energy_full = tonumber(v)
                    end
                    i = i + 1
                end

                -- calculate percentage
                bat_info.percentage = math.floor((bat_info.energy_now / bat_info.energy_full) * 100)

                -- update popup
                -- if net_info.popup.speed_row.visible then
                --     update_speed_popup(net_info)
                -- end

                -- calculate total percentage
                local total_energy_full = 0
                local total_energy_now = 0
                for _, v in pairs(info.batteries) do
                    total_energy_full = total_energy_full + v.energy_full
                    total_energy_now = total_energy_now + v.energy_now
                end
                info.percentage = math.floor((total_energy_now / total_energy_full) * 100)

                -- update widget
                update_battery_widget()
            end
        )
    end

    local function update()
        -- check batteries in the system
        awful.spawn.easy_async(
            "ls /sys/class/power_supply",
            function(stdout, _, _, _)
                -- iterate all batteries
                local i = 1
                for name in stdout:gmatch("[^\r\n]+") do
                    if string.match(name, "BAT%w+") then
                        if not info.batteries[i] then
                            -- add new battery info since there isn't any
                            info.batteries[i] =
                                {
                                    name = name,
                                    energy_full = 0,
                                    energy_now = 0,
                                    percentage = 0,
                                    status = "N/A"
                                }
                            -- local bat_info = info.batteries[i]

                            -- add popup row to layout
                            -- popup_speed:get_widget():get_children_by_id("row_container")[1]:add(bat_info.popup.speed_row)
                        end

                        local bat_info = info.batteries[i]

                        -- check battery state
                        update_battery_state(bat_info)

                        -- continue
                        i = i + 1
                    elseif string.match(name, "A%w+") then
                        if not info.ac then
                            -- add ac info since there isn't any
                            info.ac =
                                {
                                    name = name
                                }
                        end

                        -- check battery state
                        update_ac_state()
                    end
                end
            end
        )
    end

    -- signals
    widget:connect_signal(
        'mouse::enter',
        function()
            naughty.destroy(notification)
            notification = naughty.notify(
                {
                    title = "Battery time",
                    text = notification_text
                })
        end
    )

    widget:connect_signal(
        'mouse::leave',
        function()
            naughty.destroy(notification)
            notification = nil
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
