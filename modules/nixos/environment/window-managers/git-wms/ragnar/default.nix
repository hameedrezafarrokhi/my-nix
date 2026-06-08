{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.ragnar;
  ragnar = pkgs.callPackage ./ragnar.nix { };

in

{

  options = {
    services.xserver.windowManager.ragnar = {
      enable = mkEnableOption "ragnar";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before ragnar is started.
        '';
      };
      package = mkPackageOption pkgs "ragnar" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "ragnar" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "ragnar";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${ragnar}/bin/ragnar &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.ragnar = {
      enable = true;
      extraSessionCommands = '' '';
      package = ragnar;
    };

  };

}
