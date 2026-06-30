{ config, pkgs, lib, mypkgs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.dubwm;
  dubwm = mypkgs.old-stable.callPackage ./dubwm.nix { };

in

{

  options = {
    services.xserver.windowManager.dubwm = {
      enable = mkEnableOption "dubwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before dubwm is started.
        '';
      };
      package = mkPackageOption pkgs "dubwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "dubwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "dubwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${dubwm}/bin/dubwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.dubwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = dubwm;
    };

  };

}
