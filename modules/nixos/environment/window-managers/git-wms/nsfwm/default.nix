{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.nsfwm;
  nsfwm = pkgs.callPackage ./nsfwm.nix { };

in

{

  options = {
    services.xserver.windowManager.nsfwm = {
      enable = mkEnableOption "nsfwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before nsfwm is started.
        '';
      };
      package = mkPackageOption pkgs "nsfwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "nsfwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "nsfwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${nsfwm}/bin/nsfwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.nsfwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = nsfwm;
    };

  };

}
