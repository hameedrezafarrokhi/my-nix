{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.mitewm-go;
  mitewm-go = pkgs.callPackage ./mitewm-go.nix { };

in

{

  options = {
    services.xserver.windowManager.mitewm-go = {
      enable = mkEnableOption "mitewm-go";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before mitewm-go is started.
        '';
      };
      package = mkPackageOption pkgs "mitewm-go" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "mitewm-go" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "mitewm-go";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${mitewm-go}/bin/mitewm-go &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.mitewm-go = {
      enable = true;
      extraSessionCommands = '' '';
      package = mitewm-go;
    };

  };

}
