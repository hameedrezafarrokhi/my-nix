{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.bouncywm;
  bouncywm = pkgs.callPackage ./bouncywm.nix { };

in

{

  options = {
    services.xserver.windowManager.bouncywm = {
      enable = mkEnableOption "bouncywm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before bouncywm is started.
        '';
      };
      package = mkPackageOption pkgs "bouncywm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "bouncywm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "bouncywm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${bouncywm}/bin/bouncywm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.bouncywm = {
      enable = true;
      extraSessionCommands = '' '';
      package = bouncywm;
    };

  };

}
