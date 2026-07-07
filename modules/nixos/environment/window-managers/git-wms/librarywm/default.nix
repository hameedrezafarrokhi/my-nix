{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.librarywm;
  librarywm = pkgs.callPackage ./librarywm.nix { };

in

{

  options = {
    services.xserver.windowManager.librarywm = {
      enable = mkEnableOption "librarywm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before librarywm is started.
        '';
      };
      package = mkPackageOption pkgs "librarywm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "librarywm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "librarywm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${librarywm}/bin/librarywm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.librarywm = {
      enable = true;
      extraSessionCommands = '' '';
      package = librarywm;
    };

  };

}
