{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.xpywm;
  xpywm = pkgs.callPackage ./xpywm.nix { };

in

{

  options = {
    services.xserver.windowManager.xpywm = {
      enable = mkEnableOption "xpywm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before xpywm is started.
        '';
      };
      package = mkPackageOption pkgs "xpywm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "xpywm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "xpywm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${xpywm}/bin/xpywm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.xpywm = {
      enable = true;
      extraSessionCommands = ''
        setxkbmap -option ctrl:nocaps
      '';
      package = xpywm;
    };

  };

}
