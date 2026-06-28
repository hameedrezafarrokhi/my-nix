{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.ywm;
  ywm = pkgs.callPackage ./ywm.nix { };

in

{

  options = {
    services.xserver.windowManager.ywm = {
      enable = mkEnableOption "ywm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before ywm is started.
        '';
      };
      package = mkPackageOption pkgs "ywm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "ywm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "ywm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${ywm}/bin/ywm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.ywm = {
      enable = true;
      extraSessionCommands = '' '';
      package = ywm;
    };

  };

}
