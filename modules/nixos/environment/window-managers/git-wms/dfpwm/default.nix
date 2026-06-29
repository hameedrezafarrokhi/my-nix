{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.dfpwm;
  dfpwm = pkgs.callPackage ./dfpwm.nix { };

in

{

  options = {
    services.xserver.windowManager.dfpwm = {
      enable = mkEnableOption "dfpwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before dfpwm is started.
        '';
      };
      package = mkPackageOption pkgs "dfpwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "dfpwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "dfpwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${dfpwm}/bin/dfpwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.dfpwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = dfpwm;
    };

  };

}
