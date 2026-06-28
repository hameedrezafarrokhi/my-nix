{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.ttwm;
  ttwm = pkgs.callPackage ./ttwm.nix { };

in

{

  options = {
    services.xserver.windowManager.ttwm = {
      enable = mkEnableOption "ttwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before ttwm is started.
        '';
      };
      package = mkPackageOption pkgs "ttwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "ttwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "ttwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${ttwm}/bin/ttwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.ttwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = ttwm;
    };

  };

}
