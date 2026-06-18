{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.eggwm;
  eggwm = pkgs.callPackage ./eggwm.nix { };

in

{

  options = {
    services.xserver.windowManager.eggwm = {
      enable = mkEnableOption "eggwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before eggwm is started.
        '';
      };
      package = mkPackageOption pkgs "eggwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "eggwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "eggwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${eggwm}/bin/eggwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.eggwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = eggwm;
    };

  };

}
