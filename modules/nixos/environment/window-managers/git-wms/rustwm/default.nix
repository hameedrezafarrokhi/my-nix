{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.rustwm;
  rustwm = pkgs.callPackage ./rustwm.nix { };

in

{

  options = {
    services.xserver.windowManager.rustwm = {
      enable = mkEnableOption "rustwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before rustwm is started.
        '';
      };
      package = mkPackageOption pkgs "rustwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "rustwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "rustwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${rustwm}/bin/rustwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.rustwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = rustwm;
    };

  };

}
