{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.goomwwm;
  goomwwm = pkgs.callPackage ./goomwwm.nix { };

in

{

  options = {
    services.xserver.windowManager.goomwwm = {
      enable = mkEnableOption "goomwwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before goomwwm is started.
        '';
      };
      package = mkPackageOption pkgs "goomwwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "goomwwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "goomwwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${goomwwm}/bin/goomwwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.goomwwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = goomwwm;
    };

  };

}
