{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.troodon;
  troodon = pkgs.callPackage ./troodon.nix { };

in

{

  options = {
    services.xserver.windowManager.troodon = {
      enable = mkEnableOption "troodon";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before troodon is started.
        '';
      };
      package = mkPackageOption pkgs "troodon" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "troodon" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "troodon";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${troodon}/bin/troodon &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.troodon = {
      enable = true;
      extraSessionCommands = '' '';
      package = troodon;
    };

  };

}
