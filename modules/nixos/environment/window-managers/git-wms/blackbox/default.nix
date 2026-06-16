{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.blackbox;
  blackbox = pkgs.callPackage ./blackbox.nix { };

in

{

  options = {
    services.xserver.windowManager.blackbox = {
      enable = mkEnableOption "blackbox";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before blackbox is started.
        '';
      };
      package = mkPackageOption pkgs "blackbox" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "blackbox" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "blackbox";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${blackbox}/bin/blackbox &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.blackbox = {
      enable = true;
      extraSessionCommands = '' '';
      package = blackbox;
    };

  };

}
