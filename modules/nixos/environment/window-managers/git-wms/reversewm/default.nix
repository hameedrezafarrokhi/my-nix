{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.reversewm;
  reversewm = pkgs.callPackage ./reversewm.nix { };

in

{

  options = {
    services.xserver.windowManager.reversewm = {
      enable = mkEnableOption "reversewm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before reversewm is started.
        '';
      };
      package = mkPackageOption pkgs "reversewm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "reversewm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "reversewm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${reversewm}/bin/reversewm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.reversewm = {
      enable = true;
      extraSessionCommands = '' '';
      package = reversewm;
    };

  };

}
