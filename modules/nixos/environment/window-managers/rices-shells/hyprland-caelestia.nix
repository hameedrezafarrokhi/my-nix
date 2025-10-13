{ inputs, config, pkgs, lib, system, ... }:

let

  caelestia = toString ../../../../hm/desktops/hypr/hyprland-caelestia.conf;

  Hyprland-Caelestia = pkgs.writeShellScriptBin "Hyprland-Caelestia" ''
    XDG_CURRENT_DESKTOP=Hyprland ${config.programs.hyprland.package}/bin/Hyprland --config ${caelestia}
  '';

in

{ config = lib.mkIf (builtins.elem "hyprland-caelestia" config.my.rices-shells) {

  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile {
      name = "Hyprland-Caelestia";
      text = ''
        [Desktop Entry]
        Name=Hyprland-Caelestia
        Comment=Hyprland with Caelestia
        Exec=${Hyprland-Caelestia}/bin/Hyprland-Caelestia
        TryExec=${Hyprland-Caelestia}/bin/Hyprland-Caelestia
        Type=Application
        DesktopNames=Hyprland
      '';
      destination = "/share/wayland-sessions/Hyprland-Caelestia.desktop";
    } // { providedSessions = [ "Hyprland-Caelestia" ]; })
  ];

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      Hyprland-Caelestia = {
        prettyName = "Hyprland-Caelestia";
        comment = "Hyprland with Caelestia Shell (UWSM)";
        binPath = "${Hyprland-Caelestia}/bin/Hyprland-Caelestia";
      };
    };
  };

  environment.systemPackages = [ Hyprland-Caelestia ];

};}
