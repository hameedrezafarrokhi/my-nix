{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.cygnus;
  cygnus = pkgs.callPackage ./cygnus.nix { };

in

{

  options = {
    services.xserver.windowManager.cygnus = {
      enable = mkEnableOption "cygnus";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before cygnus is started.
        '';
      };
      package = mkPackageOption pkgs "cygnus" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "cygnus" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "cygnus";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${cygnus}/bin/cygnus &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.cygnus = {
      enable = true;
      extraSessionCommands = '' '';
      package = cygnus;
    };

  };

}
