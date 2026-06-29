{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.wm0;
  wm0 = pkgs.callPackage ./wm0.nix {
    conf = ''
#ifndef WM0_CONFIG_H
#define WM0_CONFIG_H

// Mouse button assignment (1 = left, 2 = middle, 3 = right)
#define BUTTON_MOVE    1
#define BUTTON_RESIZE  3
#define BUTTON_CLOSE   2

// Modifier key
#define MODKEY_MASK XCB_MOD_MASK_1

// Color of the border of windows
#define COLOR_ACTIVE   "#0000FF"  // for active (focused) window
#define COLOR_INACTIVE "#202020"  // for inactive (not focused) window

#endif // WM0_CONFIG_H
    '';
  };

in

{

  options = {
    services.xserver.windowManager.wm0 = {
      enable = mkEnableOption "wm0";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before wm0 is started.
        '';
      };
      package = mkPackageOption pkgs "wm0" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "wm0" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "wm0";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${wm0}/bin/wm0 &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.wm0 = {
      enable = true;
      extraSessionCommands = '' '';
      package = wm0;
    };

  };

}
