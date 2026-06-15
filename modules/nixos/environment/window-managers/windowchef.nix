{ config, pkgs, lib, inputs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.windowchef;

in

{

  options = {
    services.xserver.windowManager.windowchef = {
      enable = mkEnableOption "windowchef";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before windowchef is started.
        '';
      };
      package = mkPackageOption pkgs "windowchef" {
        example = '' '';
      };
    };
  };

  config =  lib.mkIf (builtins.elem "windowchef" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "windowchef";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${cfg.package}/bin/windowchef &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.windowchef = {
      enable = true;
      extraSessionCommands = '' '';
      package = pkgs.windowchef;
    };

  };


}
