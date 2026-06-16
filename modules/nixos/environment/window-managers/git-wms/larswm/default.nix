{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.larswm;
  larswm = pkgs.callPackage ./larswm.nix { };

in

{

  options = {
    services.xserver.windowManager.larswm = {
      enable = mkEnableOption "larswm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before larswm is started.
        '';
      };
      package = mkPackageOption pkgs "larswm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "larswm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "larswm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${larswm}/bin/larswm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.larswm = {
      enable = true;
      extraSessionCommands = '' '';
      package = larswm;
    };

  };

}
