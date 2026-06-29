{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.xmt;
  xmt = pkgs.callPackage ./xmt.nix { };

in

{

  options = {
    services.xserver.windowManager.xmt = {
      enable = mkEnableOption "xmt";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before xmt is started.
        '';
      };
      package = mkPackageOption pkgs "xmt" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "xmt" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "xmt";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${xmt}/bin/xmt &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.xmt = {
      enable = true;
      extraSessionCommands = '' '';
      package = xmt;
    };

  };

}
