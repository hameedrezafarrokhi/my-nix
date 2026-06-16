{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.ctwm;
  ctwm = pkgs.callPackage ./ctwm.nix { };

in

{

  options = {
    services.xserver.windowManager.ctwm = {
      enable = mkEnableOption "ctwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before ctwm is started.
        '';
      };
      package = mkPackageOption pkgs "ctwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "ctwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "ctwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${ctwm}/bin/ctwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.ctwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = ctwm;
    };

  };

}
