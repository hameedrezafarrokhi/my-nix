{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.sdorfehs;
  sdorfehs = pkgs.callPackage ./sdorfehs.nix { };

in

{

  options = {
    services.xserver.windowManager.sdorfehs = {
      enable = mkEnableOption "sdorfehs";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before sdorfehs is started.
        '';
      };
      package = mkPackageOption pkgs "sdorfehs" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "sdorfehs" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "sdorfehs";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${sdorfehs}/bin/sdorfehs &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.sdorfehs = {
      enable = true;
      extraSessionCommands = '' '';
      package = sdorfehs;
    };

  };

}
