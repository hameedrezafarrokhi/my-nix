{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.vtwm;
  vtwm = pkgs.callPackage ./vtwm.nix { };

in

{

  options = {
    services.xserver.windowManager.vtwm = {
      enable = mkEnableOption "vtwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before vtwm is started.
        '';
      };
      package = mkPackageOption pkgs "vtwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "vtwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "vtwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${vtwm}/bin/vtwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.vtwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = vtwm;
    };

  };

}
