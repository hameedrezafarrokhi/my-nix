{ config, pkgs, lib, ... }:

let

  dms = toString ../../../../hm/desktops/hypr/hyprland-dms.conf;

  Hyprland-DMS = pkgs.writeShellScriptBin "Hyprland-DMS" ''
    XDG_CURRENT_DESKTOP=Hyprland ${config.programs.hyprland.package}/bin/Hyprland --config ${dms}
  '';

in

{ config = lib.mkIf (builtins.elem "hyprland-dms" config.my.rices-shells) {

  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile {
      name = "Hyprland-DMS";
      text = ''
        [Desktop Entry]
        Name=Hyprland-DMS
        Comment=Hyprland with DankMaterialShell
        Exec=${Hyprland-DMS}/bin/Hyprland-DMS
        TryExec=${Hyprland-DMS}/bin/Hyprland-DMS
        Type=Application
        DesktopNames=Hyprland
      '';
      destination = "/share/wayland-sessions/Hyprland-DMS.desktop";
     #derivationArgs = {
     #  passthru.providedSessions = [ "budgie-env" ];
     #};
    } // { providedSessions = [ "Hyprland-DMS" ]; })
  ];

 #programs.uwsm = {
 #  enable = true;
 #  waylandCompositors = {
 #    Hyprland-DMS = {
 #      prettyName = "Hyprland-DMS";
 #      comment = "Hyprland with DankMaterialShell (UWSM)";
 #      binPath = "${Hyprland-DMS}/bin/Hyprland-DMS";
 #    };
 #  };
 #};

  environment.systemPackages = [ Hyprland-DMS ];

};}
