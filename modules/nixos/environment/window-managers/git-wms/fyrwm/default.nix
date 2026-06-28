{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.fyrwm;
  fyrwm = pkgs.callPackage ./fyrwm.nix { };

in

{

  options = {
    services.xserver.windowManager.fyrwm = {
      enable = mkEnableOption "fyrwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before fyrwm is started.
        '';
      };
      package = mkPackageOption pkgs "fyrwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "fyrwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "fyrwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${fyrwm}/bin/fyrwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.fyrwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = fyrwm;
    };

  };

}
