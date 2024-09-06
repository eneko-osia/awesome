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
    local args = args or {}

    local icons = args.icons or {
        logo = nil
    }
    local mem_info = { total = 0 }
    local popup = awful.popup(
        {
            border_color = beautiful.bg_focus,
            border_width = 2,
            offset = { y = 2 },
            ontop = true,
            shape = gears.shape.rounded_rect,
            visible = false,
            widget =
                {
                    colors =
                        {
                            "#FFFF00",
                            "#00FF00",
                            "#FF0000"
                        },
                    forced_height = beautiful_dpi(180),
                    forced_width = beautiful_dpi(360),
                    widget = wibox.widget.piechart
                }
        }
    )
    local terminal = args.terminal or "xterm"

    local memory = wibox.widget({
            {
                {
                    {
                        id = "icon",
                        widget = wibox.widget.imagebox(icons.logo)
                    },
                    layout = wibox.container.margin(_, _, 2, _, _)
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
    local function update_popup()
        popup:get_widget().data_list =
            {
                {
                    string.format("buffers %d%%", math.floor(mem_info.buffers / mem_info.total * 100)),
                    mem_info.buffers
                },
                {
                    string.format("free %d%%", math.floor(mem_info.free / mem_info.total * 100)),
                    mem_info.free
                },
                {
                    string.format("used %d%%", math.floor(mem_info.used / mem_info.total * 100)),
                    mem_info.used
                }
            }
    end

    local function update_widget()
        local text_widget = memory:get_children_by_id("text")[1]
        text_widget:set_markup(string.format(" %d%% ", math.floor(mem_info.used / mem_info.total * 100)))
    end

    local function update()
        awful.spawn.easy_async(
            string.format("cat /proc/meminfo"),
            function(stdout, _, _, _)
                for mem_line in stdout:gmatch("[^\r\n]+") do
                    for k, v in mem_line:gmatch("([%a]+):[%s]+([%d]+).+") do
                        if     k == "Buffers"      then mem_info.buffers        = math.floor(v / 1024 + 0.5)
                        elseif k == "Cached"       then mem_info.cached         = math.floor(v / 1024 + 0.5)
                        -- elseif k == "MemAvailable" then mem_info.available      = math.floor(v / 1024 + 0.5)
                        elseif k == "MemFree"      then mem_info.free           = math.floor(v / 1024 + 0.5)
                        elseif k == "MemTotal"     then mem_info.total          = math.floor(v / 1024 + 0.5)
                        -- elseif k == "Shmem"        then mem_info.shmem          = math.floor(v / 1024 + 0.5)
                        elseif k == "SReclaimable" then mem_info.sreclaimable   = math.floor(v / 1024 + 0.5)
                        -- elseif k == "SwapCached"   then mem_info.swap_cached    = math.floor(v / 1024 + 0.5)
                        elseif k == "SwapFree"     then mem_info.swap_free      = math.floor(v / 1024 + 0.5)
                        elseif k == "SwapTotal"    then mem_info.swap_total     = math.floor(v / 1024 + 0.5)
                        end
                    end
                end
                mem_info.used = mem_info.total - mem_info.free - mem_info.buffers - mem_info.cached - mem_info.sreclaimable
                mem_info.swap_used = mem_info.swap_total - mem_info.swap_free

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
