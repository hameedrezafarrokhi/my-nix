{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.pointblank;
  pointblank = pkgs.callPackage ./pointblank.nix { };

in

{

  options = {
    services.xserver.windowManager.pointblank = {
      enable = mkEnableOption "pointblank";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before pointblank is started.
        '';
      };
      package = mkPackageOption pkgs "pointblank" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "pointblank" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "pointblank";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${pointblank}/bin/pointblank &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.pointblank = {
      enable = true;
      extraSessionCommands = '' '';
      package = pointblank;
    };

  };

}
