{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.fxwm;
  fxwm = pkgs.callPackage ./fxwm.nix { };

in

{

  options = {
    services.xserver.windowManager.fxwm = {
      enable = mkEnableOption "fxwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before fxwm is started.
        '';
      };
      package = mkPackageOption pkgs "fxwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "fxwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "fxwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${fxwm}/bin/fxwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.fxwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = fxwm;
    };

  };

}
