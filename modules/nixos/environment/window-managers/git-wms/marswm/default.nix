{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.marswm;
  marswm = pkgs.callPackage ./marswm.nix { };

in

{

  options = {
    services.xserver.windowManager.marswm = {
      enable = mkEnableOption "marswm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before marswm is started.
        '';
      };
      package = mkPackageOption pkgs "marswm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "marswm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "marswm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${marswm}/bin/marswm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.marswm = {
      enable = true;
      extraSessionCommands = '' '';
      package = marswm;
    };

  };

}
