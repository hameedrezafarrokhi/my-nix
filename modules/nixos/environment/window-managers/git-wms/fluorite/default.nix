{ config, pkgs, lib, nix-path, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.fluorite;
  fluorite = pkgs.callPackage ./fluorite.nix { };

in

{

  options = {
    services.xserver.windowManager.fluorite = {
      enable = mkEnableOption "fluorite";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before fluorite is started.
        '';
      };
      package = mkPackageOption pkgs "fluorite" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "fluorite" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "fluorite";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${fluorite}/bin/Fluorite &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.fluorite = {
      enable = true;
      extraSessionCommands = ''
        polybar -c ${nix-path}/modules/nixos/environment/window-managers/git-wms/fluorite/Fluorite/dotfiles_examples/catppuccin/polybar/config.ini example &
      '';
      package = fluorite;
    };

  };

}
