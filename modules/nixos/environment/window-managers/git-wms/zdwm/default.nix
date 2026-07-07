{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.zdwm;
  zdwm = pkgs.callPackage ./zdwm.nix { };

in

{

  options = {
    services.xserver.windowManager.zdwm = {
      enable = mkEnableOption "zdwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before zdwm is started.
        '';
      };
      package = mkPackageOption pkgs "zdwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "zdwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "zdwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${zdwm}/bin/zdwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.zdwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = zdwm;
    };

  };

}
