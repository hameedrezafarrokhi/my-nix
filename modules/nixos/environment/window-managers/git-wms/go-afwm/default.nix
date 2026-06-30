{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.go-afwm;
  go-afwm = pkgs.callPackage ./go-afwm.nix { };

in

{

  options = {
    services.xserver.windowManager.go-afwm = {
      enable = mkEnableOption "go-afwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before go-afwm is started.
        '';
      };
      package = mkPackageOption pkgs "go-afwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "go-afwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "go-afwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${go-afwm}/bin/afwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.go-afwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = go-afwm;
    };

  };

}
