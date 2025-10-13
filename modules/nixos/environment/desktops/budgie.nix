{ config, pkgs, lib, admin, utils, ... }:

let

  nixos-background-light = pkgs.nixos-artwork.wallpapers.nineish;
  nixos-background-dark = pkgs.nixos-artwork.wallpapers.nineish-dark-gray;

  nixos-gsettings-overrides = pkgs.budgie-gsettings-overrides.override {
    inherit (config.services.xserver.desktopManager.budgie) extraGSettingsOverrides extraGSettingsOverridePackages;
    inherit nixos-background-dark nixos-background-light;
  };

  xremap-yaml = pkgs.writeText "xremap-yaml-config.yaml" config.home-manager.users.${admin}.services.xremap.yamlConfig;

  budgie-env = pkgs.writeShellScriptBin "budgie-env" ''
    export NIX_GSETTINGS_OVERRIDES_DIR=${nixos-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas
    exec ${pkgs.budgie-desktop}/bin/budgie-desktop
    exec xremap --watch --mouse ${xremap-yaml}
    test -n "$waitPID" && wait "$waitPID"
  '';

 #budgie-env-desktop = (pkgs.writeTextDir "share/xsessions/budgie-gs-env.desktop" ''
 #  [Desktop Entry]
 #  Name=Budgie Desktop with Env
 #  Comment=This session logs you into the Budgie Desktop
 #  Exec=${budgie-env}/bin/budgie-env
 #  TryExec=${budgie-env}/bin/budgie-env
 #  Icon=
 #  Type=Application
 #  DesktopNames=Budgie;GNOME
 #'');

in


{ config = lib.mkIf (builtins.elem "budgie" config.my.desktops) {

  services.xserver.desktopManager.budgie = {
    enable = true;
    extraPlugins = [ pkgs.budgie-analogue-clock-applet ];
    sessionPath = [ ];
   #extraGSettingsOverridePackages = [ ];
   #extraGSettingsOverrides = "";
  };

  environment.budgie.excludePackages = [ ];

 #services.xserver.desktopManager.session = [
 #  {
 #    name = "budgie-desktop";
 #    prettyName = "Budgie with Env";
 #    manage = "desktop";
 #    desktopNames = [ "Budgie" "GNOME" ];
 #   #bgSupport = true;
 #    start = ''
 #    export NIX_GSETTINGS_OVERRIDES_DIR=${nixos-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas &
 #    ${pkgs.budgie-desktop}/bin/budgie-desktop &
 #    waitPID=$!
 #    '';
 #  }
 #];

  services.displayManager.sessionPackages = [

   #(pkgs.budgie-desktop.overrideAttrs (old: {
   #  postInstall = ''
   #    rm -f $out/share/xsessions/budgie-desktop.desktop
   #    install -Dm644 ${budgie-env-desktop} $out
   #  '';
   #  passthru = {
   #    providedSessions = [ "budgie-env-desktop" ];
   #  };
   #}))

   #(pkgs.writeTextFile {
   #  name = "budgie-env";
   #  text = ''
   #    [Desktop Entry]
   #    Name=Budgie (env)
   #    Comment=Budgie Desktop with envs
   #    Exec=${budgie-env}/bin/budgie-env
   #    Type=Application
   #  '';
   #  destination = "/share/xsessions/budgie-env.desktop";
   #  derivationArgs = {
   #    passthru.providedSessions = [ "budgie-env" ];
   #  };
   #})

    (pkgs.writeTextFile {
      name = "budgie-env";
      text = ''
        [Desktop Entry]
        Name=Budgie (env)
        Comment=This session logs you into the Budgie Desktop
        Exec=${budgie-env}/bin/budgie-env
        TryExec=${budgie-env}/bin/budgie-env
        Type=Application
        DesktopNames=Budgie;GNOME
      '';
      destination = "/share/xsessions/budgie-env.desktop";
     #derivationArgs = {
     #  passthru.providedSessions = [ "budgie-env" ];
     #};
    } // { providedSessions = [ "budgie-env" ]; })

  ];

  environment.systemPackages = [
   #budgie-env-desktop
   budgie-env
  ];

  environment.shellAliases = {

    budbud = "startx ${budgie-env}/bin/budgie-env";

  };

};}
