{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.worm;
  worm = pkgs.callPackage ./worm.nix { };
  worm-bin = pkgs.callPackage ./worm-bin.nix { };

in

{

  options = {
    services.xserver.windowManager.worm = {
      enable = mkEnableOption "worm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before worm is started.
        '';
      };
      package = mkPackageOption pkgs "worm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "worm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "worm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${cfg.package}/bin/worm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.worm = {
      enable = true;
      extraSessionCommands = '' '';
      package = worm-bin;
    };

  };

}
