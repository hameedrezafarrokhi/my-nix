{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.bouncewm;
  bouncewm = pkgs.callPackage ./bouncewm.nix { };

in

{

  options = {
    services.xserver.windowManager.bouncewm = {
      enable = mkEnableOption "bouncewm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before bouncewm is started.
        '';
      };
      package = mkPackageOption pkgs "bouncewm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "bouncewm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "bouncewm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${bouncewm}/bin/bouncewm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.bouncewm = {
      enable = true;
      extraSessionCommands = '' '';
      package = bouncewm;
    };

  };

}
