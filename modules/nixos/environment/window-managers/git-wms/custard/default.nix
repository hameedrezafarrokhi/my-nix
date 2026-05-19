{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.custard;
  custard = pkgs.callPackage ./custard.nix { };

in

{

  options = {
    services.xserver.windowManager.custard = {
      enable = mkEnableOption "custard";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before custard is started.
        '';
      };
      package = mkPackageOption pkgs "custard" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "custard" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "custard";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${custard}/bin/custard &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.custard = {
      enable = true;
      extraSessionCommands = '' '';
      package = custard;
    };

  };

}
