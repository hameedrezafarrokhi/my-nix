{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.rwm;
  rwm = pkgs.callPackage ./rwm.nix { };

in

{

  options = {
    services.xserver.windowManager.rwm = {
      enable = mkEnableOption "rwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before rwm is started.
        '';
      };
      package = mkPackageOption pkgs "rwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "rwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "rwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${rwm}/bin/rwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.rwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = rwm;
    };

  };

}
