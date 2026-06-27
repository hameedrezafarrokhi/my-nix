{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.page;
  page = pkgs.callPackage ./page.nix { };

in

{

  options = {
    services.xserver.windowManager.page = {
      enable = mkEnableOption "page";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before page is started.
        '';
      };
      package = mkPackageOption pkgs "page" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "page" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "page";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${page}/bin/page &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.page = {
      enable = true;
      extraSessionCommands = '' '';
      package = page;
    };

  };

}
