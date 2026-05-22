{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.coma;
  coma = pkgs.callPackage ./coma.nix { };

in

{

  options = {
    services.xserver.windowManager.coma = {
      enable = mkEnableOption "coma";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before coma is started.
        '';
      };
      package = mkPackageOption pkgs "coma" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "coma" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "coma";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${coma}/bin/coma &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.coma = {
      enable = true;
      extraSessionCommands = ''
        xterm &
      '';
      package = coma;
    };

  };

}
