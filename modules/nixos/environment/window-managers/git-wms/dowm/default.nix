{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.dowm;
  dowm = pkgs.callPackage ./dowm.nix { };

in

{

  options = {
    services.xserver.windowManager.dowm = {
      enable = mkEnableOption "dowm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before dowm is started.
        '';
      };
      package = mkPackageOption pkgs "dowm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "dowm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "dowm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${dowm}/bin/doWM &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.dowm = {
      enable = true;
      extraSessionCommands = '' '';
      package = dowm;
    };

  };

}
