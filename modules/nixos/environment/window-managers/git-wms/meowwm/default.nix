{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.meowwm;
  meowwm = pkgs.callPackage ./meowwm.nix {
    conf = ''
#ifndef CONFIG_H
#define CONFIG_H

#include "meow.h"

#define WIN_BORDER_WIDTH 4

const char* menu[] = {"rofi","-show","drun","-theme",".config/rofi/themes/main.rasi", 0};
const char* term[] = {"${config.my.default.terminal}", 0};
const char* voldown[] = {"amixer", "sset", "Master", "5%-",         0};
const char* volup[]   = {"amixer", "sset", "Master", "5%+",         0};
const char* volmute[] = {"amixer", "sset", "Master", "toggle",      0};

keybind keybinds[] = {
    {Mod4Mask, XK_space, menu},
    {Mod4Mask, XK_Return, term},
    {0, XF86XK_AudioLowerVolume, voldown},
    {0, XF86XK_AudioRaiseVolume, volup},
    {0, XF86XK_AudioMute,        volmute},
};

const char* termstart[] = {"${config.my.default.terminal}", 0};

command startup_cmds[] = {
	{ termstart },
};

#endif

    '';
  };

in

{

  options = {
    services.xserver.windowManager.meowwm = {
      enable = mkEnableOption "meowwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before meowwm is started.
        '';
      };
      package = mkPackageOption pkgs "meowwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "meowwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "meowwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${meowwm}/bin/meowwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.meowwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = meowwm;
    };

  };

}
