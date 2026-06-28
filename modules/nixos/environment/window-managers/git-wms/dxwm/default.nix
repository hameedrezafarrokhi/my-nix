{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.dxwm;
  dxwm = pkgs.callPackage ./dxwm.nix { };

in

{

  options = {
    services.xserver.windowManager.dxwm = {
      enable = mkEnableOption "dxwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before dxwm is started.
        '';
      };
      package = mkPackageOption pkgs "dxwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "dxwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "dxwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${dxwm}/bin/dxwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.dxwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = dxwm;
    };

  };

}
