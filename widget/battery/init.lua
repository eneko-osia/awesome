-- {{{ Standard libraries
local awful         = require("awful")
local beautiful     = require("beautiful")
local beautiful_dpi = require("beautiful.xresources").apply_dpi
local gears         = require("gears")
local wibox         = require("wibox")
-- }}}

-- {{{ Variable definitions
local UNKNOWN_TYPE  = 0
local AC_TYPE       = 1
local ADP_TYPE      = 2
local BATTERY_TYPE  = 3
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
            power_supplies = {},
            power_supplies_updating = 0,
            percentage = 0,
            status = "N/A"
        }
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
                    id = "icon_container",
                    layout = wibox.container.margin(_, beautiful_dpi(4), beautiful_dpi(1), beautiful_dpi(3), beautiful_dpi(3))
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

    local function update_popup(power_info)
        local function _set_text(container, index, value)
            local widget = container:get_children()[index]:get_children()[1]:get_children()[1]
            widget:set_markup(value)
        end

        local rows_container_widget = power_info.popup.row:get_children()[1]
        _set_text(rows_container_widget, 2, power_info.status)
        _set_text(rows_container_widget, 3, string.format("%d%%", power_info.percentage))
    end

    local function update_widget()
        local icon_widget = widget:get_children_by_id("icon")[1]
        local text_widget = widget:get_children_by_id("text")[1]
        if (icon_widget ~= nil and text_widget ~= nil) then
            if info.ac.status == true then
                icon_widget:set_image(icons.ac)
                text_widget:set_markup(" " .. info.percentage .. "%" .. " ")
            else
                if info.percentage == 100 then
                    icon_widget:set_image(icons.ac)
                    text_widget:set_markup(" " .. info.percentage .. "%" .. " ")
                elseif info.percentage > 50 then
                    icon_widget:set_image(icons.full)
                    text_widget:set_markup(" " .. info.percentage .. "%" .. " ")
                elseif info.percentage > 15 then
                    icon_widget:set_image(icons.low)
                    text_widget:set_markup(string.format("<span foreground='%s'> %s </span>", beautiful.fg_focus, info.percentage))
                else
                    icon_widget:set_image(icons.empty)
                    text_widget:set_markup(string.format("<span foreground='%s'> %s </span>", beautiful.fg_urgent, info.percentage))
                end
            end
        end
    end

    local function update_ac_state(power_info)
        power_info.percentage = 100
        power_info.status = "Connected"

        -- decrease the number of power supplies updating
        -- info.power_supplies_updating = info.power_supplies_updating - 1

        -- update popup
        if popup.visible then
            update_popup(power_info)
        end
    end

    local function update_adp_state(power_info)
        awful.spawn.easy_async(
            string.format("cat /sys/class/power_supply/%s/online", power_info.power_supply),
            function(stdout, _, _, _)
                -- read data from command results
                power_info.status = (tonumber(stdout) == 1) and "On" or "Off"

                -- decrease the number of power supplies updating
                info.power_supplies_updating = info.power_supplies_updating - 1

                -- update popup
                if popup.visible then
                    update_popup(power_info)
                end
            end
        )
    end

    local function update_battery_state(power_info)
        awful.spawn.easy_async(
            string.format("cat \
                /sys/class/power_supply/%s/status \
                /sys/class/power_supply/%s/energy_now \
                /sys/class/power_supply/%s/energy_full",
                power_info.power_supply,
                power_info.power_supply,
                power_info.power_supply),
            function(stdout, _, _, _)
                -- read data from command results
                local i = 0
                for v in stdout:gmatch("[^\r\n]+") do
                    if i == 0 then
                        power_info.status = v
                    elseif i == 1 then
                        power_info.energy_now = tonumber(v)
                    elseif i == 2 then
                        power_info.energy_full = tonumber(v)
                    end
                    i = i + 1
                end

                -- calculate percentage
                power_info.percentage = math.floor((power_info.energy_now / power_info.energy_full) * 100)

                -- decrease the number of power supplies updating
                info.power_supplies_updating = info.power_supplies_updating - 1

                -- update popup
                if popup.visible then
                    update_popup(power_info)
                end

                -- update widget if all power supplies update has been completed
                if info.power_supplies_updating == 0 then
                    -- calculate total percentage
                    local total_energy_full = 0
                    local total_energy_now = 0
                    for _, v in pairs(info.power_supplies) do
                        total_energy_full = total_energy_full + v.energy_full
                        total_energy_now = total_energy_now + v.energy_now
                    end
                    info.percentage = math.floor(((total_energy_now / total_energy_full) * 100) + 0.5)

                    -- update widget
                    update_widget()
                end
            end
        )
    end

    local function update()
        -- check that previous update has finished
        if info.power_supplies_updating == 0 then

            -- check power supplies in the system
            awful.spawn.easy_async(
                "ls /sys/class/power_supply",
                function(stdout, _, _, _)
                    -- get power supplies
                    local power_supplies = {}
                    for power_supply in stdout:gmatch("[^\r\n]+") do
                        table.insert(power_supplies, power_supply)
                    end

                    -- if not power supply add default AC power supply
                    if #power_supplies == 0 then
                        table.insert(power_supplies, "AC")
                    end

                    -- set number of power supplies updating
                    info.power_supplies_updating = #power_supplies

                    -- iterate all power supplies
                    for i, power_supply in ipairs(power_supplies) do
                        if not info.power_supplies[i] then
                            -- add new power supply info since there isn't any
                            info.power_supplies[i] =
                                {
                                    energy_full = 0,
                                    energy_now = 0,
                                    percentage = 0,
                                    popup =
                                        {
                                            row = create_popup_row(power_supply)
                                        },
                                    power_supply = power_supply,
                                    status = "N/A",
                                    type = UNKNOWN_TYPE
                                }
                            local power_info = info.power_supplies[i]

                            -- set power supply type
                            if string.match(power_supply, "AC") then
                                power_info.type = AC_TYPE
                            elseif string.match(power_supply, "ADP%w+") then
                                power_info.type = ADP_TYPE
                            elseif string.match(power_supply, "BAT%w+") then
                                power_info.type = BATTERY_TYPE
                            end

                            -- add popup row to layout
                            popup:get_widget():get_children_by_id("row_container")[1]:add(power_info.popup.row)
                        end

                        local power_info = info.power_supplies[i]

                        -- update power supply state
                        if power_info.type == AC_TYPE then
                            -- check ac state
                            update_ac_state(power_info)
                        elseif power_info.type == ADP_TYPE then
                            -- check adp state
                            update_adp_state(power_info)
                        elseif power_info.type == BATTERY_TYPE then
                            -- check battery state
                            update_battery_state(power_info)
                        end
                    end
                end
            )
        end
    end

    -- signals
    widget:connect_signal(
        'mouse::enter',
        function(c)
            c:set_bg(beautiful.bg_normal)

            for _, v in pairs(info.power_supplies) do
                update_popup(v)
            end
            popup:move_next_to(mouse.current_widget_geometry)
            popup.visible = true
        end
    )

    widget:connect_signal(
        'mouse::leave',
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
