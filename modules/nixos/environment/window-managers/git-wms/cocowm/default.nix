{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.cocowm;
  cocowm = pkgs.callPackage ./cocowm.nix { };

in

{

  options = {
    services.xserver.windowManager.cocowm = {
      enable = mkEnableOption "cocowm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before cocowm is started.
        '';
      };
      package = mkPackageOption pkgs "cocowm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "cocowm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "cocowm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${cocowm}/bin/cocowm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.cocowm = {
      enable = true;
      extraSessionCommands = '' '';
      package = cocowm;
    };

  };

}
