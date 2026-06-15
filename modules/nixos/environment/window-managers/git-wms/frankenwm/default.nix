{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.frankenwm;
  frankenwm = pkgs.callPackage ./frankenwm.nix { };

in

{

  options = {
    services.xserver.windowManager.frankenwm = {
      enable = mkEnableOption "frankenwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before frankenwm is started.
        '';
      };
      package = mkPackageOption pkgs "frankenwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "frankenwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "frankenwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${frankenwm}/bin/frankenwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.frankenwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = frankenwm;
    };

  };

}
