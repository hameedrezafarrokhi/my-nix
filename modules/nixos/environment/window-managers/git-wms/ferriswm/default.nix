{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.ferriswm;
  ferriswm = pkgs.callPackage ./ferriswm.nix { };

in

{

  options = {
    services.xserver.windowManager.ferriswm = {
      enable = mkEnableOption "ferriswm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before ferriswm is started.
        '';
      };
      package = mkPackageOption pkgs "ferriswm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "ferriswm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "ferriswm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${ferriswm}/bin/ferriswm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.ferriswm = {
      enable = true;
      extraSessionCommands = '' '';
      package = ferriswm;
    };

  };

}
