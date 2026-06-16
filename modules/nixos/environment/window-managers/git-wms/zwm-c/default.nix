{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.zwm-c;
  zwm-c = pkgs.callPackage ./zwm-c.nix { };

in

{

  options = {
    services.xserver.windowManager.zwm-c = {
      enable = mkEnableOption "zwm-c";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before zwm-c is started.
        '';
      };
      package = mkPackageOption pkgs "zwm-c" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "zwm-c" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "zwm-c";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${zwm-c}/bin/zwm-c &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.zwm-c = {
      enable = true;
      extraSessionCommands = '' '';
      package = zwm-c;
    };

  };

}
