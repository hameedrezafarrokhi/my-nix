{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.fowm;
  fowm = pkgs.callPackage ./fowm.nix { };

in

{

  options = {
    services.xserver.windowManager.fowm = {
      enable = mkEnableOption "fowm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before fowm is started.
        '';
      };
      package = mkPackageOption pkgs "fowm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "fowm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "fowm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${fowm}/bin/fowm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.fowm = {
      enable = true;
      extraSessionCommands = '' '';
      package = fowm;
    };

  };

}
