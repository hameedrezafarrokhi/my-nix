{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager._9wm;
  _9wm = pkgs.callPackage ./9wm.nix { };

in

{

  options = {
    services.xserver.windowManager._9wm = {
      enable = mkEnableOption "9wm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before 9wm is started.
        '';
      };
      package = mkPackageOption pkgs "9wm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "9wm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "9wm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${_9wm}/bin/9wm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager._9wm = {
      enable = true;
      extraSessionCommands = '' '';
      package = _9wm;
    };

  };

}
