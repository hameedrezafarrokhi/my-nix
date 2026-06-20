{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.kopiwm;
  kopiwm = pkgs.callPackage ./kopiwm.nix { };

in

{

  options = {
    services.xserver.windowManager.kopiwm = {
      enable = mkEnableOption "kopiwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before kopiwm is started.
        '';
      };
      package = mkPackageOption pkgs "kopiwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "kopiwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "kopiwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${kopiwm}/bin/kopiwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.kopiwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = kopiwm;
    };

  };

}
