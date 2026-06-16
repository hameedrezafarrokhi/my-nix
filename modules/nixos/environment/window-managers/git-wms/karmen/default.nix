{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.karmen;
  karmen = pkgs.callPackage ./karmen.nix { };

in

{

  options = {
    services.xserver.windowManager.karmen = {
      enable = mkEnableOption "karmen";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before karmen is started.
        '';
      };
      package = mkPackageOption pkgs "karmen" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "karmen" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "karmen";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${karmen}/bin/karmen &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.karmen = {
      enable = true;
      extraSessionCommands = '' '';
      package = karmen;
    };

  };

}
