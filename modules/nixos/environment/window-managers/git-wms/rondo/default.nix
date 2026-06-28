
{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.rondo;
  rondo = pkgs.callPackage ./rondo.nix { };

in

{

  options = {
    services.xserver.windowManager.rondo = {
      enable = mkEnableOption "rondo";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before rondo is started.
        '';
      };
      package = mkPackageOption pkgs "rondo" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "rondo" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "rondo";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${rondo}/bin/rondo &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.rondo = {
      enable = true;
      extraSessionCommands = '' '';
      package = rondo;
    };

  };

}
