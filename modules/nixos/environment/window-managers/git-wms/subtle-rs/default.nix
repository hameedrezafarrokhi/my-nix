{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.subtle-rs;
  subtle-rs = pkgs.callPackage ./subtle-rs.nix { };

in

{

  options = {
    services.xserver.windowManager.subtle-rs = {
      enable = mkEnableOption "subtle-rs";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before subtle-rs is started.
        '';
      };
      package = mkPackageOption pkgs "subtle-rs" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "subtle-rs" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "subtle-rs";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${subtle-rs}/bin/subtle-rs &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.subtle-rs = {
      enable = true;
      extraSessionCommands = '' '';
      package = subtle-rs;
    };

  };

}
