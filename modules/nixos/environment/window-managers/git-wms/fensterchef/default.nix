{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.fensterchef;
  fensterchef = pkgs.callPackage ./fensterchef.nix { };

in

{

  options = {
    services.xserver.windowManager.fensterchef = {
      enable = mkEnableOption "fensterchef";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before fensterchef is started.
        '';
      };
      package = mkPackageOption pkgs "fensterchef" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "fensterchef" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "fensterchef";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${fensterchef}/bin/fensterchef &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.fensterchef = {
      enable = true;
      extraSessionCommands = '' '';
      package = fensterchef;
    };

  };

}
