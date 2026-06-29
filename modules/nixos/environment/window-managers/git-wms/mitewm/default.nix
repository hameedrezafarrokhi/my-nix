{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.mitewm;
  mitewm = pkgs.callPackage ./mitewm.nix { };

in

{

  options = {
    services.xserver.windowManager.mitewm = {
      enable = mkEnableOption "mitewm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before mitewm is started.
        '';
      };
      package = mkPackageOption pkgs "mitewm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "mitewm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "mitewm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${mitewm}/bin/mitewm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.mitewm = {
      enable = true;
      extraSessionCommands = '' '';
      package = mitewm;
    };

  };

}
