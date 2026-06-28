{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.pgwm;
  pgwm = pkgs.callPackage ./pgwm.nix { };

in

{

  options = {
    services.xserver.windowManager.pgwm = {
      enable = mkEnableOption "pgwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before pgwm is started.
        '';
      };
      package = mkPackageOption pkgs "pgwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "pgwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "pgwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${pgwm}/bin/pgwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.pgwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = pgwm;
    };

  };

}
