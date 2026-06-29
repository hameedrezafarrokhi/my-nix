{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.moksha;
  moksha = pkgs.callPackage ./moksha.nix { };

in

{

  options = {
    services.xserver.windowManager.moksha = {
      enable = mkEnableOption "moksha";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before moksha is started.
        '';
      };
      package = mkPackageOption pkgs "moksha" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "moksha" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "moksha";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${moksha}/bin/moksha &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.moksha = {
      enable = true;
      extraSessionCommands = '' '';
      package = moksha;
    };

  };

}
