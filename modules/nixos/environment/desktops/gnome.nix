{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "gnome" config.my.desktops) {

  services.xserver.desktopManager.gnome = {
    enable = true;
    debug = false;
   #sessionPath = [ ];
   #extraGSettingsOverrides = "";
   #extraGSettingsOverridePackages = [ ];

    flashback = {
      panelModulePackages = [ pkgs.gnome-applets ];
      enableMetacity = false;
      customSessions = [
       #{
       #  "*" = {
       #    wmName = "i3";
       #    wmLabel = "i3";
       #    wmCommand = "${pkgs.i3}/bin/i3";
       #    enableGnomePanel = true;
       #  };
       #}
      ];
    };

  };

  services.gnome = {

    core-shell.enable = true;
    core-os-services.enable = true;
    core-developer-tools.enable = true;
    core-apps.enable = true;
    at-spi2-core.enable = true;

    gnome-user-share.enable = true;
    gnome-settings-daemon.enable = true;
    gnome-remote-desktop.enable = true;
    gnome-online-accounts.enable = true;
    gnome-keyring.enable = true;
   #gnome-initial-setup.enable = true;
    gnome-browser-connector.enable = true;

    glib-networking.enable = true;
    gcr-ssh-agent = {
      package = pkgs.gcr_4;
      enable = true;
    };

    evolution-data-server = {
      enable = true;
      plugins = [ ];
    };
    rygel = {
      package = pkgs.rygel;
      enable = true;
    };

    tinysparql.enable = true;
    sushi.enable = true;
    localsearch.enable = true;
    games.enable = true;

  };

};}
