{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.waimea;
  waimea = pkgs.callPackage ./waimea.nix { };

in

{

  options = {
    services.xserver.windowManager.waimea = {
      enable = mkEnableOption "waimea";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before waimea is started.
        '';
      };
      package = mkPackageOption pkgs "waimea" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "waimea" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "waimea";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${waimea}/bin/waimea &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.waimea = {
      enable = true;
      extraSessionCommands = '' '';
      package = waimea;
    };

  };

}
