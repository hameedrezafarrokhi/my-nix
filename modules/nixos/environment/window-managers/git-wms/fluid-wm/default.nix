{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.fluid-wm;
  fluid-wm = pkgs.callPackage ./fluid-wm.nix { };

in

{

  options = {
    services.xserver.windowManager.fluid-wm = {
      enable = mkEnableOption "fluid-wm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before fluid-wm is started.
        '';
      };
      package = mkPackageOption pkgs "fluid-wm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "fluid-wm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "fluid-wm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${fluid-wm}/bin/fluid_wm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.fluid-wm = {
      enable = true;
      extraSessionCommands = '' '';
      package = fluid-wm;
    };

  };

}
