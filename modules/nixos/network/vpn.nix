{ config, lib, pkgs, mypkgs, ... }:

{ config = lib.mkIf (config.my.network.vpn.enable) {

  environment.systemPackages = [

   #pkgs.echoip                        ##Show ip cli

    pkgs.networkmanager-openvpn
    pkgs.openvpn
   #pkgs.networkmanager-l2tp
   #pkgs.xl2tpd
   #pkgs.networkmanager-iodine
   #pkgs.iodine
   #pkgs.networkmanager-fortisslvpn
   #pkgs.openfortivpn
   #pkgs.networkmanager-sstp
   #pkgs.sstp
   #pkgs.networkmanager-vpnc
   #pkgs.vpnc
   #pkgs.networkmanager-openconnect
   #pkgs.openconnect
   #pkgs.ocserv
   #pkgs.ocproxy
   #pkgs.openconnect_openssl
   #pkgs.globalprotect-openconnect
   #pkgs.gpclient
   #pkgs.gpauth

    mypkgs.stable.protonvpn-gui                 ##Unofficial proton gui
   #pkgs.protonvpn-cli                 ##Unofficial pronton cli
   #pkgs.protonvpn-cli_2               ##Unofficial pronton cli (Another)

   #pkgs.mieru
   #pkgs.spoofdpi
   #pkgs.obfs4
   #pkgs.tractor
   #pkgs.softether
   #pkgs.geph
   #pkgs.cloak-pt
   #pkgs.riseup-vpn
   #pkgs.calyx-vpn
   #pkgs.brook
   #pkgs.sshuttle
   #pkgs.eduvpn-client
   #pkgs.tor-browser
   #pkgs.tor

   #pkgs.v2ray
    pkgs.v2rayn
   #pkgs.v2raya
   #pkgs.v2ray-domain-list-community
   #pkgs.xray


    pkgs.warp-plus
   #pkgs.ivpn
   #pkgs.ivpn-ui
   #pkgs.ivpn-service
   #pkgs.openfortivpn
   #pkgs.openfortivpn-webview
   #pkgs.openfortivpn-webview-qt
   #pkgs.expressvpn
   #pkgs.mullvad-vpn                   ##Mullvad (not free)
   #pkgs.geph.gui                      ##Geph vpn gui (not working)
   #pkgs.geph.cli                      ##Geph vpn cli (not working)
   #pkgs.carburetor                    ##Another vpn (not working)

  ];

 #networking.openconnect = {
 #  package = pkgs.openconnect;
 #  interfaces = {
 #    openconnect3 = {
 #      gateway = "Crv3.ghose-nakhor.xyz";
 #      protocol = "anyconnect";
 #      user = "rayan9521";
 #      autoStart = false;
 #     #extraOptions = {};
 #     #certificate = "/var/lib/secrets/openconnect_certificate.pem";  #Example
 #    #passwordFile = "/var/lib/secrets/openconnect-passwd";
 #    #privateKey = "/var/lib/secrets/openconnect_private_key.pem"; #Example
 #    };
 #  };
 #};

  services = {

   #openvpn.enable = true;              #LOOOTS of Options and import protonvpn sftuff

   #mozillavpn.enable = true;

   #mullvad-vpn.enable = true;
    cloudflare-warp = {
      enable = true;
      package = mypkgs.fallback.cloudflare-warp;
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

  };

  programs = {

   #openvpn3 = {
   #  enable = true;
   #  package= pkgs.openvpn3;
   #};
   #amnezia-vpn = {
   #  enable = true;
   #  package = pkgs.amnezia-vpn;
   #};
   #appgate-sdp.enable = true;
   #haguichi.enable = true;

  };

};}
