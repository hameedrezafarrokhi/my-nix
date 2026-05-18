{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.safwm;
  safwm = pkgs.callPackage ./safwm.nix {
#    conf = ''
##pragma once
#
##include <X11/XF86keysym.h>
#
##define MOD Mod4Mask
#
##define SCREEN_WIDTH 1366
##define SCREEN_HEIGHT 768
#
##define BORDER_NORMAL  0xff7a8478
##define BORDER_FOCUS   0xaad666aa
##define BORDER_NONE    0x00000000
##define BORDER_WIDTH   7
##define WINDOW_GAP     10
##define WINDOW_MOVE_PX 10
#
##define SNAP_RATIO 0.55
#
##define SAVE_SCREENSHOT "tee $HOME/Pictures/Screenshots/$(date +'Screenshot-from-%Y-%m-%d-%H-%M-%S').png | xclip -selection clipboard -t image/png"
##define SCREENSHOT_CMD           "maim -u | "    SAVE_SCREENSHOT
##define SELECTION_SCREENSHOT_CMD "maim -u -s | " SAVE_SCREENSHOT
#
##define MENU_CMD    "rofi -show drun -theme .config/rofi/themes/main.rasi"
##define TERM_CMD    "${config.my.default.terminal}"
##define BROWSER_CMD "${config.my.default.browser}"
#
##define BRIUP_CMD   "brightnessctl set 2%+ -n"
##define BRIDOWN_CMD "brightnessctl set 2%- -n"
#
##define VOLUP_CMD   "amixer sset Master 5%+"
##define VOLDOWN_CMD "amixer sset Master 5%-"
##define VOLMUTE_CMD "amixer sset Master toggle"
#
##define MEDIA_NEXT_CMD   "playerctl next"
##define MEDIA_PREV_CMD   "playerctl previous"
##define MEDIA_TOGGLE_CMD "playerctl play-pause"
#
##define BAR_HEIGHT (24 + 5)
#
##define ENABLE_BAR  "polybar-msg cmd show"
##define DISABLE_BAR "polybar-msg cmd hide"
#    '';

#    keys = ''
##include <X11/XF86keysym.h>
#
##include "safwm.h"
##include "config.h"
#
##define ALT Mod1Mask
#
#const Keymap keymaps[] = {
#    // general window manager keys
#    { MOD|ShiftMask, XK_q, quit_wm, {0}},
#
#
#    // window controls
#    { MOD, XK_c, center_win,     {0}},
#    { MOD, XK_m, maximize_win,   {0}},
#    { MOD, XK_f, fullscreen_win, {0}},
#    { MOD, XK_q, close_win,      {0}},
#
#    { MOD, XK_k, win_shrink, { .i = D_UP }},
#    { MOD, XK_j, win_shrink, { .i = D_DOWN }},
#    { MOD, XK_l, win_shrink, { .i = D_RIGHT }},
#    { MOD, XK_h, win_shrink, { .i = D_LEFT }},
#
#    { MOD|ShiftMask, XK_k, win_extend, { .i = D_UP }},
#    { MOD|ShiftMask, XK_j, win_extend, { .i = D_DOWN }},
#    { MOD|ShiftMask, XK_l, win_extend, { .i = D_RIGHT }},
#    { MOD|ShiftMask, XK_h, win_extend, { .i = D_LEFT }},
#
#    { MOD|ALT, XK_k, win_move, { .i = D_UP }},
#    { MOD|ALT, XK_j, win_move, { .i = D_DOWN }},
#    { MOD|ALT, XK_l, win_move, { .i = D_RIGHT }},
#    { MOD|ALT, XK_h, win_move, { .i = D_LEFT }},
#
#    { MOD, XK_Left,  win_swap_prev, {0}},
#    { MOD, XK_Right, win_swap_next, {0}},
#
#    // workspace controls
#    { MOD, XK_1, goto_ws, { .i = 0 }},
#    { MOD, XK_2, goto_ws, { .i = 1 }},
#    { MOD, XK_3, goto_ws, { .i = 2 }},
#    { MOD, XK_4, goto_ws, { .i = 3 }},
#
#    { MOD|ShiftMask, XK_1, move_win_to_ws, { .i = 0 }},
#    { MOD|ShiftMask, XK_2, move_win_to_ws, { .i = 1 }},
#    { MOD|ShiftMask, XK_3, move_win_to_ws, { .i = 2 }},
#    { MOD|ShiftMask, XK_4, move_win_to_ws, { .i = 3 }},
#
#    { MOD, XK_d, goto_next_ws, {0}},
#    { MOD, XK_a, goto_prev_ws, {0}},
#    { MOD|ShiftMask, XK_d, move_win_to_next_ws, {0}},
#    { MOD|ShiftMask, XK_a, move_win_to_prev_ws, {0}},
#
#    { Mod1Mask,           XK_Tab, win_next, {0}},
#    { Mod1Mask|ShiftMask, XK_Tab, win_prev, {0}},
#
#    { MOD, XK_v, ws_toggle_visibility, {0}},
#
#
#    // applications
#    { MOD, XK_s,      execute_cmd, { .com = MENU_CMD }},
#    { MOD, XK_Return, execute_cmd, { .com = TERM_CMD }},
#    { MOD, XK_b,      toggle_bar,  {0}},
#
#    { ShiftMask, XK_Print, execute_cmd, { .com = SCREENSHOT_CMD }},
#    { 0,         XK_Print, execute_cmd, { .com = SELECTION_SCREENSHOT_CMD }},
#
#    { 0, XF86XK_AudioRaiseVolume, execute_cmd, { .com = VOLUP_CMD }},
#    { 0, XF86XK_AudioLowerVolume, execute_cmd, { .com = VOLDOWN_CMD }},
#    { 0, XF86XK_AudioMute,        execute_cmd, { .com = VOLMUTE_CMD }},
#    { MOD, XK_F2, execute_cmd, { .com = VOLUP_CMD }},
#    { MOD, XK_F1, execute_cmd, { .com = VOLDOWN_CMD }},
#
#    { Mod1Mask, XK_F3, execute_cmd, { .com = MEDIA_NEXT_CMD }},
#    { Mod1Mask, XK_F2, execute_cmd, { .com = MEDIA_PREV_CMD }},
#    { Mod1Mask, XK_F1, execute_cmd, { .com = MEDIA_TOGGLE_CMD }},
#
#    { 0, XF86XK_MonBrightnessUp,   execute_cmd, { .com = BRIUP_CMD }},
#    { 0, XF86XK_MonBrightnessDown, execute_cmd, { .com = BRIDOWN_CMD }},
#    { MOD, XK_F4, execute_cmd, { .com = BRIUP_CMD }},
#    { MOD, XK_F3, execute_cmd, { .com = BRIDOWN_CMD }},
#};
#
#    '';


  };

in

{

  options = {
    services.xserver.windowManager.safwm = {
      enable = mkEnableOption "safwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before safwm is started.
        '';
      };
      package = mkPackageOption pkgs "safwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "safwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "safwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${safwm}/bin/safwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.safwm = {
      enable = true;
      extraSessionCommands = ''
        systemctl --user stop xremap.service
      '';
      package = safwm;
    };

  };

}
