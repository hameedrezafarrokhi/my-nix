{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.musca;
  musca = pkgs.callPackage ./musca.nix { };

in

{

  options = {
    services.xserver.windowManager.musca = {
      enable = mkEnableOption "musca";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before musca is started.
        '';
      };
      package = mkPackageOption pkgs "musca" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "musca" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "musca";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${musca}/bin/musca &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.musca = {
      enable = true;
      extraSessionCommands = '' '';
      package = musca;
    };

  };

}
