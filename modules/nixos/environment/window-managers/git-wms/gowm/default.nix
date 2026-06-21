{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.gowm;
  gowm = pkgs.callPackage ./gowm.nix {
    conf = ''
package main

import (
	"github.com/jezek/xgb/xproto"
)

// Catppuccin Frappe color palette
const (
	// Base colors
	ColorBase   = 0x303446
	ColorMantle = 0x292c3c
	ColorCrust  = 0x232634

	// Surface colors
	ColorSurface0 = 0x414559
	ColorSurface1 = 0x51576d
	ColorSurface2 = 0x626880

	// Text colors
	ColorText     = 0xc6d0f5
	ColorSubtext0 = 0xa5adce
	ColorSubtext1 = 0xb5bfe2

	// Accent colors
	ColorRosewater = 0xf2d5cf
	ColorFlamingo  = 0xeebebe
	ColorPink      = 0xf4b8e4
	ColorMauve     = 0xca9ee6
	ColorRed       = 0xe78284
	ColorMaroon    = 0xea999c
	ColorPeach     = 0xef9f76
	ColorYellow    = 0xe5c890
	ColorGreen     = 0xa6d189
	ColorTeal      = 0x81c8be
	ColorSky       = 0x99d1db
	ColorSapphire  = 0x85c1dc
	ColorBlue      = 0x8caaee
	ColorLavender  = 0xbabbf1

	// Overlay colors
	ColorOverlay0 = 0x737994
	ColorOverlay1 = 0x838ba7
	ColorOverlay2 = 0x949cbb
)

// Config holds all window manager configuration
type Config struct {
	// Appearance
	BorderWidth          uint16
	GapWidth             uint16 // Deprecated: use OuterGap and InnerGap
	OuterGap             uint16 // Gap between windows and screen edge
	InnerGap             uint16 // Gap between windows
	FocusedBorderColor   uint32
	UnfocusedBorderColor uint32
	UrgentBorderColor    uint32

	// Behavior
	FocusFollowsMouse bool

	// Modifier key (Mod4 = Super/Windows key)
	ModKey uint16

	// Default applications
	Terminal string
	Launcher string

	// Keybindings
	Keybindings map[KeyCombo]Action
}

// KeyCombo represents a key combination (modifier + keycode)
type KeyCombo struct {
	Mod     uint16
	Keycode xproto.Keycode
}

// Action is a function that performs a window manager action
type Action func(*WindowManager)

// DefaultConfig returns the default configuration matching your xmonad setup
func DefaultConfig() *Config {
	return &Config{
		BorderWidth:          2,
		OuterGap:             4, // Gap between windows and screen edge
		InnerGap:             4, // Gap between windows
		FocusedBorderColor:   ColorLavender,
		UnfocusedBorderColor: ColorSurface0,
		UrgentBorderColor:    ColorRed, // Red for urgent windows
		FocusFollowsMouse:    true,
		ModKey:               xproto.ModMask4, // Super key
		Terminal:             "kitty",
		Launcher:             "sh ~/.config/rofi/scripts/rofi-main.sh",
	}
}

// SetupKeybindings configures all keybindings (called after WM has keysym mapping)
func (wm *WindowManager) SetupKeybindings() {
	mod := wm.config.ModKey
	shift := uint16(xproto.ModMaskShift)
	ctrl := uint16(xproto.ModMaskControl)

	wm.config.Keybindings = map[KeyCombo]Action{
		// Scratchpad
		{mod, wm.keysymToKeycode(XK_grave)}: ActionToggleScratchpad,

		// Applications
		{mod, wm.keysymToKeycode(XK_Return)}:         ActionSpawn(wm.config.Terminal),
		{mod | shift, wm.keysymToKeycode(XK_Return)}: ActionSpawn(wm.config.Terminal + " --class floating"),
		{mod | shift, wm.keysymToKeycode(XK_f)}:      ActionSpawn("thunar"),
		{mod, wm.keysymToKeycode(XK_r)}:              ActionSpawn(wm.config.Launcher),
		{mod, wm.keysymToKeycode(XK_d)}:              ActionSpawn(wm.config.Launcher),

		// Window management
		{mod, wm.keysymToKeycode(XK_q)}:         ActionKill,
		{mod | shift, wm.keysymToKeycode(XK_q)}: ActionKillAll,
		{mod, wm.keysymToKeycode(XK_g)}:         ActionGridSelect,
		{mod | shift, wm.keysymToKeycode(XK_g)}: ActionGridSelectWorkspaces,
		{mod, wm.keysymToKeycode(XK_p)}:         ActionGridSelectSpawn,

		// Focus
		{mod, wm.keysymToKeycode(XK_j)}:   ActionFocusNext,
		{mod, wm.keysymToKeycode(XK_k)}:   ActionFocusPrev,
		{mod, wm.keysymToKeycode(XK_Tab)}: ActionFocusNext,
		{mod, wm.keysymToKeycode(XK_m)}:   ActionFocusMaster,

		// Swap
		{mod | shift, wm.keysymToKeycode(XK_j)}: ActionSwapNext,
		{mod | shift, wm.keysymToKeycode(XK_k)}: ActionSwapPrev,

		// Resize
		{mod, wm.keysymToKeycode(XK_h)}:      ActionShrink,
		{mod, wm.keysymToKeycode(XK_l)}:      ActionExpand,
		{mod, wm.keysymToKeycode(XK_comma)}:  ActionIncMaster,
		{mod, wm.keysymToKeycode(XK_period)}: ActionDecMaster,

		// Layout
		{mod, wm.keysymToKeycode(XK_space)}:         ActionNextLayout,
		{mod | shift, wm.keysymToKeycode(XK_space)}: ActionResetLayout,
		{mod, wm.keysymToKeycode(XK_b)}:             ActionToggleStruts,

		// Floating
		{mod, wm.keysymToKeycode(XK_s)}: ActionSink,

		// Restart/Quit
		{mod | shift, wm.keysymToKeycode(XK_r)}: ActionRestart,
		{mod | ctrl, wm.keysymToKeycode(XK_q)}:  ActionQuit,

		// Workspaces 1-9
		{mod, wm.keysymToKeycode(XK_1)}: ActionSwitchWorkspace(0),
		{mod, wm.keysymToKeycode(XK_2)}: ActionSwitchWorkspace(1),
		{mod, wm.keysymToKeycode(XK_3)}: ActionSwitchWorkspace(2),
		{mod, wm.keysymToKeycode(XK_4)}: ActionSwitchWorkspace(3),
		{mod, wm.keysymToKeycode(XK_5)}: ActionSwitchWorkspace(4),
		{mod, wm.keysymToKeycode(XK_6)}: ActionSwitchWorkspace(5),
		{mod, wm.keysymToKeycode(XK_7)}: ActionSwitchWorkspace(6),
		{mod, wm.keysymToKeycode(XK_8)}: ActionSwitchWorkspace(7),
		{mod, wm.keysymToKeycode(XK_9)}: ActionSwitchWorkspace(8),

		// Move to workspace 1-9
		{mod | shift, wm.keysymToKeycode(XK_1)}: ActionMoveToWorkspace(0),
		{mod | shift, wm.keysymToKeycode(XK_2)}: ActionMoveToWorkspace(1),
		{mod | shift, wm.keysymToKeycode(XK_3)}: ActionMoveToWorkspace(2),
		{mod | shift, wm.keysymToKeycode(XK_4)}: ActionMoveToWorkspace(3),
		{mod | shift, wm.keysymToKeycode(XK_5)}: ActionMoveToWorkspace(4),
		{mod | shift, wm.keysymToKeycode(XK_6)}: ActionMoveToWorkspace(5),
		{mod | shift, wm.keysymToKeycode(XK_7)}: ActionMoveToWorkspace(6),
		{mod | shift, wm.keysymToKeycode(XK_8)}: ActionMoveToWorkspace(7),
		{mod | shift, wm.keysymToKeycode(XK_9)}: ActionMoveToWorkspace(8),

		// Developer tools
		{mod | shift, wm.keysymToKeycode(XK_l)}: ActionSpawn("kitty -e lazydocker"),
		{mod | shift, wm.keysymToKeycode(XK_b)}: ActionSpawn("kitty -e btop"),

		// Telegram
		{mod | ctrl, wm.keysymToKeycode(XK_t)}: ActionSpawn("$HOME/Telegram/Telegram"),

		// Screenshots (using rofi_screenshot)
		{0, wm.keysymToKeycode(XK_Print)}:       ActionSpawn("sh $HOME/.config/bspwm/scripts/rofi_screenshot"),
		{mod, wm.keysymToKeycode(XK_Print)}:     ActionSpawn("sh $HOME/.config/bspwm/scripts/rofi_screenshot"),
		{mod | shift, wm.keysymToKeycode(XK_s)}: ActionSpawn("sh $HOME/.config/bspwm/scripts/rofi_screenshot"),

		// Rofi scripts
		{mod, wm.keysymToKeycode(XK_w)}:         ActionSpawn("sh ~/.config/rofi/scripts/rofi-window.sh"),
		{mod | shift, wm.keysymToKeycode(XK_p)}: ActionSpawn("rofi -show run"),
		{mod, wm.keysymToKeycode(XK_x)}:         ActionSpawn("rofi -show ssh"),

		// Config editing
		{mod, wm.keysymToKeycode(XK_e)}:        ActionSpawn("kitty -e nvim ~/.config/gowm/"),
		{mod | ctrl, wm.keysymToKeycode(XK_e)}: ActionSpawn("kitty -e nvim ~/.config"),

		// Keyboard layout
		{mod, wm.keysymToKeycode(XK_p)}: ActionSpawn("sh $HOME/.scripts/change-layout-br"),
		{mod, wm.keysymToKeycode(XK_u)}: ActionSpawn("sh $HOME/.scripts/change-layout-us"),

		// Compositor toggle
		{mod | ctrl, wm.keysymToKeycode(XK_d)}: ActionSpawn("killall picom || picom --config ~/.config/picom/picom.conf"),

		// Gaming mode
		{mod | shift, wm.keysymToKeycode(XK_g)}: ActionSpawn("~/.xmonad/gaming-mode.sh"),

		// Volume (XF86 keys)
		{0, wm.keysymToKeycode(XF86XK_AudioMute)}:        ActionSpawn("~/.config/eww/scripts/volume toggle"),
		{0, wm.keysymToKeycode(XF86XK_AudioLowerVolume)}: ActionSpawn("~/.config/eww/scripts/volume down"),
		{0, wm.keysymToKeycode(XF86XK_AudioRaiseVolume)}: ActionSpawn("~/.config/eww/scripts/volume up"),

		// Volume (Fn keys fallback)
		{mod, wm.keysymToKeycode(XK_F1)}: ActionSpawn("~/.config/eww/scripts/volume toggle"),
		{mod, wm.keysymToKeycode(XK_F2)}: ActionSpawn("~/.config/eww/scripts/volume down"),
		{mod, wm.keysymToKeycode(XK_F3)}: ActionSpawn("~/.config/eww/scripts/volume up"),

		// Brightness (XF86 keys)
		{0, wm.keysymToKeycode(XF86XK_MonBrightnessUp)}:   ActionSpawn("xbacklight -inc 5"),
		{0, wm.keysymToKeycode(XF86XK_MonBrightnessDown)}: ActionSpawn("xbacklight -dec 5"),

		// Brightness (Fn keys fallback)
		{mod, wm.keysymToKeycode(XK_F5)}: ActionSpawn("xbacklight -dec 5"),
		{mod, wm.keysymToKeycode(XK_F6)}: ActionSpawn("xbacklight -inc 5"),

		// Media controls (XF86 keys)
		{0, wm.keysymToKeycode(XF86XK_AudioPlay)}: ActionSpawn("playerctl play-pause"),
		{0, wm.keysymToKeycode(XF86XK_AudioNext)}: ActionSpawn("playerctl next"),
		{0, wm.keysymToKeycode(XF86XK_AudioPrev)}: ActionSpawn("playerctl previous"),

		// Media controls (Fn keys fallback)
		{mod, wm.keysymToKeycode(XK_F7)}: ActionSpawn("playerctl previous"),
		{mod, wm.keysymToKeycode(XK_F8)}: ActionSpawn("playerctl play-pause"),
		{mod, wm.keysymToKeycode(XK_F9)}: ActionSpawn("playerctl next"),
	}
}
    '';

    rule = ''
package main

import (
	"log"
	"strings"

	"github.com/jezek/xgb/xproto"
)

// WindowRule defines rules for matching and handling windows
type WindowRule struct {
	Class     string // WM_CLASS to match (case-insensitive, supports prefix)
	Instance  string // WM_CLASS instance to match (optional)
	Title     string // Window title to match (optional, prefix match)
	Floating  *bool  // Force floating if set
	Workspace *int   // Assign to workspace if set
}

// DefaultRules returns the default window rules
func DefaultRules() []WindowRule {
	floating := true
	return []WindowRule{
		// Dialogs and popups
		{Class: "floating", Floating: &floating},
		{Class: "dialog", Floating: &floating},
		{Class: "popup", Floating: &floating},

		// Common floating applications
		{Class: "pavucontrol", Floating: &floating},
		{Class: "nm-connection-editor", Floating: &floating},
		{Class: "blueman-manager", Floating: &floating},
		{Class: "lxappearance", Floating: &floating},
		{Class: "qt5ct", Floating: &floating},
		{Class: "nwg-look", Floating: &floating},
		{Class: "file-roller", Floating: &floating},
		{Class: "ark", Floating: &floating},
		{Class: "gnome-calculator", Floating: &floating},
		{Class: "galculator", Floating: &floating},

		// Steam
		{Class: "steam", Title: "Friends List", Floating: &floating},
		{Class: "steam", Title: "Steam - News", Floating: &floating},

		// Games (CS2, etc.)
		{Class: "steam_app_730", Floating: &floating}, // CS2
		{Class: "cs2", Floating: &floating},
		{Class: "csgo_linux64", Floating: &floating},
		{Class: "hl2_linux", Floating: &floating},
		{Class: "SDL Application", Floating: &floating},

		// Media viewers
		{Class: "mpv", Floating: &floating},
		{Class: "feh", Floating: &floating},
		{Class: "imv", Floating: &floating},
		{Class: "eog", Floating: &floating},
		{Class: "gpicview", Floating: &floating},
		{Class: "sxiv", Floating: &floating},

		// Settings
		{Class: "gnome-control-center", Floating: &floating},
		{Class: "xfce4-settings", Floating: &floating},

		// Pinentry (GPG)
		{Class: "pinentry", Floating: &floating},
		{Class: "gcr-prompter", Floating: &floating},

		// Zoom
		{Class: "zoom", Floating: &floating},

		// Workspace assignments (examples - customize as needed)
		// {Class: "firefox", Workspace: intPtr(1)},
		// {Class: "discord", Workspace: intPtr(8)},
		// {Class: "spotify", Workspace: intPtr(9)},
	}
}

// intPtr is a helper to create int pointer for workspace assignment
func intPtr(i int) *int {
	return &i
}

// applyRules applies window rules to a window and returns float/workspace settings
func (wm *WindowManager) applyRules(win xproto.Window) (shouldFloat bool, workspace *int) {
	class := strings.ToLower(wm.getWMClass(win))
	instance := strings.ToLower(wm.getWMInstance(win))
	title := strings.ToLower(wm.getWindowTitle(win))

	log.Printf("Checking rules for window: class=%q instance=%q title=%q", class, instance, title)

	for _, rule := range wm.rules {
		if !wm.matchRule(rule, class, instance, title) {
			continue
		}

		log.Printf("Rule matched: class=%q", rule.Class)

		if rule.Floating != nil {
			shouldFloat = *rule.Floating
		}
		if rule.Workspace != nil {
			workspace = rule.Workspace
		}
	}

	return shouldFloat, workspace
}

// matchRule checks if a window matches a rule
func (wm *WindowManager) matchRule(rule WindowRule, class, instance, title string) bool {
	// Class must match if specified
	if rule.Class != "" {
		ruleClass := strings.ToLower(rule.Class)
		if !strings.HasPrefix(class, ruleClass) && !strings.Contains(class, ruleClass) {
			return false
		}
	}

	// Instance must match if specified
	if rule.Instance != "" {
		ruleInstance := strings.ToLower(rule.Instance)
		if !strings.HasPrefix(instance, ruleInstance) && !strings.Contains(instance, ruleInstance) {
			return false
		}
	}

	// Title must match if specified
	if rule.Title != "" {
		ruleTitle := strings.ToLower(rule.Title)
		if !strings.Contains(title, ruleTitle) {
			return false
		}
	}

	return true
}

// getWMInstance returns the WM_CLASS instance name
func (wm *WindowManager) getWMInstance(win xproto.Window) string {
	reply, err := xproto.GetProperty(wm.conn, false, win,
		xproto.AtomWmClass, xproto.AtomString, 0, 256).Reply()
	if err != nil || reply == nil || len(reply.Value) == 0 {
		return ""
	}

	// WM_CLASS format: instance\0class\0
	parts := strings.Split(string(reply.Value), "\x00")
	if len(parts) > 0 {
		return parts[0]
	}
	return ""
}

// getWindowTitle returns the window title
func (wm *WindowManager) getWindowTitle(win xproto.Window) string {
	// Try _NET_WM_NAME first
	reply, err := xproto.GetProperty(wm.conn, false, win,
		wm.atoms.NET_WM_NAME, wm.atoms.UTF8_STRING, 0, 1024).Reply()
	if err == nil && reply != nil && len(reply.Value) > 0 {
		return string(reply.Value)
	}

	// Fall back to WM_NAME
	reply, err = xproto.GetProperty(wm.conn, false, win,
		xproto.AtomWmName, xproto.AtomString, 0, 1024).Reply()
	if err == nil && reply != nil && len(reply.Value) > 0 {
		return string(reply.Value)
	}

	return ""
}
    '';
  };

in

{

  options = {
    services.xserver.windowManager.gowm = {
      enable = mkEnableOption "gowm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before gowm is started.
        '';
      };
      package = mkPackageOption pkgs "gowm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "gowm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "gowm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${gowm}/bin/gowm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.gowm = {
      enable = true;
      extraSessionCommands = '' '';
      package = gowm;
    };

  };

}
