{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.unknowwm;
  unknowwm = pkgs.callPackage ./unknowwm.nix { };
  unknowdock = pkgs.callPackage ./unknowdock.nix { };

in

{

  options = {
    services.xserver.windowManager.unknowwm = {
      enable = mkEnableOption "unknowwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before unknowwm is started.
        '';
      };
      package = mkPackageOption pkgs "unknowwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "unknowwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "unknowwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${unknowwm}/bin/unknowwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
      unknowdock
    ];

    services.xserver.windowManager.unknowwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = unknowwm;
    };

  };

}
