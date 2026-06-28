{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.chamferwm;
  chamferwm = pkgs.callPackage ./chamferwm.nix {
    boost = pkgs.boost.override {
      enablePython = true;
      python = pkgs.python3.withPackages (ps: with ps; [
        xlib
        psutil
        setuptools
        boost
      ]);
    };
  };

in

{

  options = {
    services.xserver.windowManager.chamferwm = {
      enable = mkEnableOption "chamferwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before chamferwm is started.
        '';
      };
      package = mkPackageOption pkgs "chamferwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "chamferwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "chamferwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${chamferwm}/bin/chamfer &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.chamferwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = chamferwm;
    };

  };

}
