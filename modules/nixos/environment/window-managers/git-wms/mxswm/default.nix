{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.mxswm;
  mxswm = pkgs.callPackage ./mxswm.nix { };

in

{

  options = {
    services.xserver.windowManager.mxswm = {
      enable = mkEnableOption "mxswm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before mxswm is started.
        '';
      };
      package = mkPackageOption pkgs "mxswm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "mxswm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "mxswm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${mxswm}/bin/mxswm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.mxswm = {
      enable = true;
      extraSessionCommands = '' '';
      package = mxswm;
    };

  };

}
