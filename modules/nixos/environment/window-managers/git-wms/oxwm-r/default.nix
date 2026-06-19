{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.oxwm-r;
  oxwm-r = pkgs.callPackage ./oxwm-r.nix { };

in

{

  options = {
    services.xserver.windowManager.oxwm-r = {
      enable = mkEnableOption "oxwm-r";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before oxwm-r is started.
        '';
      };
      package = mkPackageOption pkgs "oxwm-r" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "oxwm-r" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "oxwm-r";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${oxwm-r}/bin/oxwm-r &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.oxwm-r = {
      enable = true;
      extraSessionCommands = '' '';
      package = oxwm-r;
    };

  };

}
