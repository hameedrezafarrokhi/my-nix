{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.window_manager;
  window_manager = pkgs.callPackage ./window_manager.nix { };

in

{

  options = {
    services.xserver.windowManager.window_manager = {
      enable = mkEnableOption "window_manager";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before window_manager is started.
        '';
      };
      package = mkPackageOption pkgs "window_manager" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "window_manager" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "window_manager";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${window_manager}/bin/window_manager &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.window_manager = {
      enable = true;
      extraSessionCommands = '' '';
      package = window_manager;
    };

  };

}
