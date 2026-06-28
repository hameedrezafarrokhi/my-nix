{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.rustile;
  rustile = pkgs.callPackage ./rustile.nix { };

in

{

  options = {
    services.xserver.windowManager.rustile = {
      enable = mkEnableOption "rustile";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before rustile is started.
        '';
      };
      package = mkPackageOption pkgs "rustile" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "rustile" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "rustile";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${rustile}/bin/rustile &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.rustile = {
      enable = true;
      extraSessionCommands = '' '';
      package = rustile;
    };

  };

}
