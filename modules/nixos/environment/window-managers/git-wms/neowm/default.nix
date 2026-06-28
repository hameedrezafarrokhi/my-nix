{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.neowm;
  neowm = pkgs.callPackage ./neowm.nix { };

in

{

  options = {
    services.xserver.windowManager.neowm = {
      enable = mkEnableOption "neowm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before neowm is started.
        '';
      };
      package = mkPackageOption pkgs "neowm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "neowm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "neowm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${neowm}/bin/neowm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.neowm = {
      enable = true;
      extraSessionCommands = '' '';
      package = neowm;
    };

  };

}
