{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.tile;
  tile = pkgs.callPackage ./tile.nix { };

in

{

  options = {
    services.xserver.windowManager.tile = {
      enable = mkEnableOption "tile";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before tile is started.
        '';
      };
      package = mkPackageOption pkgs "tile" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "tile" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "tile";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${tile}/bin/tile &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.tile = {
      enable = true;
      extraSessionCommands = '' '';
      package = tile;
    };

  };

}
