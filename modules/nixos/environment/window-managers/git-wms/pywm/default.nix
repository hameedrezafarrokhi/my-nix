{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.pywm;
  pywm = pkgs.callPackage ./pywm.nix { };

in

{

  options = {
    services.xserver.windowManager.pywm = {
      enable = mkEnableOption "pywm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before pywm is started.
        '';
      };
      package = mkPackageOption pkgs "pywm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "pywm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "pywm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${pywm}/bin/pywm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.pywm = {
      enable = true;
      extraSessionCommands = ''
        setxkbmap -option ctrl:nocaps
      '';
      package = pywm;
    };

  };

}
