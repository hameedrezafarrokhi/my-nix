{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.amiwb;
  amiwb = pkgs.callPackage ./amiwb.nix { };

in

{

  options = {
    services.xserver.windowManager.amiwb = {
      enable = mkEnableOption "amiwb";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before amiwb is started.
        '';
      };
      package = mkPackageOption pkgs "amiwb" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "amiwb" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "amiwb";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${amiwb}/bin/amiwb &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.amiwb = {
      enable = true;
      extraSessionCommands = '' '';
      package = amiwb;
    };

  };

}
