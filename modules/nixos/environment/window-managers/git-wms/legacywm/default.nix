{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.legacywm;
  legacywm = pkgs.callPackage ./legacywm.nix { };

in

{

  options = {
    services.xserver.windowManager.legacywm = {
      enable = mkEnableOption "legacywm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before legacywm is started.
        '';
      };
      package = mkPackageOption pkgs "legacywm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "legacywm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "legacywm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${legacywm}/bin/legacywm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.legacywm = {
      enable = true;
      extraSessionCommands = '' '';
      package = legacywm;
    };

  };

}
