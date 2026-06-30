{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.solbourne;
  solbourne = pkgs.callPackage ./solbourne.nix { };

in

{

  options = {
    services.xserver.windowManager.solbourne = {
      enable = mkEnableOption "solbourne";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before solbourne is started.
        '';
      };
      package = mkPackageOption pkgs "solbourne" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "solbourne" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "solbourne";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${solbourne}/bin/swm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.solbourne = {
      enable = true;
      extraSessionCommands = '' '';
      package = solbourne;
    };

  };

}
