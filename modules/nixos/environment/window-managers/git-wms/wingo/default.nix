{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.wingo;
  wingo = pkgs.callPackage ./wingo.nix { };

in

{

  options = {
    services.xserver.windowManager.wingo = {
      enable = mkEnableOption "wingo";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before wingo is started.
        '';
      };
      package = mkPackageOption pkgs "wingo" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "wingo" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "wingo";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${wingo}/bin/wingo &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.wingo = {
      enable = true;
      extraSessionCommands = '' '';
      package = wingo;
    };

  };

}
