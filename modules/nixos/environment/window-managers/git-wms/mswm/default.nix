{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.mswm;
  mswm = pkgs.callPackage ./mswm.nix { };

in

{

  options = {
    services.xserver.windowManager.mswm = {
      enable = mkEnableOption "mswm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before mswm is started.
        '';
      };
      package = mkPackageOption pkgs "mswm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "mswm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "mswm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${mswm}/bin/mswm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.mswm = {
      enable = true;
      extraSessionCommands = '' '';
      package = mswm;
    };

  };

}
