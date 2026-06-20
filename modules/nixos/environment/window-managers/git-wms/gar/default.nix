{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.gar;
  gar = pkgs.callPackage ./gar.nix { };
  garbar = pkgs.callPackage ./garbar.nix { };

in

{

  options = {
    services.xserver.windowManager.gar = {
      enable = mkEnableOption "gar";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before gar is started.
        '';
      };
      package = mkPackageOption pkgs "gar" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "gar" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "gar";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${gar}/bin/gar &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package garbar ];

    services.xserver.windowManager.gar = {
      enable = true;
      extraSessionCommands = ''
        garbar &
      '';
      package = gar;
    };

  };

}
