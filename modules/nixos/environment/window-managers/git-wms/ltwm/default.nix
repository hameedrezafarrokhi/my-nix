{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.ltwm;
  ltwm = pkgs.callPackage ./ltwm.nix { };

in

{

  options = {
    services.xserver.windowManager.ltwm = {
      enable = mkEnableOption "ltwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before ltwm is started.
        '';
      };
      package = mkPackageOption pkgs "ltwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "ltwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "ltwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${ltwm}/bin/ltwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.ltwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = ltwm;
    };

  };

}
