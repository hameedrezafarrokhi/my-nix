{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.multimedia.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

  ############################################################   VIDEO_PLAYER

    vlc                           ##VLC!!
    vlc-bittorrent
    mpv                           ##MPV backend
    mpv-handler                   ##For web
    mpvc                          ##Mpc-like control interface for mpv
    smplayer                      ##MPV frontend
    showtime                      ##GOOD video player
    handbrake                     ##CD/DVD ripper/player
   #ruffle                        ##Flash player
   #celluloid                     ##MPV backend (Another)

  ############################################################   MUSIC_PLAYER

    amberol                       ##Modern music player
    decibels                      ##Modern music player (gnome)
    gnome-music                   ##Gnome music player
    resonance                     ##Modern music player (Another)
   #qmmp                          ##Old music player (winapm)
    audacious                     ##Old music player
    parlatype                     ##Another Gnome Music Player

    spotify                       ##Spotify Client (unofficial)
    spotdl                        ##Spotify Downloader
    monophony                     ##Online music player
    mousai                        ##Shazam for linux
    shortwave                     ##Online radio
   #kdePackages.audiotube         ##KDE online music (not good)

    cozy                          ##Audiobook manager
    blanket                       ##White noises and ambient

   #cavalier                      ##Visualisation for audio
    eartag                        ##Audio metadata editor

  ################################################################   PICTURES

    pix                           ##Image viewer (Cinnamon)
    nomacs                        ##Image viewer (Titus)
    loupe                         ##Image viewer (Gnome)
    shotwell                      ##Image viewer (KDE-old)
    kdePackages.gwenview          ##Image viewer (KDE)
    kdePackages.koko              ##Image viewer (KDE)
    komikku                       ##Comicbook viewer
    identity                      ##Compare images side-by-side
    digikam                       ##Photo
    switcheroo                    ##Image Conversion
    converseen                    ##Bulk image editor

  ] ) config.my.software.multimedia.exclude)

   ++

  config.my.software.multimedia.include;

};}
