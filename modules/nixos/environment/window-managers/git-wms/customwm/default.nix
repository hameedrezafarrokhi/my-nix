{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.customwm;
  customwm = pkgs.callPackage ./customwm.nix { };

in

{

  options = {
    services.xserver.windowManager.customwm = {
      enable = mkEnableOption "customwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before customwm is started.
        '';
      };
      package = mkPackageOption pkgs "customwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "customwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "customwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${customwm}/bin/customwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.customwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = customwm;
    };

  };

}
