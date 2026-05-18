{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.mcwm;
  mcwm = pkgs.callPackage ./mcwm.nix { };

in

{

  options = {
    services.xserver.windowManager.mcwm = {
      enable = mkEnableOption "mcwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before mcwm is started.
        '';
      };
      package = mkPackageOption pkgs "mcwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "mcwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "mcwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${mcwm}/bin/mcwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.mcwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = mcwm;
    };

  };

}
