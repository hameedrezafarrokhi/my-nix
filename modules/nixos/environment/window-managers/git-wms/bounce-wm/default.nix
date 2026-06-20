{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.bounce-wm;
  bounce-wm = pkgs.callPackage ./bounce-wm.nix { };

in

{

  options = {
    services.xserver.windowManager.bounce-wm = {
      enable = mkEnableOption "bounce-wm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before bounce-wm is started.
        '';
      };
      package = mkPackageOption pkgs "bounce-wm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "bounce-wm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "bounce-wm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${bounce-wm}/bin/bounce-wm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.bounce-wm = {
      enable = true;
      extraSessionCommands = '' '';
      package = bounce-wm;
    };

  };

}
