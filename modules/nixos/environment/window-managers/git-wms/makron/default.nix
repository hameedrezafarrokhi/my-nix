{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.makron;
  libsulfur = pkgs.callPackage ./libsulfur.nix { };
  makron = pkgs.callPackage ./makron.nix {
    libsulfur = libsulfur;
  };

in

{

  options = {
    services.xserver.windowManager.makron = {
      enable = mkEnableOption "makron";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before makron is started.
        '';
      };
      package = mkPackageOption pkgs "makron" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "makron" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "makron";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${makron}/bin/makron &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package libsulfur ];

    services.xserver.windowManager.makron = {
      enable = true;
      extraSessionCommands = '' '';
      package = makron;
    };

  };

}
