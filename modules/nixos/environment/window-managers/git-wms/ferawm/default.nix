{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.ferawm;
  ferawm = pkgs.callPackage ./ferawm.nix { };

in

{

  options = {
    services.xserver.windowManager.ferawm = {
      enable = mkEnableOption "ferawm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before ferawm is started.
        '';
      };
      package = mkPackageOption pkgs "ferawm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "ferawm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "ferawm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${ferawm}/bin/ferawm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.ferawm = {
      enable = true;
      extraSessionCommands = '' '';
      package = ferawm;
    };

  };

}
