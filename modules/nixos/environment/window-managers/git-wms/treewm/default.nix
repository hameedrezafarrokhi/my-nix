{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.treewm;
  treewm = pkgs.callPackage ./treewm.nix { };

in

{

  options = {
    services.xserver.windowManager.treewm = {
      enable = mkEnableOption "treewm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before treewm is started.
        '';
      };
      package = mkPackageOption pkgs "treewm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "treewm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "treewm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${treewm}/bin/treewm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.treewm = {
      enable = true;
      extraSessionCommands = '' '';
      package = treewm;
    };

  };

}
