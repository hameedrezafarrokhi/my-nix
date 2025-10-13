{ config, pkgs, lib, admin, ... }:

let

  nixos-gsettings-overrides = pkgs.cinnamon-gsettings-overrides.override {
    extraGSettingsOverridePackages = config.services.xserver.desktopManager.cinnamon.extraGSettingsOverridePackages;
    extraGSettingsOverrides = config.services.xserver.desktopManager.cinnamon.extraGSettingsOverrides;
  };

  xremap-yaml = pkgs.writeText "xremap-yaml-config.yaml" config.home-manager.users.${admin}.services.xremap.yamlConfig;

  cinnamon-env = pkgs.writeShellScriptBin "cinnamon-env" ''
    export NIX_GSETTINGS_OVERRIDES_DIR=${nixos-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas
    exec ${pkgs.cinnamon}/bin/cinnamon-session-cinnamon
  '';

  cinnamon-env-try = pkgs.writeShellScriptBin "cinnamon-env-try" ''
    export NIX_GSETTINGS_OVERRIDES_DIR=${nixos-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas
    exec ${pkgs.cinnamon}/bin/cinnamon
    xremap --watch --mouse ${xremap-yaml}
  '';

 #cinnamon-env-desktop = (pkgs.writeTextDir "share/xsessions/cinnamon-gs-env.desktop" ''
 #  [Desktop Entry]
 #  Name=Cinnamon Desktop with Env
 #  Comment=This session logs you into the Cinnamon Desktop
 #  Exec=${cinnamon-env}/bin/cinnamon-env
 #  TryExec=${cinnamon-env}/bin/cinnamon-env
 #  Icon=
 #  Type=Application
 #  DesktopNames=Cinnamon;GNOME
 #'');

in

{ config = lib.mkIf (builtins.elem "cinnamon" config.my.desktops) {

  services.xserver.desktopManager.cinnamon = {
    enable = true;
    sessionPath = [ ];
   #extraGSettingsOverridePackages = [ ];
   #extraGSettingsOverrides = "";
  };

  services.cinnamon.apps.enable = true;
  environment.cinnamon.excludePackages = [ ];

  environment.systemPackages = [
    cinnamon-env
    cinnamon-env-try
   #cinnamon-env-desktop
 ];

  environment.shellAliases = {

    cincin = "startx ${cinnamon-env}/bin/cinnamon-env";

  };

  services.displayManager.sessionPackages = [

    (pkgs.writeTextFile {
      name = "cinnamon-env";
      text = ''
        [Desktop Entry]
        Name=Cinnamon (env)
        Comment=This session logs you into Cinnamon
        Exec=${cinnamon-env}/bin/cinnamon-env
        TryExec=${cinnamon-env-try}/bin/cinnamon-env-try
        Type=Application
      '';
      destination = "/share/xsessions/cinnamon-env.desktop";
     #derivationArgs = {
     #  passthru.providedSessions = [ "cinnamon-env" ];
     #};
    } // { providedSessions = [ "cinnamon-env" ]; })

  ];

};}
