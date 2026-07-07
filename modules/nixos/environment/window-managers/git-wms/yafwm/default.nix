{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.yafwm;
  yafwm = pkgs.callPackage ./yafwm.nix { };

in

{

  options = {
    services.xserver.windowManager.yafwm = {
      enable = mkEnableOption "yafwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before yafwm is started.
        '';
      };
      package = mkPackageOption pkgs "yafwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "yafwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "yafwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${yafwm}/bin/yafwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.yafwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = yafwm;
    };

  };

}
