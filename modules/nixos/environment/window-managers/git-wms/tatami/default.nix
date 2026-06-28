{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.tatami;
  tatami = pkgs.callPackage ./tatami.nix { };

in

{

  options = {
    services.xserver.windowManager.tatami = {
      enable = mkEnableOption "tatami";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before tatami is started.
        '';
      };
      package = mkPackageOption pkgs "tatami" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "tatami" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "tatami";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${tatami}/bin/tatami &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.tatami = {
      enable = true;
      extraSessionCommands = '' '';
      package = tatami;
    };

  };

}
