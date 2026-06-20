{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.bouncewm-kacper;
  bouncewm-kacper = pkgs.callPackage ./bouncewm-kacper.nix { };

in

{

  options = {
    services.xserver.windowManager.bouncewm-kacper = {
      enable = mkEnableOption "bouncewm-kacper";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before bouncewm-kacper is started.
        '';
      };
      package = mkPackageOption pkgs "bouncewm-kacper" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "bouncewm-kacper" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "bouncewm-kacper";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${bouncewm-kacper}/bin/bouncewm-kacper &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.bouncewm-kacper = {
      enable = true;
      extraSessionCommands = '' '';
      package = bouncewm-kacper;
    };

  };

}
