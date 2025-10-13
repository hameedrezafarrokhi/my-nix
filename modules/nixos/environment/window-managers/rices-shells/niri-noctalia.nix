{ config, pkgs, lib, ... }:

let

  Niri-Noctalia = pkgs.writeShellScriptBin "Niri-Noctalia" ''
    DESKTOP_SESSION=Niri-Noctalia ${config.programs.niri.package}/bin/niri-session
  '';

in

{ config = lib.mkIf (builtins.elem "niri-noctalia" config.my.rices-shells) {

  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile {
      name = "Niri-Noctalia";
      text = ''
        [Desktop Entry]
        Name=Niri-Noctalia
        Comment=Niri with DankMaterialShell
        Exec=${Niri-Noctalia}/bin/Niri-Noctalia
        TryExec=${Niri-Noctalia}/bin/Niri-Noctalia
        Type=Application
        DesktopNames=niri
      '';
      destination = "/share/wayland-sessions/Niri-Noctalia.desktop";
     #derivationArgs = {
     #  passthru.providedSessions = [ "budgie-env" ];
     #};
    } // { providedSessions = [ "Niri-Noctalia" ]; })
  ];

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      Niri-Noctalia = {
        prettyName = "Niri-Noctalia";
        comment = "Niri with DankMaterialShell (UWSM)";
        binPath = "${Niri-Noctalia}/bin/Niri-Noctalia";
      };
    };
  };

  environment.systemPackages = [ Niri-Noctalia ];

};}
