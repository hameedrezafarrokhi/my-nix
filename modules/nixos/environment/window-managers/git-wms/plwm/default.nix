{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.plwm;
  plwm = pkgs.callPackage ./plwm.nix { };

in

{

  options = {
    services.xserver.windowManager.plwm = {
      enable = mkEnableOption "plwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before plwm is started.
        '';
      };
      package = mkPackageOption pkgs "plwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "plwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "plwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${plwm}/bin/plwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.plwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = plwm;
    };

  };

}
