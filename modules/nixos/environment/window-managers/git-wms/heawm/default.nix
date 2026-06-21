{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.heawm;
  heawm = pkgs.callPackage ./heawm.nix { };

in

{

  options = {
    services.xserver.windowManager.heawm = {
      enable = mkEnableOption "heawm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before heawm is started.
        '';
      };
      package = mkPackageOption pkgs "heawm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "heawm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "heawm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${heawm}/bin/heawm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package pkgs.dash ];

    services.xserver.windowManager.heawm = {
      enable = true;
      extraSessionCommands = '' '';
      package = heawm;
    };

  };

}
