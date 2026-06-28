{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.bond-wm;
  bond-wm = pkgs.callPackage ./bond-wm.nix { };

in

{

  options = {
    services.xserver.windowManager.bond-wm = {
      enable = mkEnableOption "bond-wm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before bond-wm is started.
        '';
      };
      package = mkPackageOption pkgs "bond-wm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "bond-wm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "bond-wm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${bond-wm}/bin/bond-wm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.bond-wm = {
      enable = true;
      extraSessionCommands = '' '';
      package = bond-wm;
    };

  };

}
