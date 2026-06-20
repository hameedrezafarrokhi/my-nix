{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.bouncy-wm;
  bouncy-wm = pkgs.callPackage ./bouncy-wm.nix { };

in

{

  options = {
    services.xserver.windowManager.bouncy-wm = {
      enable = mkEnableOption "bouncy-wm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before bouncy-wm is started.
        '';
      };
      package = mkPackageOption pkgs "bouncy-wm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "bouncy-wm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "bouncy-wm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${bouncy-wm}/bin/bouncy-wm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.bouncy-wm = {
      enable = true;
      extraSessionCommands = '' '';
      package = bouncy-wm;
    };

  };

}
