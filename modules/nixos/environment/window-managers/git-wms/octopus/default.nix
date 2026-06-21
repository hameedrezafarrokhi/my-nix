{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.octopus;
  octopus = pkgs.callPackage ./octopus.nix { };

in

{

  options = {
    services.xserver.windowManager.octopus = {
      enable = mkEnableOption "octopus";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before octopus is started.
        '';
      };
      package = mkPackageOption pkgs "octopus" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "octopus" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "octopus";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${octopus}/bin/octopus-window-manager &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.octopus = {
      enable = true;
      extraSessionCommands = '' '';
      package = octopus;
    };

  };

}
