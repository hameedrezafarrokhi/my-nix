{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.hadlock;
  hadlock = pkgs.callPackage ./hadlock.nix { };

in

{

  options = {
    services.xserver.windowManager.hadlock = {
      enable = mkEnableOption "hadlock";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before hadlock is started.
        '';
      };
      package = mkPackageOption pkgs "hadlock" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "hadlock" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "hadlock";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${hadlock}/bin/hadlock &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.hadlock = {
      enable = true;
      extraSessionCommands = '' '';
      package = hadlock;
    };

  };

}
