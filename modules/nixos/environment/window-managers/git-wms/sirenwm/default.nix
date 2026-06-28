{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.sirenwm;
  sirenwm = pkgs.callPackage ./sirenwm.nix { };

in

{

  options = {
    services.xserver.windowManager.sirenwm = {
      enable = mkEnableOption "sirenwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before sirenwm is started.
        '';
      };
      package = mkPackageOption pkgs "sirenwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "sirenwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "sirenwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${sirenwm}/bin/sirenwm-x11 &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.sirenwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = sirenwm;
    };

  };

}
