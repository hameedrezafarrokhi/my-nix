{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.internet.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

    brave                         ##Chromium spin
   #firefox                       ##Its just Firefox
   #firefox-esr                   ##Firefox LTS version
    firefoxpwa                    ##Firefox WebApps
   #mullvad-browser               ##Firefox spin with vpn
   #librewolf                     ##Firefox spin of libre
   #librewolf-bin
   #epiphany                      ##Gnome browser
   #floorp                        ##Firefox spin
   #qutebrowser

    browsh

   #thunderbird
   #evolution                     ##Email Client
    freetube                      ##YouTube Client
   #pipeline                      ##YouTube Client

   #wike                          ##Wikipedia Client
   #tangram                       ##WebApp Saver/Loader

   #newsflash                     ##RSS reader
   #read-it-later                 ##Save HTML for reading



    uget                          ##Not bad DL manager
    kdePackages.kget              ##KDE DL manager
   #persepolis                    ##Another DL manager

    kdePackages.ktorrent          ##Torrent (KDE)
   #deluge-gtk                    ##Torrent
   #deluge                        ##Torrent (CLI)
   #transmission_4-qt6            ##Torrent for Cinnamon
   #varia                         ##Torrent modern GTK (Another)
   #fragments                     ##Torrent modern GTK
   #qbittorrent                   ##Torrent

   #youtube-dl
   #ytdl-sub                      ##automate downloads (set options)
    ytdownloader                  ##Video/YouTube DL
    parabolic                     ##Video/YouTube DL
    video-downloader
    media-downloader

  ] ) config.my.software.internet.exclude)

   ++

  config.my.software.internet.include;

  programs = {

    firefox = {
      enable = true;
      package = pkgs.firefox;
      languagePacks = [ "en-US" "fa" ];
      nativeMessagingHosts = {
        packages = [ pkgs.uget-integrator pkgs.ff2mpv ];
       #ugetIntegrator = true;
       #tridactyl = true;
       #passff = true;
       #jabref = true;
       #gsconnect = true;
       #fxCast = true;
       #euwebid = true;
       #bukubrow = true;
       #browserpass = true;
       #ff2mpv = true;
      };
     #autoConfig = ""
     #autoConfigFiles = [ ];
     #preferencesStatus = "locked"; # one of "default", "locked", "user", "clear"
     #preferences = {
     #  "browser.tabs.tabmanager.enabled" = false;
     #};
     #policies = { };
    };

    chromium = {
      enable = true;
      enablePlasmaBrowserIntegration = true;
      plasmaBrowserIntegrationPackage = lib.mkForce pkgs.kdePackages.plasma-browser-integration;
    };

   #ladybird.enable = true;

   #evolution = {
   #  enable = true;
   # #plugin = [ pkgs.evolution-ews ];
   #};

  };

};}
