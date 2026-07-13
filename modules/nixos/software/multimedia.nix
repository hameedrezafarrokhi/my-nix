{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.multimedia.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

  ############################################################   VIDEO_PLAYER

    vlc                           ##VLC!!
   #vlc-bittorrent
    mpv                           ##MPV backend
   #mpv-handler                   ##For web
   #mpvc                          ##Mpc-like control interface for mpv
   #smplayer                      ##MPV frontend
   #showtime                      ##GOOD video player
   #handbrake                     ##CD/DVD ripper/player
   #ruffle                        ##Flash player
   #celluloid                     ##MPV backend (Another)
    mplayer

   #bink-player   # player for bink formats
   #cosmic-player # cosmic media player

  ############################################################   MUSIC_PLAYER

    amberol                       ##Modern music player
   #decibels                      ##Modern music player (gnome)
   #gnome-music                   ##Gnome music player
   #resonance                     ##Modern music player (Another)
    qmmp                          ##Old music player (winapm)
   #audacious                     ##Old music player
   #audacious-plugins
   #parlatype                     ##Another Gnome Music Player

   #spotify                       ##Spotify Client (unofficial)
   #spotdl                        ##Spotify Downloader
   #spotify-player                ##Spotify tui
   #monophony                     ##Online music player
   #mousai                        ##Shazam for linux
   #shortwave                     ##Online radio
   #kdePackages.audiotube         ##KDE online music (not good)

   #cozy                          ##Audiobook manager
   #blanket                       ##White noises and ambient

   #cavalier                      ##Visualisation for audio
   #eartag                        ##Audio metadata editor

    termusic
    ytermusic
    ytui-music
   #get_iplayer  # bbc programs

   #musicus      # classical music specialty
   #musicfree-desktop  # plugin support
    kew          # command line
   #fooyin       # customisable
   #roon-bridge
   #roon-server
    sayonara
   #clementine
   #strawberry
   #mikmod       # tui
   #lollypop     # gnome music player
   #nuclear      # free streaming
   #recordbox
   #amarok       # kde music player
   #sonata
    nulloy       # waveform progress bar
   #exaile
    tauon
   #headset      # music player for youtube and reddit
   #deadbeef
   #cmus
   #cmusfm       # last.fm/libre.fm for cmus
   #museeks
   #musikcube    # tui
   #gapless
   #cplay-ng     # tui/ncurses
    waves        # tui/keyboard driven
    cliamp       # tui/winamp like
   #cider-2
   #musicpod     # music/radio/tv/podcast
   #qmplay2
   #qmplay2-qt5
   #qmplay2-qt6
   #quodlibet-full  # builtin matugen
   #quodlibet
   #quodlibet-xine-full
   #quodlibet-xine
   #hqplayerd
   #hqplayer-desktop
   #yandex-music  # music suggestion?
   #mopidy-ytmusic # youtube music extension
   #glide-media-player
   #rustplayer    # tui
   #kopuz


   #media-player-info  # data files for media
   #penguin-subtitle-player # standalone subtitle player

   #turntable    # scrobbles to multiple servers



  ################################################################   PICTURES

    pix                           ##Image viewer (Cinnamon)
   #nomacs                        ##Image viewer (Titus)
   #loupe                         ##Image viewer (Gnome)
    shotwell                      ##Image viewer (KDE-old)
    kdePackages.gwenview          ##Image viewer (KDE)
   #kdePackages.koko              ##Image viewer (KDE)
   #komikku                       ##Comicbook viewer
   #identity                      ##Compare images side-by-side
   #digikam                       ##Photo
   #switcheroo                    ##Image Conversion
   #converseen                    ##Bulk image editor

  ] ) config.my.software.multimedia.exclude)

   ++

  config.my.software.multimedia.include;

};}
