{ config, pkgs, lib, nix-path, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.superiorxwm;
  superiorxwm = pkgs.callPackage ./superiorxwm.nix { };

in

{

  options = {
    services.xserver.windowManager.superiorxwm = {
      enable = mkEnableOption "superiorxwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before superiorxwm is started.
        '';
      };
      package = mkPackageOption pkgs "superiorxwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "superiorxwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "superiorxwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${superiorxwm}/bin/superiorxwm -c "${nix-path}/modules/nixos/environment/window-managers/git-wms/superiorxwm/config"  &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.superiorxwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = superiorxwm;
    };

  };

}
