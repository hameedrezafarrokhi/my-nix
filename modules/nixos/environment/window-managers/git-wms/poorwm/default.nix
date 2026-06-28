{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.poorwm;
  poorwm = pkgs.callPackage ./poorwm.nix { };

in

{

  options = {
    services.xserver.windowManager.poorwm = {
      enable = mkEnableOption "poorwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before poorwm is started.
        '';
      };
      package = mkPackageOption pkgs "poorwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "poorwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "poorwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${poorwm}/bin/poorwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.poorwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = poorwm;
    };

  };

}
