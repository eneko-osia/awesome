-- {{{ Standard libraries
local awful         = require("awful")
local beautiful     = require("beautiful")
local beautiful_dpi = require("beautiful.xresources").apply_dpi
local gears         = require("gears")
local wibox         = require("wibox")
-- }}}

-- {{{ Calendar functions
local styles =
    {
        focus =
            {
                bg_color = "#1E2320", -- beautiful.bg_focus
                fg_color = "#F0DFAF", -- beautiful.fg_focus
                markup = function(t) return string.format("<b>%s</b>", t) end,
                shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(2)) end
            },
        focus_weekend =
            {
                bg_color = "#1E2320", -- beautiful.bg_focus
                fg_color = "#CC9393", -- beautiful.fg_urgent
                markup = function(t) return string.format("<b>%s</b>", t) end,
                shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(2)) end
            },
        header =
            {
                bg_color = "#3F3F3F", -- beautiful.bg_normal
                fg_color = "#DCDCCC", -- beautiful.fg_normal
                markup = function(t) return string.format("%s", t) end
            },
        month =
            {
                bg_color = "#3F3F3F", -- beautiful.bg_normal
                fg_color = "#DCDCCC", -- beautiful.fg_normal
                margins = beautiful_dpi(10)
            },
        normal =
            {
                bg_color = "#3F3F3F", -- beautiful.bg_normal
                fg_color = "#DCDCCC", -- beautiful.fg_normal
                markup = function(t) return string.format("%s", t) end,
                shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(2)) end
            },
        normal_weekend =
            {
                bg_color = "#3F3F3F", -- beautiful.bg_normal
                fg_color = "#CC9393", -- beautiful.fg_urgent
                markup = function(t) return string.format("%s", t) end,
                shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(2)) end
            },
        weekday =
            {
                bg_color = "#3F3F3F", -- beautiful.bg_normal
                fg_color = "#DCDCCC", -- beautiful.fg_normal
                markup = function(t) return string.format("%s", t) end
            }
    }

local function is_holiday(date)
    local bank_holidays =
        {
            { day = 12, month = 10, year = 2024 },
            { day = 1,  month = 11, year = 2024 },
            { day = 6,  month = 12, year = 2024 },
            { day = 25, month = 12, year = 2024 },

            { day = 1,  month = 1,  year = 2025 },
            { day = 6,  month = 1,  year = 2025 },
            { day = 17, month = 4,  year = 2025 },
            { day = 18, month = 4,  year = 2025 },
            { day = 21, month = 4,  year = 2025 },
            { day = 1,  month = 5,  year = 2025 },
            { day = 25, month = 7,  year = 2025 },
            { day = 31, month = 7,  year = 2025 },
            { day = 15, month = 8,  year = 2025 },
            { day = 16, month = 9,  year = 2025 },
            { day = 1,  month = 11, year = 2025 },
            { day = 6,  month = 12, year = 2025 },
            { day = 8,  month = 12, year = 2025 },
            { day = 25, month = 12, year = 2025 }
        }

    local holidays =
        {
            { day = 2,  month = 5,  year = 2025 },
            { day = 1,  month = 8,  year = 2025 },
            { day = 15, month = 9,  year = 2025 },
            { day = 26, month = 12, year = 2024 },
            { day = 27, month = 12, year = 2024 },
            { day = 28, month = 12, year = 2024 },
            { day = 29, month = 12, year = 2024 },
            { day = 30, month = 12, year = 2024 },
            { day = 31, month = 12, year = 2024 }
        }

    local function _is_holiday(holidays, date)
        for _, v in pairs(holidays) do
            if v.day == date.day and v.month == date.month and v.year == date.year then
                return true
            end
        end
    end

    if _is_holiday(bank_holidays, date) then
        return true
    end
    if _is_holiday(holidays, date) then
        return true
    end
    return false
end

local function decorate_cell(widget, flag, date)
    if flag == "focus" then
        local today = os.date('*t')
        if not (today.month == date.month and today.year == date.year) then
            flag = "normal"
        end
    end

    local d = { year = date.year, month = (date.month or 1), day = (date.day or 1) }
    local weekday = tonumber(os.date('%w', os.time(d)))
    if weekday == 0 or weekday == 6 or is_holiday(d) then
        flag = (flag == "focus" and "focus_weekend" or flag == "normal" and "normal_weekend" or flag)
    end

    local style = styles[flag] or {}
    if style.markup and widget.get_text and widget.set_markup then
        widget:set_markup(style.markup(widget:get_text()))
    end

    return wibox.widget(
        {
            {
                {
                    widget,
                    halign = 'center',
                    widget = wibox.container.place
                },
                margins = style.margins,
                widget = wibox.container.margin
            },
            bg = style.bg_color,
            fg = style.fg_color,
            shape = style.shape,
            shape_border_color = style.shape_border_color,
            shape_border_width = style.shape_border_width,
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
            logo = nil
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
                                date = os.date("*t"),
                                fn_embed = decorate_cell,
                                id = "calendar",
                                long_weekdays = true,
                                start_sunday = false,
                                week_numbers = false,
                                widget = wibox.widget.calendar.month
                            },
                            layout = wibox.layout.fixed.vertical
                        },
                        bg = beautiful.bg_reset,
                        shape = gears.shape.rectangle,
                        widget = wibox.container.background
                    }
            }
        )
    local widget = wibox.widget(
        {
            {
                {
                    {
                        widget = wibox.widget.imagebox(icons.logo)
                    },
                    layout = wibox.container.margin(_, _, _, _, _)
                },
                {
                    {
                        {
                            align  = "center",
                            forced_width = beautiful_dpi(128),
                            id = "text",
                            text = "N/A",
                            valign = "center",
                            widget = wibox.widget.textclock(" %a %d %b %H:%M:%S ", 1)
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
    function widget:move_date(months)
        local calendar_widget = popup:get_widget():get_children_by_id("calendar")[1]
        local current_date = calendar_widget:get_date()
        current_date.month = current_date.month + months
        calendar_widget:set_date(nil)
        calendar_widget:set_date(current_date)
    end

    function widget:set_date(date)
        local calendar_widget = popup:get_widget():get_children_by_id("calendar")[1]
        calendar_widget:set_date(nil)
        calendar_widget:set_date(date)
    end

    -- bindings
    widget:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                _,
                function()
                    widget:move_date(-1)
                end
            ),

            awful.button(
                {},
                2,
                _,
                function()
                    widget:set_date(os.date("*t"))
                end
            ),

            awful.button(
                {},
                3,
                _,
                function()
                    widget:move_date(1)
                end
            ),

            awful.button(
                {},
                4,
                _,
                function()
                    widget:move_date(-1)
                end
            ),

            awful.button(
                {},
                5,
                _,
                function()
                    widget:move_date(1)
                end
            ),

            awful.button(
                { "Shift" },
                1,
                _,
                function()
                    widget:move_date(-12)
                end
            ),

            awful.button(
                { "Shift" },
                3,
                _,
                function()
                    widget:move_date(12)
                end
            ),

            awful.button(
                { "Shift" },
                4,
                _,
                function()
                    widget:move_date(-12)
                end
            ),

            awful.button(
                { "Shift" },
                5,
                _,
                function()
                    widget:move_date(12)
                end
            )
        )
    )

    -- signals
    widget:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)

            widget:set_date(os.date("*t"))
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

    return widget
end
-- }}}

return factory
