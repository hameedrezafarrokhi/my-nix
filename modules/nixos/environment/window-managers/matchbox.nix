{ config, pkgs, lib, inputs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.matchbox;

in

{

  options = {
    services.xserver.windowManager.matchbox = {
      enable = mkEnableOption "matchbox";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before matchbox is started.
        '';
      };
      package = mkPackageOption pkgs "matchbox" {
        example = '' '';
      };
    };
  };

  config =  lib.mkIf (builtins.elem "matchbox" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "matchbox";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${cfg.package}/bin/matchbox &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.matchbox = {
      enable = true;
      extraSessionCommands = '' '';
      package = pkgs.matchbox;
    };

  };


}
