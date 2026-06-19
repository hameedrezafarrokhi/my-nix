{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.minyaty;
  minyaty = pkgs.callPackage ./minyaty.nix { };

in

{

  options = {
    services.xserver.windowManager.minyaty = {
      enable = mkEnableOption "minyaty";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before minyaty is started.
        '';
      };
      package = mkPackageOption pkgs "minyaty" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "minyaty" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "minyaty";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${minyaty}/bin/minyaty &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
     #pkgs.shards
     # pkgs.crystal
    ];

    services.xserver.windowManager.minyaty = {
      enable = true;
      extraSessionCommands = '' '';
      package = minyaty;
    };

  };

}
