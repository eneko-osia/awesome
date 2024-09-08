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
    local memory = wibox.widget(
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
                                {
                                    {
                                        {
                                            align  = "left",
                                            text = "memory",
                                            valign = "center",
                                            widget = wibox.widget.textbox
                                        },
                                        layout = wibox.container.margin(_, beautiful_dpi(5), _, beautiful_dpi(5), _)
                                    },
                                    {
                                        {
                                            border_color = beautiful.bg_focus,
                                            border_width = beautiful_dpi(2),
                                            colors =
                                                {
                                                    "#FFFF00",
                                                    "#00FF00",
                                                    "#FF0000"
                                                },
                                            id = "memory",
                                            widget = wibox.widget.piechart
                                        },
                                        layout = wibox.container.margin(_, _, _, _, _)
                                    },
                                    layout = wibox.layout.fixed.vertical
                                },
                                bg = beautiful.bg_focus,
                                forced_height = beautiful_dpi(180),
                                forced_width = beautiful_dpi(320),
                                shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(5)) end,
                                widget = wibox.container.background,
                            },
                            layout = wibox.container.margin(_, beautiful_dpi(5), beautiful_dpi(5), beautiful_dpi(5), beautiful_dpi(5))
                        },
                        {
                            {
                                {
                                    {
                                        {
                                            align  = "left",
                                            text = "swap",
                                            valign = "center",
                                            widget = wibox.widget.textbox
                                        },
                                        layout = wibox.container.margin(_, beautiful_dpi(5), _, beautiful_dpi(5), _)
                                    },
                                    {
                                        {
                                            border_color = beautiful.bg_focus,
                                            border_width = beautiful_dpi(2),
                                            colors =
                                                {
                                                    "#00FF00",
                                                    "#FF0000"
                                                },
                                            id = "swap",
                                            widget = wibox.widget.piechart
                                        },
                                        layout = wibox.container.margin(_, _, _, _, _)
                                    },
                                    layout = wibox.layout.fixed.vertical
                                },
                                bg = beautiful.bg_focus,
                                forced_height = beautiful_dpi(180),
                                forced_width = beautiful_dpi(320),
                                shape = function(cr, width, height) gears.shape.rounded_rect(cr, beautiful_dpi(width), beautiful_dpi(height), beautiful_dpi(5)) end,
                                widget = wibox.container.background,
                            },
                            layout = wibox.container.margin(_, beautiful_dpi(5), beautiful_dpi(5), _, beautiful_dpi(5))
                        },
                        layout = wibox.layout.fixed.vertical
                    },
                    bg = beautiful.bg_reset,
                    shape = gears.shape.rectangle,
                    widget = wibox.container.background
                }
        }
    )
    local terminal = args.terminal or "xterm"

    -- methods
    local function update_popup()
        local popup_widget = popup:get_widget()
        popup_widget:get_children_by_id("memory")[1].data_list =
            {
                {
                    string.format("buffers %d%%", math.floor((info.buffers + info.cached) / info.total * 100)),
                    info.buffers + info.cached
                },
                {
                    string.format("free %d%%", math.floor((info.free + info.sreclaimable) / info.total * 100)),
                    info.free + info.sreclaimable
                },
                {
                    string.format("used %d%%", math.floor(info.used / info.total * 100)),
                    info.used
                }
            }

        popup_widget:get_children_by_id("swap")[1].data_list =
            {
                {
                    string.format("free %d%%", math.floor(info.swap_free / info.swap_total * 100)),
                    info.swap_free
                },
                {
                    string.format("used %d%%", math.floor(info.swap_used / info.swap_total * 100)),
                    info.swap_used
                }
            }
    end

    local function update_widget()
        local text_widget = memory:get_children_by_id("text")[1]
        text_widget:set_markup(string.format(" %d%% ", math.floor(info.used / info.total * 100)))
    end

    local function update()
        awful.spawn.easy_async(
            string.format("cat /proc/meminfo"),
            function(stdout, _, _, _)
                for line in stdout:gmatch("[^\r\n]+") do
                    for k, v in line:gmatch("([%a]+):[%s]+([%d]+).+") do
                        if     k == "Buffers"      then info.buffers        = math.floor(v / 1024 + 0.5)
                        elseif k == "Cached"       then info.cached         = math.floor(v / 1024 + 0.5)
                        elseif k == "MemFree"      then info.free           = math.floor(v / 1024 + 0.5)
                        elseif k == "MemTotal"     then info.total          = math.floor(v / 1024 + 0.5)
                        elseif k == "SReclaimable" then info.sreclaimable   = math.floor(v / 1024 + 0.5)
                        elseif k == "SwapFree"     then info.swap_free      = math.floor(v / 1024 + 0.5)
                        elseif k == "SwapTotal"    then info.swap_total     = math.floor(v / 1024 + 0.5)
                        end
                    end
                end
                info.used = info.total - info.free - info.buffers - info.cached - info.sreclaimable
                info.swap_used = info.swap_total - info.swap_free
                if popup.visible then
                    update_popup()
                end
                update_widget()
            end
        )
    end

    -- bindings
    memory:buttons(gears.table.join(
        awful.button(
            {},
            1,
            _,
            function()
                awful.spawn.easy_async(
                    terminal .." -e htop",
                    function(stdout)
                    end
                )
            end
        )
    ))

    -- signals
    memory:connect_signal(
        "button::press",
        function(c)
            c:set_bg(beautiful.bg_focus)
        end
    )

    memory:connect_signal(
        "button::release",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )

    memory:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_normal)

            update_popup()
            popup:move_next_to(mouse.current_widget_geometry)
            popup.visible = true
        end
    )

    memory:connect_signal(
        "mouse::leave",
        function(c)
            popup.visible = false
            c:set_bg(beautiful.bg_reset)
        end
    )
    -- timers
    gears_timer(
        {
            timeout = 2,
            autostart = true,
            call_now = true,
            callback = update
        }
    )

    return memory
end
-- }}}

return factory
