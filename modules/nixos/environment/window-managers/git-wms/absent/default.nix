{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.absent;
  absent = pkgs.callPackage ./absent.nix { };

in

{

  options = {
    services.xserver.windowManager.absent = {
      enable = mkEnableOption "absent";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before absent is started.
        '';
      };
      package = mkPackageOption pkgs "absent" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "absent" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "absent";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${absent}/bin/absent &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.absent = {
      enable = true;
      extraSessionCommands = '' '';
      package = absent;
    };

  };

}
