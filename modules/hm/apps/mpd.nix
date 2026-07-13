{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.mpd.enable) {

  services.mpd = {

    enable = true;
   #package = pkgs.mpd.override {
   #  features = [
   #    "udisks" "webdav"
   #    # Input plugins
   #    "cdio_paranoia" "curl" "io_uring" "mms" "nfs" "smbclient"
   #    # Archive support
   #    "bzip2" "zzip"
   #    # Decoder plugins
   #    "audiofile" "faad" "ffmpeg" "flac" "fluidsynth" "gme" "mad" "mikmod" "mpg123" "opus" "vorbis"
   #    # Encoder plugins
   #    "vorbisenc" "lame"
   #    # Filter plugins
   #    "libsamplerate" "soxr"
   #    # Output plugins
   #    "alsa" "ao" "jack" "pipewire" "pulse" "shout"
   #    # Commercial services
   #    "qobuz"
   #    # Client support
   #    "libmpdclient"
   #    # Tag support
   #    "id3tag"
   #    # Misc
   #    "dbus" "expat" "icu" "pcre" "sqlite" "syslog" "systemd" "zeroconf"
   #  ];
   #};

   #dataDir = "$XDG_DATA_HOME/mpd";
   #dbFile = "\${dataDir}/tag_cache";
    enableSessionVariables = true;

   #extraArgs = [ ];
   #extraConfig = '' '';
   #generatedConfig = '' '';
    musicDirectory = config.xdg.userDirs.music;
   #playlistDirectory = "\${dataDir}/playlists";

    network = {
      listenAddress = "127.0.0.1"; # "any"
      port = 6600;
      startWhenNeeded = true;
    };

  };

  # MPRIS

  services.mpd-mpris = {
    enable = true;
    package = pkgs.mpd-mpris;
    mpd = {
      host = config.services.mpd.network.listenAddress;
     #network = null; # "tcp" "unix"
      password = null;
      port = config.services.mpd.network.port;
      useLocal = config.services.mpd.enable;
    };
  };

 #services.mpdris2-rs = {
 #  enable = ;
 #  package = ;
 #  host = ;
 #  notifications = {
 #    enable = ;
 #    timeout = ;
 #    body = ;
 #    summary = ;
 #    bodyPaused = ;
 #    summaryPaused = ;
 #  };
 #};

 #services.mpdris2 = {
 #  enable = true;
 #  package = pkgs.mpdris2;
 #  multimediaKeys = ;
 #  notifications = ;
 #  mpd = {
 #    musicDirectory = ;
 #    host = ;
 #    password = ;
 #    port = ;
 #  };
 #};

  # CLIENTS

  programs.ncmpcpp = {
    enable = true;
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };
   #settings = { };
   #bindings = { };
   #mpdMusicDir = config.services.mpd.musicDirectory;
  };

  programs.rmpc = {
    enable = true;
    package = pkgs.rmpc;
   #config = '' '';
  };

  home.packages = [
    # GUI CLIENTS
    pkgs.cantata
    pkgs.euphonica
    pkgs.ymuse
    pkgs.ario
    pkgs.inori
    pkgs.plattenalbum
    pkgs.miniplayer

    # tui
    pkgs.ncmpc
    pkgs.libmpdclient


  ];

};}
