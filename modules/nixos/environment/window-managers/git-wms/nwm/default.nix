{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.nwm;
  nwm = pkgs.callPackage ./nwm.nix { };

in

{

  options = {
    services.xserver.windowManager.nwm = {
      enable = mkEnableOption "nwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before nwm is started.
        '';
      };
      package = mkPackageOption pkgs "nwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "nwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "nwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${nwm}/bin/nwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.nwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = nwm;
    };

  };

}
