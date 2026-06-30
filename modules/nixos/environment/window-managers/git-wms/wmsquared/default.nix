{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.wmsquared;
  wmsquared = pkgs.callPackage ./wmsquared.nix { };

in

{

  options = {
    services.xserver.windowManager.wmsquared = {
      enable = mkEnableOption "wmsquared";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before wmsquared is started.
        '';
      };
      package = mkPackageOption pkgs "wmsquared" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "wmsquared" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "wmsquared";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${wmsquared}/bin/wmsquared &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.wmsquared = {
      enable = true;
      extraSessionCommands = '' '';
      package = wmsquared;
    };

  };

}
