{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.basketcase;
  basketcase = pkgs.callPackage ./basketcase.nix { };

in

{

  options = {
    services.xserver.windowManager.basketcase = {
      enable = mkEnableOption "basketcase";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before basketcase is started.
        '';
      };
      package = mkPackageOption pkgs "basketcase" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "basketcase" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "basketcase";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${basketcase}/bin/basketcase &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.basketcase = {
      enable = true;
      extraSessionCommands = '' '';
      package = basketcase;
    };

  };

}
