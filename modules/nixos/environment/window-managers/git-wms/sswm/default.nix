{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.sswm;
  sswm = pkgs.callPackage ./sswm.nix { };

in

{

  options = {
    services.xserver.windowManager.sswm = {
      enable = mkEnableOption "sswm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before sswm is started.
        '';
      };
      package = mkPackageOption pkgs "sswm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "sswm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "sswm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${sswm}/bin/sswm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.sswm = {
      enable = true;
      extraSessionCommands = '' '';
      package = sswm;
    };

  };

}
