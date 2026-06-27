{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.voxwm;
  voxwm = pkgs.callPackage ./voxwm.nix {
    conf = ''
#ifndef CONFIG_H
#define CONFIG_H

#include <stddef.h>
#include <X11/X.h>
#include <X11/keysym.h>
#include "main.h"
#include "wm.h"

#define MODKEY Mod1Mask

float master_factor = 0.5;
float master_factor_max = 0.9;
float master_factor_min = 0.1;
int gap = 2;

static const Key keys[] = {
    /* Mod                 Tecla         Função      Argumento */

    { MODKEY,              XK_Return,       execsh,        {.s = "alacritty"}    },
    { MODKEY|ShiftMask,    XK_q,         quit,       {0} },
};

static const unsigned int nkeys =
    sizeof(keys) / sizeof(keys[0]);

#endif
    '';
  };

in

{

  options = {
    services.xserver.windowManager.voxwm = {
      enable = mkEnableOption "voxwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before voxwm is started.
        '';
      };
      package = mkPackageOption pkgs "voxwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "voxwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "voxwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${voxwm}/bin/voxwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.voxwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = voxwm;
    };

  };

}
