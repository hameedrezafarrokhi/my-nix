{ config, pkgs, lib, admin, options, ... }:

let

  inherit (lib)
    mkOption
    types
    literalExpression
    optionalString
    ;

  xremap-yaml = pkgs.writeText "xremap-yaml-config.yaml" config.home-manager.users.${admin}.services.xremap.yamlConfig;

  mate-env = pkgs.writeShellScriptBin "mate-env" ''
    export NIX_GSETTINGS_OVERRIDES_DIR=${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas

    /run/current-system/systemd/bin/systemctl --user stop nixos-fake-graphical-session.target

    export NIX_GSETTINGS_OVERRIDES_DIR=${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas

    exec ${pkgs.mate.mate-session-manager}/bin/mate-session
    xremap --watch --mouse ${xremap-yaml}

    export NIX_GSETTINGS_OVERRIDES_DIR=${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas
  '';

 #mate-env-desktop = (pkgs.writeTextDir "share/xsessions/mate-gs-env.desktop" ''
 #  [Desktop Entry]
 #  Name=Mate Desktop with Env
 #  Comment=This session logs you into the Mate Desktop
 #  Exec=${mate-env}/bin/mate-env
 #  TryExec=${mate-env}/bin/mate-env
 #  Icon=
 #  Type=Application
 #  DesktopNames=Mate;GNOME
 #'');

in

{ config = lib.mkIf (builtins.elem "mate" config.my.desktops) {

  services.xserver.desktopManager.mate = {
    enable = true;
    debug = false;
    enableWaylandSession = true;
    extraCajaExtensions = [ ];
    extraPanelApplets = with pkgs.mate; [ mate-applets ];
  };

  environment.mate.excludePackages = [ ];

  environment.systemPackages = [
    mate-env
   #mate-env-desktop
  ];

  environment.shellAliases = {

    matmat = "startx ${mate-env}/bin/mate-env";

  };

  services.displayManager.sessionPackages = [

    (pkgs.writeTextFile {
      name = "mate-env";
      text = ''
        [Desktop Entry]
        Name=MATE (env)
        Comment=This session logs you into MATE
        Exec=${mate-env}/bin/mate-env
        TryExec=${mate-env}/bin/mate-env
        Type=Application
        DesktopNames=MATE
        Keywords=launch;MATE;desktop;session;
      '';
      destination = "/share/xsessions/mate-env.desktop";
     #derivationArgs = {
     #  passthru.providedSessions = [ "mate-env" ];
     #};
    } // { providedSessions = [ "mate-env" ]; })

  ];

};}
