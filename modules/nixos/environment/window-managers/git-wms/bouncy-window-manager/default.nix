{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.bouncy-window-manager;
  bouncy-window-manager = pkgs.callPackage ./bouncy-window-manager.nix { };

in

{

  options = {
    services.xserver.windowManager.bouncy-window-manager = {
      enable = mkEnableOption "bouncy-window-manager";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before bouncy-window-manager is started.
        '';
      };
      package = mkPackageOption pkgs "bouncy-window-manager" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "bouncy-window-manager" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "bouncy-window-manager";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${bouncy-window-manager}/bin/bouncy-window-manager &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.bouncy-window-manager = {
      enable = true;
      extraSessionCommands = '' '';
      package = bouncy-window-manager;
    };

  };

}
