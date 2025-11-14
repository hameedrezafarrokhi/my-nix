-- modules/wibar.lua

-- Load required libraries
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local widgets = require("modules.widgets")

-- Create wibar table
local wibar = {}

-- Wibar configuration
local config = {
    position = "top",
    height = 30,
    opacity = 1.0
}

-- Setup wibar for each screen
local function setup_wibar(s)
    -- Create taglist for this screen
    local taglist = widgets.create_taglist(s)
    
    -- Create layoutbox for this screen
    local layoutbox = widgets.create_layoutbox(s)
    
    -- Create a separator widget
    local separator = wibox.widget {
        markup = '<span color="' .. beautiful.bg_minimize .. '">|</span>',
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    -- TaskBar
  --s.mytasklist = awful.widget.tasklist {
  --    screen = s,
  --    filter = awful.widget.tasklist.filter.currenttags,
  --    buttons = widgets.tasklist_buttons
  --}

  s.mytasklist = awful.widget.tasklist {
      screen = s,
      filter = awful.widget.tasklist.filter.alltags,
      buttons = widgets.tasklist_buttons,
      widget_template = {
          {
              {
                  id            = 'icon_role',
                  widget        = wibox.widget.imagebox,
                  forced_width  = 24,  -- ← Fixed size
                      forced_height = 24,
              },
              left  = 8,
              right = 8,
              top   = 5,
              bottom= 4,
              widget = wibox.container.margin
          },
          id            = 'background_role',
          widget        = wibox.container.background,
          bg            = beautiful.bg_focus or "#5e81ac",
          shape         = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, 12)  -- ← 12px = strong round
          end,
          shape_clip    = true,
          forced_width  = 36,  -- ← Force container size
          forced_height = 32,
      },
      layout = {
          spacing = 4,
          layout  = wibox.layout.fixed.horizontal
      },
      style = {
          -- Explicitly override the background colors in the theme
          bg_focus = beautiful.gh_blue,  -- Use blue background for selected tag
          fg_focus = beautiful.gh_bg,    -- Dark text (matching clock widget)
          bg_occupied = "transparent",   -- Keep occupied tag background transparent
          fg_occupied = beautiful.gh_fg, -- Use theme's fg color for occupied tags
          bg_empty = "transparent",      -- Keep empty tag background transparent
          fg_empty = beautiful.gh_comment .. "80", -- Use theme's dimmed comment color
          shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, config.corner_radius)
          end,
      }

  }
    
    -- Create the wibar
    s.mywibar = awful.wibar({
        position = config.position,
        screen = s,
        height = config.height,
        bg = beautiful.bg_normal .. string.format("%x", math.floor(config.opacity * 255)),
    })
    
    -- Add widgets to the wibar
    s.mywibar:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 6,
            layoutbox,
            separator,
            taglist,
            separator,
        },
        { -- Middle widget
            s.mytasklist, -- Middle widget,
            layout = wibox.layout.fixed.horizontal,
            spacing = 2,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 6,
            {
                widgets.systray,
                top = 4,    -- Add top margin for vertical centering
                bottom = 4, -- Add bottom margin for vertical centering
                left = 8,   -- Add left padding
                right = 8,  -- Add right padding
                widget = wibox.container.margin
            },
            widgets.cpu_widget,
            widgets.mem_widget,
            widgets.volume_widget,
            widgets.clock_widget,
          --widgets.bluetooth_widget,
        },
    }
end

-- Initialize wibars
function wibar.init()
    -- Setup wibar for each screen
    awful.screen.connect_for_each_screen(function(s)
        setup_wibar(s)
    end)
    
    -- Handle screen changes (connecting/disconnecting monitors)
    screen.connect_signal("property::geometry", function(s)
        -- Recreate wibar when screen geometry changes
        if s.mywibar then
            s.mywibar:remove()
        end
        setup_wibar(s)
    end)
end

return wibar
