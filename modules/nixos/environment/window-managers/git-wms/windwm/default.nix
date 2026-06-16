{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.windwm;
  windwm = pkgs.callPackage ./windwm.nix { };

in

{

  options = {
    services.xserver.windowManager.windwm = {
      enable = mkEnableOption "windwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before windwm is started.
        '';
      };
      package = mkPackageOption pkgs "windwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "windwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "windwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${windwm}/bin/wind &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.windwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = windwm;
    };

  };

}
