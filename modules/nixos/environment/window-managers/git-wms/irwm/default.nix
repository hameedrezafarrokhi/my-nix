{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.irwm;
  irwm = pkgs.callPackage ./irwm.nix { };

in

{

  options = {
    services.xserver.windowManager.irwm = {
      enable = mkEnableOption "irwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before irwm is started.
        '';
      };
      package = mkPackageOption pkgs "irwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "irwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "irwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${irwm}/bin/irwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.irwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = irwm;
    };

  };

}
