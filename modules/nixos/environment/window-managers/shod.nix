{ config, pkgs, lib, inputs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.shod;

in

{

  options = {
    services.xserver.windowManager.shod = {
      enable = mkEnableOption "shod";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before shod is started.
        '';
      };
      package = mkPackageOption pkgs "shod" {
        example = '' '';
      };
    };
  };

  config =  lib.mkIf (builtins.elem "shod" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "shod";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${cfg.package}/bin/shod &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.shod = {
      enable = true;
      extraSessionCommands = '' '';
      package = pkgs.shod;
    };

  };


}
