{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.stressfulwm;
  stressfulwm = pkgs.callPackage ./stressfulwm.nix { };

in

{

  options = {
    services.xserver.windowManager.stressfulwm = {
      enable = mkEnableOption "stressfulwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before stressfulwm is started.
        '';
      };
      package = mkPackageOption pkgs "stressfulwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "stressfulwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "stressfulwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${stressfulwm}/bin/stressfulwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.stressfulwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = stressfulwm;
    };

  };

}
