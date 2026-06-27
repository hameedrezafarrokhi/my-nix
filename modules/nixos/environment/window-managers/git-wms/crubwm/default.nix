{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.crubwm;
  crubwm = pkgs.callPackage ./crubwm.nix { };

in

{

  options = {
    services.xserver.windowManager.crubwm = {
      enable = mkEnableOption "crubwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before crubwm is started.
        '';
      };
      package = mkPackageOption pkgs "crubwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "crubwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "crubwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${crubwm}/bin/crubwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.crubwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = crubwm;
    };

  };

}
