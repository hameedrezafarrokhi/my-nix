{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.yggdrasilwm;
  yggdrasilwm = pkgs.callPackage ./yggdrasilwm.nix { };

in

{

  options = {
    services.xserver.windowManager.yggdrasilwm = {
      enable = mkEnableOption "yggdrasilwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before yggdrasilwm is started.
        '';
      };
      package = mkPackageOption pkgs "yggdrasilwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "yggdrasilwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "yggdrasilwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${yggdrasilwm}/bin/yggdrasilwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.yggdrasilwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = yggdrasilwm;
    };

  };

}
