{ config, pkgs, lib, ... }:

let

  Niri-DMS = pkgs.writeShellScriptBin "Niri-DMS" ''
    DESKTOP_SESSION=Niri-DMS ${config.programs.niri.package}/bin/niri-session
  '';

in

{ config = lib.mkIf (builtins.elem "niri-dms" config.my.rices-shells) {

  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile {
      name = "Niri-DMS";
      text = ''
        [Desktop Entry]
        Name=Niri-DMS
        Comment=Niri with DankMaterialShell
        Exec=${Niri-DMS}/bin/Niri-DMS
        TryExec=${Niri-DMS}/bin/Niri-DMS
        Type=Application
        DesktopNames=niri
      '';
      destination = "/share/wayland-sessions/Niri-DMS.desktop";
     #derivationArgs = {
     #  passthru.providedSessions = [ "budgie-env" ];
     #};
    } // { providedSessions = [ "Niri-DMS" ]; })
  ];

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      Niri-DMS = {
        prettyName = "Niri-DMS";
        comment = "Niri with DankMaterialShell (UWSM)";
        binPath = "${Niri-DMS}/bin/Niri-DMS";
      };
    };
  };

  environment.systemPackages = [ Niri-DMS ];

};}
