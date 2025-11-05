{ config, pkgs, lib, nix-path, admin, ... }:

let

  ax = toString ../../../../hm/desktops/hypr/hyprland-ax.conf;

  Hyprland-AX = pkgs.writeShellScriptBin "Hyprland-AX" ''
    XDG_CURRENT_DESKTOP=Hyprland ${config.programs.hyprland.package}/bin/Hyprland --config /home/${admin}/.config/hypr/hyprland-ax.conf
  '';

in

{ config = lib.mkIf (builtins.elem "hyprland-ax" config.my.rices-shells) {

  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile {
      name = "Hyprland-AX";
      text = ''
        [Desktop Entry]
        Name=Hyprland-AX
        Comment=Hyprland with AxSell
        Exec=${Hyprland-AX}/bin/Hyprland-AX
        TryExec=${Hyprland-AX}/bin/Hyprland-AX
        Type=Application
        DesktopNames=Hyprland
      '';
      destination = "/share/wayland-sessions/Hyprland-AX.desktop";
     #derivationArgs = {
     #  passthru.providedSessions = [ "budgie-env" ];
     #};
    } // { providedSessions = [ "Hyprland-AX" ]; })
  ];

 #programs.uwsm = {
 #  enable = true;
 #  waylandCompositors = {
 #    Hyprland-AX = {
 #      prettyName = "Hyprland-AX";
 #      comment = "Hyprland with AxShell (UWSM)";
 #      binPath = "${Hyprland-AX}/bin/Hyprland-AX";
 #    };
 #  };
 #};

  environment.systemPackages = [ Hyprland-AX ];

};}
