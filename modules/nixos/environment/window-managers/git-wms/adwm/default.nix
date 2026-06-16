{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.adwm;
  adwm = pkgs.callPackage ./adwm.nix { };

in

{

  options = {
    services.xserver.windowManager.adwm = {
      enable = mkEnableOption "adwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before adwm is started.
        '';
      };
      package = mkPackageOption pkgs "adwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "adwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "adwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${adwm}/bin/adwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.adwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = adwm;
    };

  };

}
