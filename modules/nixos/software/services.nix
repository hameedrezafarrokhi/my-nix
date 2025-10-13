{ config, lib, pkgs, admin, ... }:

{ config = lib.mkIf (config.my.software.services.enable) {

  services = {

    gnome.gnome-keyring.enable = true;

    illum.enable = true;

    hardware.openrgb = {
      package = pkgs.openrgb-with-all-plugins;
      enable = true;
     #motherboard = " ";  # "amd" "intel" null
     #server.port = 6742;
    };

    colord.enable = true;

   #redshift = {
   #  enable = true;
   #  package = pkgs.redshift;           #pkg override, lots of options
   #  executable = "/bin/redshift-gtk";
   # #extraOptions = [  ];
   #  temperature = {
   #    day = 5500;
   #    night = 3700;
   #  };
   #  brightness = {
   #    day = "1";
   #    night = "0.5";
   #};

   #buffyboard.enable = true;           #More Options

   #deluge = {
   #  enable = true;
   #  package = pkgs.deluge-gtk;
   # #extraPackages = [  ];
   #  user = "deluge";
   #  group = "deluge";
   #  web = {
   #    enable = true;
   #   #port = 8112;
   #  };
   # #dataDir = "/var/lib/deluge";
   #  declarative = false;  # options below only take effect if this is true!!!
   # #openFirewall = true;
   # #authFile = "";
   # #config = {  # example:
   # #  download_location = "/srv/torrents/";
   # #  max_upload_speed = "1000.0";
   # #  share_ratio_limit = "2.0";
   # #  allow_remote = true;
   # #  daemon_port = 58846;
   # #  listen_ports = [ 6881 6889 ];
   # #};
   #};

   #transmission = {
   #  enable = true;
   #  package = pkgs.transmission_4-qt6;
   #  user = "transmission";
   #  group = "transmission";
   # #home = "/var/lib/transmission";
   # #extraFlags = [ ];
   # #performanceNetParameters = false;
   #  openRPCPort = true;
   #  openPeerPorts = true;
   #  openFirewall = true;
   # #downloadDirPermissions = null;
   # #credentialsFile = "/dev/null";
   #  settings = {
   #    message-level = 2; # between 0 - 6
   #    utp-enabled = true;
   #   #trash-original-torrent-files = false;
   #   #script-torrent-done-enabled = false;
   #   #script-torrent-done-filename = null;
   #   #watch-dir-enabled = true;
   #   #watch-dir = "${config.services.transmission.home}/watchdir";
   #   #umask = "022";
   #   #webHome = null;
   #   #rpc-port = 9091;
   #   #rpc-bind-address = "127.0.0.1";
   #   #peer-port-random-on-start = false;
   #   #peer-port-random-low = 65535;
   #   #peer-port-random-high = 65535;
   #   #peer-port = 51413;
   #   #incomplete-dir-enabled = true;
   #   #incomplete-dir = "${config.services.transmission.home}/.incomplete";
   #   #download-dir = "${config.services.transmission.home}/Downloads";
   #  };
   #};

   #openvpn.enable = true;              #LOOOTS of Options and import protonvpn sftuff

   #mozillavpn.enable = true;
   #mullvad-vpn.enable = true;
    cloudflare-warp = {
      enable = true;
      package = pkgs.cloudflare-warp;
      rootDir = "/var/lib/cloudflare-warp";
      openFirewall = true;
      udpPort = 2408;
    };
   #windscribe = {
   #  enable = true;
   #  autoStart = true;
   #};
   #snowflake-proxy = {
   #  enable = true;
   # #stun = “stun:stun.stunprotocol.org:3478”;
   # #relay =  “wss://snowflake.bamsoftware.com/”;
   # #broker = “https://snowflake-broker.torproject.net/”;
   # #capacity = ;
   #};
   #softether = {
   #  enable = true;
   #  package = pkgs.softether;
   #  dataDir = "/var/lib/softether";
   #  vpnserver.enable = true;
   #  vpnbridge.enable = true;
   #  vpnclient = {
   #    enable = true;
   #   #up = "";
   #   #down = "";
   #  };
   #};
   #logmein-hamachi.enable = false;
   #ivpn.enable = true;
   #expressvpn.enable = true;
   #v2ray = {
   #  enable = true;
   #  package = pkgs.v2ray;
   # #config = {};           #Either config or configFile SHOULD BE SET
   # #configFile = "";
   #};
   #v2raya = {
   #  enable = true;
   #  package = pkgs.v2raya;
   #  cliPackage = pkgs.v2ray; # Or pkgs.xray
   #};
   #xray = {
   #  enable = true;
   #  package = pkgs.xray;
   # #settingsFile = "";
   #  settings = {};
   #};
   #libreswan = {
   #  enable = true;
   # #disableRedirects = true;
   # #connections = {};
   # #configSetup = '' '';
   # #policies = {};
   #};
   #shadowsocks = {};

    ollama = {
      enable = true;
      package = pkgs.ollama;
     #environmentVariables = {};
     #host = "127.0.0.1";
     #port = 11434;
      openFirewall = true;
     #home = "/home/${admin}";
      models = "\${config.services.ollama.home}/models";
      loadModels = [
        #wizardlm-uncensored:13b
        #deepseek-r1
        #gemma3n
      ];
     #user = admin;
     #group = config.services.ollama.user;
    };
    nextjs-ollama-llm-ui = {
      enable = true;
      package = pkgs.nextjs-ollama-llm-ui;
     #ollamaUrl = "http://127.0.0.1:11434";
     #port = 3000;
     #hostname = "127.0.0.1";
    };

    locate = {
      enable = true;
      package = pkgs.plocate;
      interval = "never";      # run updatedb manually
     #extraFlags = ;           # Extra flags to pass to updatedb
      prunePaths = [
       "/tmp"
       "/var/tmp"
       "/var/cache"
       "/var/lock"
       "/var/run"
       "/var/spool"
       "/nix/store"
       "/nix/var/log/nix"
      ];
      pruneNames = [ ".bzr" ".cache" ".git" ".hg" ".svn" ];
     #pruneFS = ;
     #pruneBindMounts = ;
      output = "/var/cache/locatedb";
    };
    # GNOME STUFF
    gnome.localsearch.enable = true;
    gnome.tinysparql.enable = true;
    gnome.glib-networking.enable = true;
    sysprof.enable = true;

   #cron = {
   #  enable = true;
   # #mailto = null; # Email address to which job output will be mailed
   # #cronFiles = [ ];
   # #systemCronJobs = [ ];
   #};

   #rsyncd = {
   #  enable = true;
   # #port = 873;
   # #settings = {};
   # #socketActivated = false;
   #};

    gnome.sushi.enable = true;
    gvfs = {
      enable = true;
      package = pkgs.gnome.gvfs;
    };

 #  xserver.desktopManager.retroarch = {
 #   enable = true;
 #   package = pkgs.retroarch-full;
 # # extraArgs = [  ];
 #  };

  };

};}
