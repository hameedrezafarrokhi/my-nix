{ inputs, config, pkgs, lib, system, ... }:

let

  Hyprland-UWSM = pkgs.writeShellScriptBin "Hyprland-UWSM" ''
    XDG_CURRENT_DESKTOP=Hyprland Hyprland
  '';

in

{ config = lib.mkIf (builtins.elem "hyprland-uwsm" config.my.rices-shells) {

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      Hyprland-UWSM = {
        prettyName = "Hyprland-UWSM";
        comment = "Hyprland (UWSM)";
        binPath = "${Hyprland-UWSM}/bin/Hyprland-UWSM";
      };
    };
  };

  environment.systemPackages = [ Hyprland-UWSM ];

};}
