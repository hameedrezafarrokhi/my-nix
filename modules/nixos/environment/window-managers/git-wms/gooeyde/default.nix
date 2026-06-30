{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.gooeyde;
  gooeyde = pkgs.callPackage ./gooeyde.nix { };

in

{

  options = {
    services.xserver.windowManager.gooeyde = {
      enable = mkEnableOption "gooeyde";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before gooeyde is started.
        '';
      };
      package = mkPackageOption pkgs "gooeyde" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "gooeyde" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "gooeyde";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${gooeyde}/bin/gooeyde &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.gooeyde = {
      enable = true;
      extraSessionCommands = '' '';
      package = gooeyde;
    };

  };

}
