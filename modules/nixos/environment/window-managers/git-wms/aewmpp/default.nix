{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.aewmpp;
  aewmpp = pkgs.callPackage ./aewmpp.nix { };

in

{

  options = {
    services.xserver.windowManager.aewmpp = {
      enable = mkEnableOption "aewmpp";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before aewmpp is started.
        '';
      };
      package = mkPackageOption pkgs "aewmpp" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "aewmpp" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "aewmpp";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${aewmpp}/bin/aewmpp &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.aewmpp = {
      enable = true;
      extraSessionCommands = '' '';
      package = aewmpp;
    };

  };

}
