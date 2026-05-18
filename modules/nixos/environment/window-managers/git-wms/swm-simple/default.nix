{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.simplewm;
  simplewm = pkgs.callPackage ./swm.nix { };

in

{

  options = {
    services.xserver.windowManager.simplewm = {
      enable = mkEnableOption "simplewm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before simplewm is started.
        '';
      };
      package = mkPackageOption pkgs "simplewm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "simplewm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "simplewm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${simplewm}/bin/simplewm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.simplewm = {
      enable = true;
      extraSessionCommands = '' '';
      package = simplewm;
    };

  };

}
