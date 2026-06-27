{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.sweetwm;
  sweetwm = pkgs.callPackage ./sweetwm.nix { };

in

{

  options = {
    services.xserver.windowManager.sweetwm = {
      enable = mkEnableOption "sweetwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before sweetwm is started.
        '';
      };
      package = mkPackageOption pkgs "sweetwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "sweetwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "sweetwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${sweetwm}/bin/sweetwm &
        waitPID=$!
      '';
    };

    # usage: sweetwm /path/to/sweetwm.lua

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.sweetwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = sweetwm;
    };

  };

}
