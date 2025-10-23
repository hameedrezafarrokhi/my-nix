{ config, pkgs, lib, ... }:

let

  exo = toString ../../../../hm/desktops/hypr/hyprland-exo.conf;

  Hyprland-Exo = pkgs.writeShellScriptBin "Hyprland-Exo" ''
    XDG_CURRENT_DESKTOP=Hyprland ${config.programs.hyprland.package}/bin/Hyprland --config ${exo}
  '';

in

{ config = lib.mkIf (builtins.elem "hyprland-exo" config.my.rices-shells) {

  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile {
      name = "Hyprland-Exo";
      text = ''
        [Desktop Entry]
        Name=Hyprland-Exo
        Comment=Hyprland with ExoShell (Ignis)
        Exec=${Hyprland-Exo}/bin/Hyprland-Exo
        TryExec=${Hyprland-Exo}/bin/Hyprland-Exo
        Type=Application
        DesktopNames=Hyprland
      '';
      destination = "/share/wayland-sessions/Hyprland-Exo.desktop";
     #derivationArgs = {
     #  passthru.providedSessions = [ "budgie-env" ];
     #};
    } // { providedSessions = [ "Hyprland-Exo" ]; })
  ];

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      Hyprland-Exo = {
        prettyName = "Hyprland-Exo";
        comment = "Hyprland with ExoShell (Ignis) (UWSM)";
        binPath = "${Hyprland-Exo}/bin/Hyprland-Exo";
      };
    };
  };

  environment.systemPackages = [ Hyprland-Exo ];

};}
