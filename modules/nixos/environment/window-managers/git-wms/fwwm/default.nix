{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.fwwm;
  fwwm = pkgs.callPackage ./fwwm.nix { };
  cherry = pkgs.callPackage ./cherry.nix { };

in

{

  options = {
    services.xserver.windowManager.fwwm = {
      enable = mkEnableOption "fwwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before fwwm is started.
        '';
      };
      package = mkPackageOption pkgs "fwwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "fwwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "fwwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${fwwm}/bin/fwwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package cherry ];

    services.xserver.windowManager.fwwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = fwwm;
    };

  };

}
