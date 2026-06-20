{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.critwm;
  critwm = pkgs.callPackage ./critwm.nix { };

in

{

  options = {
    services.xserver.windowManager.critwm = {
      enable = mkEnableOption "critwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before critwm is started.
        '';
      };
      package = mkPackageOption pkgs "critwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "critwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "critwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${critwm}/bin/critwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.critwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = critwm;
    };

  };

}
