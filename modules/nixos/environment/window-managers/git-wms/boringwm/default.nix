{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.boringwm;
  boringwm = pkgs.callPackage ./boringwm.nix { };

in

{

  options = {
    services.xserver.windowManager.boringwm = {
      enable = mkEnableOption "boringwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before boringwm is started.
        '';
      };
      package = mkPackageOption pkgs "boringwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "boringwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "boringwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${boringwm}/bin/boringwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.boringwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = boringwm;
    };

  };

}
