{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.network.torrent.enable) {

  services = {  # Pick only ONE if neccessary

    deluge = {
      enable = true;
      package = pkgs.deluge-gtk;
     #extraPackages = [  ];
      user = "deluge";
      group = "deluge";
      web = {
        enable = true;
       #port = 8112;
      };
     #dataDir = "/var/lib/deluge";
      declarative = false;  # options below only take effect if this is true!!!
     #openFirewall = true;
     #authFile = "";
     #config = {  # example:
     #  download_location = "/srv/torrents/";
     #  max_upload_speed = "1000.0";
     #  share_ratio_limit = "2.0";
     #  allow_remote = true;
     #  daemon_port = 58846;
     #  listen_ports = [ 6881 6889 ];
     #};
    };

    transmission = {
      enable = true;
      package = pkgs.transmission_4-qt6;
      user = "transmission";
      group = "transmission";
     #home = "/var/lib/transmission";
     #extraFlags = [ ];
     #performanceNetParameters = false;
      openRPCPort = true;
      openPeerPorts = true;
      openFirewall = true;
     #downloadDirPermissions = null;
     #credentialsFile = "/dev/null";
      settings = {
        message-level = 2; # between 0 - 6
        utp-enabled = true;
       #trash-original-torrent-files = false;
       #script-torrent-done-enabled = false;
       #script-torrent-done-filename = null;
       #watch-dir-enabled = true;
       #watch-dir = "${config.services.transmission.home}/watchdir";
       #umask = "022";
       #webHome = null;
       #rpc-port = 9091;
       #rpc-bind-address = "127.0.0.1";
       #peer-port-random-on-start = false;
       #peer-port-random-low = 65535;
       #peer-port-random-high = 65535;
       #peer-port = 51413;
       #incomplete-dir-enabled = true;
       #incomplete-dir = "${config.services.transmission.home}/.incomplete";
       #download-dir = "${config.services.transmission.home}/Downloads";
      };
    };

  };

};}
