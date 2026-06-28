{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.oxidewm;
  oxidewm = pkgs.callPackage ./oxidewm.nix { };

in

{

  options = {
    services.xserver.windowManager.oxidewm = {
      enable = mkEnableOption "oxidewm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before oxidewm is started.
        '';
      };
      package = mkPackageOption pkgs "oxidewm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "oxidewm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "oxidewm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${oxidewm}/bin/oxide &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.oxidewm = {
      enable = true;
      extraSessionCommands = '' '';
      package = oxidewm;
    };

  };

}
