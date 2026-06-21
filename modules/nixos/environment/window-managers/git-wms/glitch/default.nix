{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.glitch;
  glitch = pkgs.callPackage ./glitch.nix {
    conf = ''
// List of X11 keyboard symbol names.
// https://cgit.freedesktop.org/xorg/proto/x11proto/tree/keysymdef.h
// https://cgit.freedesktop.org/xorg/proto/x11proto/tree/XF86keysym.h

#ifndef CONFIG_H
#define CONFIG_H

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-variable"

#include "glitch.h"

#define MODKEY Mod4Mask   // Mod1Mask is Alt, Mod4Mask is Windows key.

static int border_size = 3;
static const char *active_border_color = "khaki";
static const char *inactive_border_color = "darkgray";
static const char *sticky_active_border_color = "violet";
static const char *sticky_inactive_border_color = "cyan";
static const char *on_top_active_border_color = "orange";
static const char *on_top_inactive_border_color = "darkorange";

static const char *widget_font = "Berkeley Mono:size=7:bold";
static const char *launcher_font_name = "Berkeley Mono:size=9:bold";
static const char *time_format = "%A %d.%m.%Y %H:%M:%S";
static const char *indicator_fg_color = "white";
static const char *indicator_bg_color = "blue";
static const char *mic_active_bg_color = "firebrick";
static const char *mic_muted_bg_color = "#222222";
static const char *mic_active_fg_color = "white";
static const char *mic_muted_fg_color = "white";
static const char *layout_tile_bg_color = "darkgreen";
static const char *layout_float_bg_color = "#222222";
static const char *layout_tile_fg_color = "white";
static const char *layout_float_fg_color = "white";

static const char *launcher_bg_color = "black";
static const char *launcher_border_color = "khaki";
static const char *launcher_fg_color = "white";
static const char *launcher_hl_bg_color = "khaki";
static const char *launcher_hl_fg_color = "black";
static int launcher_width = 800;
static int launcher_height = 600;

static Shortcut shortcuts[] = {
	/* Mask                 KeySym                    Shell command */
	{ MODKEY,               XK_Return,                "st -f 'Berkeley Mono:style=Bold:size=10' -g 110x60" },
	{ ControlMask,          XK_Escape,                "sh -c 'maim -s | xclip -selection clipboard -t image/png'" },
	{ MODKEY,               XK_w,                     "brave --new-window" },
	{ MODKEY,               XK_e,                     "thunar" },
	{ MODKEY,               XK_s,                     "xmagnify -s 1000 -z 3" },
	{ MODKEY,               XK_r,                     "simplescreenrecorder" },
	{ MODKEY,               XK_l,                     "xlock" },
	{ 0,                    XF86XK_AudioLowerVolume,  "pactl set-sink-volume @DEFAULT_SINK@ -5%" },
	{ 0,                    XF86XK_AudioRaiseVolume,  "pactl set-sink-volume @DEFAULT_SINK@ +5%" },
	{ 0,                    XF86XK_AudioMute,         "pactl set-sink-mute @DEFAULT_SINK@ toggle" },
	{ MODKEY,               XK_bracketright,          "pats -t" },
};

static Keybinds keybinds[] = {
	/* Mask                 KeySym      Function             Argument     */
	{ Mod1Mask,             XK_Tab,     cycle_active_window, { .i = 0 } },
	{ Mod1Mask | ShiftMask, XK_Tab,     cycle_active_window, { .i = 1 } },
	{ MODKEY,               XK_Left,    move_window_x,       { .i = -75 } },
	{ MODKEY,               XK_Right,   move_window_x,       { .i = +75 } },
	{ MODKEY,               XK_Up,      move_window_y,       { .i = -75 } },
	{ MODKEY,               XK_Down,    move_window_y,       { .i = +75 } },
	{ MODKEY | ShiftMask,   XK_Left,    resize_window_x,     { .i = -75 } },
	{ MODKEY | ShiftMask,   XK_Right,   resize_window_x,     { .i = +75 } },
	{ MODKEY | ShiftMask,   XK_Up,      resize_window_y,     { .i = -75 } },
	{ MODKEY | ShiftMask,   XK_Down,    resize_window_y,     { .i = +75 } },
	{ MODKEY | ControlMask, XK_Up,      window_snap_up,      { 0 }        },
	{ MODKEY | ControlMask, XK_Down,    window_snap_down,    { 0 }        },
	{ MODKEY | ControlMask, XK_Right,   window_snap_right,   { 0 }        },
	{ MODKEY | ControlMask, XK_Left,    window_snap_left,    { 0 }        },
	{ MODKEY,               XK_1,       goto_desktop,        { .i = 1 }   },
	{ MODKEY,               XK_2,       goto_desktop,        { .i = 2 }   },
	{ MODKEY,               XK_3,       goto_desktop,        { .i = 3 }   },
	{ MODKEY,               XK_4,       goto_desktop,        { .i = 4 }   },
	{ MODKEY,               XK_5,       goto_desktop,        { .i = 5 }   },
	{ MODKEY,               XK_6,       goto_desktop,        { .i = 6 }   },
	{ MODKEY,               XK_7,       goto_desktop,        { .i = 7 }   },
	{ MODKEY,               XK_8,       goto_desktop,        { .i = 8 }   },
	{ MODKEY,               XK_9,       goto_desktop,        { .i = 9 }   },
	{ MODKEY | ShiftMask,   XK_1,       send_window_to_desktop, { .i = 1 }   },
	{ MODKEY | ShiftMask,   XK_2,       send_window_to_desktop, { .i = 2 }   },
	{ MODKEY | ShiftMask,   XK_3,       send_window_to_desktop, { .i = 3 }   },
	{ MODKEY | ShiftMask,   XK_4,       send_window_to_desktop, { .i = 4 }   },
	{ MODKEY | ShiftMask,   XK_5,       send_window_to_desktop, { .i = 5 }   },
	{ MODKEY | ShiftMask,   XK_6,       send_window_to_desktop, { .i = 6 }   },
	{ MODKEY | ShiftMask,   XK_7,       send_window_to_desktop, { .i = 7 }   },
	{ MODKEY | ShiftMask,   XK_8,       send_window_to_desktop, { .i = 8 }   },
	{ MODKEY | ShiftMask,   XK_9,       send_window_to_desktop, { .i = 9 }   },
	{ MODKEY | ShiftMask,   XK_s,       toggle_pip,          { 0 }        },
	{ MODKEY | ShiftMask,   XK_t,       toggle_always_on_top,{ 0 }        },
	{ MODKEY,               XK_x,       window_hmaximize,    { 0 }        },
	{ MODKEY,               XK_z,       window_vmaximize,    { 0 }        },
	{ MODKEY,               XK_f,       toggle_fullscreen,   { 0 }        },
	{ MODKEY | ShiftMask,   XK_r,       reload,              { 0 }        },
	{ MODKEY,               XK_c,       center_window,       { 0 }        },
	{ MODKEY,               XK_m,       toggle_mic_mute,     { 0 }        },
	{ MODKEY,               XK_space,   toggle_layout,       { 0 }        },
	{ MODKEY,               XK_p,       toggle_launcher,     { 0 }        },
	{ MODKEY | ShiftMask,   XK_q,       quit,                { 0 }        },
	{ MODKEY,               XK_q,       close_window,        { 0 }        },
};

#pragma GCC diagnostic pop

#endif // CONFIG_H
    '';
  };

in

{

  options = {
    services.xserver.windowManager.glitch = {
      enable = mkEnableOption "glitch";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before glitch is started.
        '';
      };
      package = mkPackageOption pkgs "glitch" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "glitch" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "glitch";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${glitch}/bin/glitch &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.glitch = {
      enable = true;
      extraSessionCommands = '' '';
      package = glitch;
    };

  };

}
