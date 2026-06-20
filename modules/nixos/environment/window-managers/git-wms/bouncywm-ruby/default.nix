{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.bouncywm-ruby;
  bouncywm-ruby = pkgs.callPackage ./bouncywm-ruby.nix { };

in

{

  options = {
    services.xserver.windowManager.bouncywm-ruby = {
      enable = mkEnableOption "bouncywm-ruby";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before bouncywm-ruby is started.
        '';
      };
      package = mkPackageOption pkgs "bouncywm-ruby" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "bouncywm-ruby" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "bouncywm-ruby";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${bouncywm-ruby}/bin/bouncywm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.bouncywm-ruby = {
      enable = true;
      extraSessionCommands = '' '';
      package = bouncywm-ruby;
    };

  };

}
