{ config, pkgs, lib, inputs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.wmfs;

in

{

  options = {
    services.xserver.windowManager.wmfs = {
      enable = mkEnableOption "wmfs";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before wmfs is started.
        '';
      };
      package = mkPackageOption pkgs "wmfs" {
        example = '' '';
      };
    };
  };

  config =  lib.mkIf (builtins.elem "wmfs" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "wmfs";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${cfg.package}/bin/wmfs &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.wmfs = {
      enable = true;
      extraSessionCommands = '' '';
      package = pkgs.wmfs;
    };

  };


}
