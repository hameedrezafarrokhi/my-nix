{ config, pkgs, lib, inputs, ... }:

let

  ambxst = toString ../../../../hm/desktops/hypr/hyprland-ambxst.conf;

  Hyprland-Ambxst = pkgs.writeShellScriptBin "Hyprland-Ambxst" ''
    XDG_CURRENT_DESKTOP=Hyprland ${config.programs.hyprland.package}/bin/Hyprland --config ${ambxst}
  '';

in

{ config = lib.mkIf (builtins.elem "hyprland-ambxst" config.my.rices-shells) {

  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile {
      name = "Hyprland-Ambxst";
      text = ''
        [Desktop Entry]
        Name=Hyprland-Ambxst
        Comment=Hyprland with Ambxst
        Exec=${Hyprland-Ambxst}/bin/Hyprland-Ambxst
        TryExec=${Hyprland-Ambxst}/bin/Hyprland-Ambxst
        Type=Application
        DesktopNames=Hyprland
      '';
      destination = "/share/wayland-sessions/Hyprland-Ambxst.desktop";
     #derivationArgs = {
     #  passthru.providedSessions = [ "budgie-env" ];
     #};
    } // { providedSessions = [ "Hyprland-Ambxst" ]; })
  ];

  programs.ambxst = {
    enable = true;
    package = inputs.ambxst.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

 #programs.uwsm = {
 #  enable = true;
 #  waylandCompositors = {
 #    Hyprland-Ambxst = {
 #      prettyName = "Hyprland-Ambxst";
 #      comment = "Hyprland with Ambxst (UWSM)";
 #      binPath = "${Hyprland-Ambxst}/bin/Hyprland-Ambxst";
 #    };
 #  };
 #};

  environment.systemPackages = [ Hyprland-Ambxst ];

};}
