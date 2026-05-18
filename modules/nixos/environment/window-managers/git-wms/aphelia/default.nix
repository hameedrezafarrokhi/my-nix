{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.aphelia;
  aphelia = pkgs.callPackage ./aphelia.nix { };

in

{

  options = {
    services.xserver.windowManager.aphelia = {
      enable = mkEnableOption "aphelia";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before aphelia is started.
        '';
      };
      package = mkPackageOption pkgs "aphelia" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "aphelia" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "aphelia";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${aphelia}/bin/aphelia &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.aphelia = {
      enable = true;
      extraSessionCommands = '' '';
      package = aphelia;
    };

  };

}
