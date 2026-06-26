{ config, pkgs, lib, mypkgs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.compiz-reloaded;
  compiz-reloaded = pkgs.callPackage ./compiz-reloaded.nix { };

in

{

  options = {
    services.xserver.windowManager.compiz-reloaded = {
      enable = mkEnableOption "compiz-reloaded";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before compiz is started.
        '';
      };
      package = mkPackageOption pkgs "compiz" {
        example = '' '';
      };
      renderingFlag = mkOption {
        default = "";
        example = "--indirect-rendering";
      };
    };
  };

  config = lib.mkIf (builtins.elem "compiz-reloaded" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "compiz-reloaded";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1

        export COMPIZ_PLUGINDIR=${config.system.path}/lib/compiz
        export COMPIZ_METADATADIR=${config.system.path}/share/compiz

        xsetroot -cursor_name left_ptr &

        ${cfg.extraSessionCommands}

        ${compiz-reloaded}/bin/compiz cpp ${cfg.renderingFlag} &
        ${compiz-reloaded}/bin/gtk-window-decorator &

        #${compiz-reloaded}/bin/compiz &

        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    environment.pathsToLink = [
      "/lib/compiz"
      "/share/compiz"
    ];

    services.xserver.windowManager.compiz-reloaded = {
      enable = true;
      extraSessionCommands = '' '';
      package = compiz-reloaded;
    };

  };

}
