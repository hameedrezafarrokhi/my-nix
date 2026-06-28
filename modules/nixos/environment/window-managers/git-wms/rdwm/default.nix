{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.rdwm;
  rdwm = pkgs.callPackage ./rdwm.nix { };

in

{

  options = {
    services.xserver.windowManager.rdwm = {
      enable = mkEnableOption "rdwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before rdwm is started.
        '';
      };
      package = mkPackageOption pkgs "rdwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "rdwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "rdwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${rdwm}/bin/rdwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.rdwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = rdwm;
    };

  };

}
