-- modules/rules.lua
-- Window behavior rules for AwesomeWM

local awful = require("awful")
local beautiful = require("beautiful")
local variables = require("modules.variables")

-- Get client keys and buttons from keys module
local keys = require("modules.keybindings")
local clientkeys = keys.clientkeys
local clientbuttons = keys.clientbuttons

-- Define rules
local rules = {
    -- Default rule for all clients

    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.centered + awful.placement.no_overlap + awful.placement.no_offscreen,
            size_hints_honor = false,
          --width = 1600,
          --height = 900
        }
    },
    -- Floating clients
    {
        rule_any = {
            class = {
                "qimgv",
                "mpv",
                "Xarchiver",
                "Tilix",
                "Galculator",
                "Lxappearance",
                "Pavucontrol"
            }
        },
        properties = { 
            floating = true
        },
        callback = function(c)
            awful.placement.centered(c)
        end
    },
    -- Scratchpad terminals and apps
    {
        rule_any = { 
            instance = {
                "scratchpad",
                "scratchpad-terminal",
                "scratchpad-ranger",
                "scratchpad-pulsemixer",
                "scratchpad-music",
              --"pavucontrol"
            },
            class = {
                "St-scratchpad"
            }
        },
        properties = {
            floating = true,
            sticky = true,
            ontop = true,
            skip_taskbar = true,
            requests_no_titlebar = true
        }
    },

    -- pavucontrol window

    {
        rule_any = {
            instance = {
                "pavucontrol"
            },
            class = {
                "St-scratchpad"
            }
        },
        properties = {
            floating = true,
            sticky = true,
            ontop = true,
            skip_taskbar = true,
            titlebars_enabled = true,
            requests_no_titlebar = false
        }
    },

    -- Galculator specific size
    {
        rule = { class = "Galculator" },
        properties = { 
            floating = true,
            titlebars_enabled = true,
            width = 900,
            height = 600
        },
        callback = function(c)
            awful.placement.centered(c)
        end
    },
    -- Disable titlebars by default for normal clients and dialogs
    {
        rule_any = { type = { "dialog", "floating", } },
        properties = { titlebars_enabled = true }
    },
    {
        rule = { class = "dolphin" },
        properties = { titlebars_enabled = true }
    },
    {
        rule = { class = "kate" },
        properties = { titlebars_enabled = true }
    },
    {
        rule = { class = "Brave" },
        properties = { titlebars_enabled = true }
    },
    -- Assign applications to specific tags
    {
        rule = { class = "GitHub Desktop" },
        properties = { screen = 1, tag = "2", switchtotag = true }
    },
    {
        rule = { class = "Gimp" },
        properties = { screen = 1, tag = "9", switchtotag = true }
    },
    {
        rule = { class = "obs" },
        properties = { screen = 1, tag = "10", switchtotag = true }
    },
    {
        rule = { class = "discord" },
        properties = { screen = 1, tag = "8", switchtotag = true }
    },

    {
        rule = { floating = true },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_focus,
            titlebars_enabled = true,  -- Enable titlebar for all floating windows
        }
    },

--    {
--        rule = { class = "Kitty" },  -- Example: Apply to Firefox
--        properties = {
--            floating = true,
--            border_width = beautiful.border_width or 2,
--            border_color = beautiful.border_focus or "#ff0000",
--            titlebars_enabled = true,
--        }
--    },

}

-- Initialize function
local function init()
    -- Set the rules
    awful.rules.rules = rules
end

-- Return the module
return {
    rules = rules,
    init = init
}
