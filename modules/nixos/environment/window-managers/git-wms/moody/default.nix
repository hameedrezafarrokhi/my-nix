{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.moody;
  moody = pkgs.callPackage ./moody.nix {
    conf = ''
#include "moody.h"

#define MODKEY Mod4Mask

const char* term[] = { "${config.my.default.terminal}", NULL };
const char* launcher[] = { "rofi","-show","drun","-theme",".config/rofi/themes/main.rasi", NULL };

Key keys[] = {
  { MODKEY, XK_Return, spawn, {.cmd = term} },
  { MODKEY, XK_space, spawn, {.cmd = launcher} },
  { MODKEY, XK_c, kill, {0} },
  { MODKEY, XK_Up, focusnext, {0} },
  { MODKEY, XK_Tab, focusnext, {0} },

  { MODKEY, XK_1, switchws, {.i = 1} },
  { MODKEY, XK_2, switchws, {.i = 2} },
  { MODKEY, XK_3, switchws, {.i = 3} },
  { MODKEY, XK_4, switchws, {.i = 4} },
  { MODKEY, XK_5, switchws, {.i = 5} },
  { MODKEY, XK_6, switchws, {.i = 6} },
  { MODKEY, XK_7, switchws, {.i = 7} },
  { MODKEY, XK_8, switchws, {.i = 8} },
  { MODKEY, XK_9, switchws, {.i = 9} },

  { MODKEY | ShiftMask, XK_1, sendws, {.i = 1} },
  { MODKEY | ShiftMask, XK_2, sendws, {.i = 2} },
  { MODKEY | ShiftMask, XK_3, sendws, {.i = 3} },
  { MODKEY | ShiftMask, XK_4, sendws, {.i = 4} },
  { MODKEY | ShiftMask, XK_5, sendws, {.i = 5} },
  { MODKEY | ShiftMask, XK_6, sendws, {.i = 6} },
  { MODKEY | ShiftMask, XK_7, sendws, {.i = 7} },
  { MODKEY | ShiftMask, XK_8, sendws, {.i = 8} },
  { MODKEY | ShiftMask, XK_9, sendws, {.i = 9} },
};

    '';
  };

in

{

  options = {
    services.xserver.windowManager.moody = {
      enable = mkEnableOption "moody";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before moody is started.
        '';
      };
      package = mkPackageOption pkgs "moody" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "moody" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "moody";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${moody}/bin/moody &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.moody = {
      enable = true;
      extraSessionCommands = '' '';
      package = moody;
    };

  };

}
