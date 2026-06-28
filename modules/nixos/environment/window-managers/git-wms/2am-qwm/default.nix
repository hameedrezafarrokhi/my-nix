{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager._2am-qwm;
  _2am-qwm = pkgs.callPackage ./2am-qwm.nix {
    conf = ''
#ifndef CONFIG_H
#define CONFIG_H

#include "core/config_api.h"

// Color configuration
#define BORDER_WIDTH 2
#define BORDER_FOCUS 0x6699CC
#define BORDER_UNFOCUS 0x222222

#define TASKBAR_COLOR 0x444444
#define TASKBAR_FONT_COLOR 0xDDDDDD

#define LAUNCHER_WIDTH 600
#define LAUNCHER_POSITION_Y 200
#define LAUNCHER_BG_COLOR 0x444444
#define LAUNCHER_FG_COLOR 0x666666
#define LAUNCHER_FONT_COLOR 0xDDDDDD

// application spawning configuration
static inline void spawn_terminal(struct qwm_t *qwm)
{
    (void)qwm;
    spawn("kitty", NULL);
}

static inline void spawn_browser(struct qwm_t *qwm)
{
    (void)qwm;
    spawn("firefox", NULL);
}

static inline void spawn_screenshot(struct qwm_t *qwm)
{
    (void)qwm;
    spawn("flameshot", "gui", NULL);
}

static inline void spawn_fm(struct qwm_t *qwm)
{
    (void)qwm;
    spawn("thunar", NULL);
}

static const keybind_t my_keybinds[] = {
    {KEY_ALT | KEY_SHIFT, KEY_Q, quit_wm},
    {KEY_SUPER, KEY_Q, quit_application},

    {KEY_SUPER, KEY_1, workspace_1},
    {KEY_SUPER, KEY_2, workspace_2},
    {KEY_SUPER, KEY_3, workspace_3},
    {KEY_SUPER, KEY_4, workspace_4},
    {KEY_SUPER, KEY_5, workspace_5},

    {KEY_SUPER | KEY_SHIFT, KEY_1, move_to_workspace_1},
    {KEY_SUPER | KEY_SHIFT, KEY_2, move_to_workspace_2},
    {KEY_SUPER | KEY_SHIFT, KEY_3, move_to_workspace_3},
    {KEY_SUPER | KEY_SHIFT, KEY_4, move_to_workspace_4},
    {KEY_SUPER | KEY_SHIFT, KEY_5, move_to_workspace_5},

    {KEY_SUPER, KEY_L, toggle_layout},
    {KEY_SUPER, KEY_T, toggle_tile_orient},
    {KEY_SUPER, KEY_K, focus_next},
    {KEY_SUPER, KEY_J, focus_prev},
    {KEY_SUPER, KEY_S, swap_master},

    {KEY_SUPER, KEY_SPACE, spawn_launcher},
    {KEY_SUPER, KEY_ENTER, spawn_terminal},
    {KEY_SUPER, KEY_B, spawn_browser},
    {KEY_SUPER, KEY_P, spawn_screenshot},
    {KEY_SUPER, KEY_O, spawn_fm},
};

#endif // CONFIG_H

    '';
  };

in

{

  options = {
    services.xserver.windowManager._2am-qwm = {
      enable = mkEnableOption "2am-qwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before 2am-qwm is started.
        '';
      };
      package = mkPackageOption pkgs "2am-qwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "2am-qwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "2am-qwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${_2am-qwm}/bin/2am-qwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager._2am-qwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = _2am-qwm;
    };

  };

}
