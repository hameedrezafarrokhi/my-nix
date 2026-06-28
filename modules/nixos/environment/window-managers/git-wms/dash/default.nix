{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.dash;
  dash = pkgs.callPackage ./dash.nix { };

in

{

  options = {
    services.xserver.windowManager.dash = {
      enable = mkEnableOption "dash";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before dash is started.
        '';
      };
      package = mkPackageOption pkgs "dash" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "dash" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "dash";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${dash}/bin/dashwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.dash = {
      enable = true;
      extraSessionCommands = '' '';
      package = dash;
    };

  };

}
