{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.stevewm;
  stevewm = pkgs.callPackage ./stevewm.nix { };

in

{

  options = {
    services.xserver.windowManager.stevewm = {
      enable = mkEnableOption "stevewm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before stevewm is started.
        '';
      };
      package = mkPackageOption pkgs "stevewm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "stevewm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "stevewm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${stevewm}/bin/steveWM &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.stevewm = {
      enable = true;
      extraSessionCommands = '' '';
      package = stevewm;
    };

  };

}
