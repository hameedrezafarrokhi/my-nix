{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.sewm;
  sewm = pkgs.callPackage ./sewm.nix { };

in

{

  options = {
    services.xserver.windowManager.sewm = {
      enable = mkEnableOption "sewm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before sewm is started.
        '';
      };
      package = mkPackageOption pkgs "sewm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "sewm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "sewm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${sewm}/bin/sewm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.sewm = {
      enable = true;
      extraSessionCommands = '' '';
      package = sewm;
    };

  };

}
