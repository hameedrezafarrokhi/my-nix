{ config, pkgs, lib, nix-path, admin, ... }:

let

  ashell = toString ../../../../hm/desktops/hypr/hyprland-ashell.conf;

  Hyprland-Ashell = pkgs.writeShellScriptBin "Hyprland-Ashell" ''
    XDG_CURRENT_DESKTOP=Hyprland ${config.programs.hyprland.package}/bin/Hyprland --config ${ashell}
  '';

in

{ config = lib.mkIf (builtins.elem "hyprland-ashell" config.my.rices-shells) {

  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile {
      name = "Hyprland-Ashell";
      text = ''
        [Desktop Entry]
        Name=Hyprland-Ashell
        Comment=Hyprland with Ashell
        Exec=${Hyprland-Ashell}/bin/Hyprland-Ashell
        TryExec=${Hyprland-Ashell}/bin/Hyprland-Ashell
        Type=Application
        DesktopNames=Hyprland
      '';
      destination = "/share/wayland-sessions/Hyprland-Ashell.desktop";
     #derivationArgs = {
     #  passthru.providedSessions = [ "budgie-env" ];
     #};
    } // { providedSessions = [ "Hyprland-Ashell" ]; })
  ];

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      Hyprland-Ashell = {
        prettyName = "Hyprland-Ashell";
        comment = "Hyprland with Ashell (UWSM)";
        binPath = "${Hyprland-Ashell}/bin/Hyprland-Ashell";
      };
    };
  };

  environment.systemPackages = [ Hyprland-Ashell ];

};}
