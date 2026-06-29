{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.nimwin;
  nimwin = pkgs.callPackage ./nimwin.nix { };

in

{

  options = {
    services.xserver.windowManager.nimwin = {
      enable = mkEnableOption "nimwin";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before nimwin is started.
        '';
      };
      package = mkPackageOption pkgs "nimwin" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "nimwin" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "nimwin";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${nimwin}/bin/nimwin &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.nimwin = {
      enable = true;
      extraSessionCommands = '' '';
      package = nimwin;
    };

  };

}
