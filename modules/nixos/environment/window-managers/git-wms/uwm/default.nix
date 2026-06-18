{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.uwm;
  uwm = pkgs.callPackage ./uwm.nix { };

in

{

  options = {
    services.xserver.windowManager.uwm = {
      enable = mkEnableOption "uwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before uwm is started.
        '';
      };
      package = mkPackageOption pkgs "uwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "uwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "uwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${uwm}/bin/uwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.uwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = uwm;
    };

  };

}
