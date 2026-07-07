{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.matwm2;
  matwm2 = pkgs.callPackage ./matwm2.nix { };

in

{

  options = {
    services.xserver.windowManager.matwm2 = {
      enable = mkEnableOption "matwm2";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before matwm2 is started.
        '';
      };
      package = mkPackageOption pkgs "matwm2" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "matwm2" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "matwm2";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${matwm2}/bin/matwm2 &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.matwm2 = {
      enable = true;
      extraSessionCommands = '' '';
      package = matwm2;
    };

  };

}
