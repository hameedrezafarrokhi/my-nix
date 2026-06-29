{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.slacker;
  slacker = pkgs.callPackage ./slacker.nix { };

in

{

  options = {
    services.xserver.windowManager.slacker = {
      enable = mkEnableOption "slacker";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before slacker is started.
        '';
      };
      package = mkPackageOption pkgs "slacker" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "slacker" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "slacker";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${slacker}/bin/slacker &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.slacker = {
      enable = true;
      extraSessionCommands = '' '';
      package = slacker;
    };

  };

}
