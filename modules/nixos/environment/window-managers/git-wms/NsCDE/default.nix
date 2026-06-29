{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.NsCDE;
  NsCDE = pkgs.callPackage ./NsCDE.nix { };

in

{

  options = {
    services.xserver.windowManager.NsCDE = {
      enable = mkEnableOption "NsCDE";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before NsCDE is started.
        '';
      };
      package = mkPackageOption pkgs "NsCDE" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "NsCDE" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "NsCDE";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${NsCDE}/bin/nscde &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.NsCDE = {
      enable = true;
      extraSessionCommands = '' '';
      package = NsCDE;
    };

  };

}
