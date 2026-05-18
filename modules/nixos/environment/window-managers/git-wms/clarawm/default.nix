{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.clarawm;
  clarawm = pkgs.callPackage ./clarawm.nix { };

in

{

  options = {
    services.xserver.windowManager.clarawm = {
      enable = mkEnableOption "clarawm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before clarawm is started.
        '';
      };
      package = mkPackageOption pkgs "clarawm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "clarawm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "clarawm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${clarawm}/bin/clarawm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.clarawm = {
      enable = true;
      extraSessionCommands = '' '';
      package = clarawm;
    };

  };

}
