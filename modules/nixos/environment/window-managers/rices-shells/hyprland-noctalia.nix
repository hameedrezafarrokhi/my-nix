{ inputs, config, pkgs, lib, system, ... }:

let

  noctalia = toString ../../../../hm/desktops/hypr/hyprland-noctalia.conf;

  Hyprland-Noctalia = pkgs.writeShellScriptBin "Hyprland-Noctalia" ''
    XDG_CURRENT_DESKTOP=Hyprland ${config.programs.hyprland.package}/bin/Hyprland --config ${noctalia}
  '';

in

{ config = lib.mkIf (builtins.elem "hyprland-noctalia" config.my.rices-shells) {

  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile {
      name = "Hyprland-Noctalia";
      text = ''
        [Desktop Entry]
        Name=Hyprland-Noctalia
        Comment=Hyprland with Noctalia
        Exec=${Hyprland-Noctalia}/bin/Hyprland-Noctalia
        TryExec=${Hyprland-Noctalia}/bin/Hyprland-Noctalia
        Type=Application
        DesktopNames=Hyprland
      '';
      destination = "/share/wayland-sessions/Hyprland-Noctalia.desktop";
    } // { providedSessions = [ "Hyprland-Noctalia" ]; })
  ];


 #programs.uwsm = {
 #  enable = true;
 #  waylandCompositors = {
 #    Hyprland-Noctalia = {
 #      prettyName = "Hyprland-Noctalia";
 #      comment = "Hyprland with Noctalia Shell (UWSM)";
 #      binPath = "${Hyprland-Noctalia}/bin/Hyprland-Noctalia";
 #    };
 #  };
 #};

  environment.systemPackages = [ Hyprland-Noctalia ];

};}
