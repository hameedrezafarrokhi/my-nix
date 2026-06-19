{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.hsdwm;
  hsdwm = pkgs.callPackage ./hsdwm.nix { };

in

{

  options = {
    services.xserver.windowManager.hsdwm = {
      enable = mkEnableOption "hsdwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before hsdwm is started.
        '';
      };
      package = mkPackageOption pkgs "hsdwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "hsdwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "hsdwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${hsdwm}/bin/hsdwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.hsdwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = hsdwm;
    };

  };

}
