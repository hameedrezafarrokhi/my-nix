{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.derpy-wm;
  derpy-wm = pkgs.callPackage ./derpy-wm.nix { };

in

{

  options = {
    services.xserver.windowManager.derpy-wm = {
      enable = mkEnableOption "derpy-wm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before derpy-wm is started.
        '';
      };
      package = mkPackageOption pkgs "derpy-wm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "derpy-wm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "derpy-wm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${derpy-wm}/bin/derpy-wm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.derpy-wm = {
      enable = true;
      extraSessionCommands = '' '';
      package = derpy-wm;
    };

  };

}
