{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.emwm;
  emwm = pkgs.callPackage ./emwm.nix { };
  tellmwm = pkgs.callPackage ./tellmwm.nix { };

in

{

  options = {
    services.xserver.windowManager.emwm = {
      enable = mkEnableOption "emwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before emwm is started.
        '';
      };
      package = mkPackageOption pkgs "emwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "emwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "emwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${emwm}/bin/emwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package tellmwm ];

    services.xserver.windowManager.emwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = emwm;
    };

  };

}
