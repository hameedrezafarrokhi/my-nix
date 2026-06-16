{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.progman;
  progman = pkgs.callPackage ./progman.nix { };

in

{

  options = {
    services.xserver.windowManager.progman = {
      enable = mkEnableOption "progman";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before progman is started.
        '';
      };
      package = mkPackageOption pkgs "progman" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "progman" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "progman";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${progman}/bin/progman &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.progman = {
      enable = true;
      extraSessionCommands = '' '';
      package = progman;
    };

  };

}
