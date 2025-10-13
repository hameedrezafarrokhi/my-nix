{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.software.internet.enable) {

  environment.systemPackages = with pkgs; [

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

   #thunderbird
   #evolution                     ##Email Client
    freetube                      ##YouTube Client
    pipeline                      ##YouTube Client

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
    varia                         ##Torrent modern GTK (Another)
    fragments                     ##Torrent modern GTK
   #qbittorrent                   ##Torrent

   #youtube-dl
   #ytdl-sub                      ##automate downloads (set options)
    ytdownloader                  ##Video/YouTube DL
    parabolic                     ##Video/YouTube DL
    video-downloader
    media-downloader

  ];

};
}
