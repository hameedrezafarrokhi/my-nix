{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.network.vpn.enable) {

  environment.systemPackages = with pkgs; [

   #echoip                        ##Show ip cli

    networkmanager-openvpn
    openvpn
   #networkmanager-l2tp
   #xl2tpd
   #networkmanager-iodine
   #iodine
   #networkmanager-fortisslvpn
   #openfortivpn
   #networkmanager-sstp
   #sstp
   #networkmanager-vpnc
   #vpnc
   #networkmanager-openconnect
   #openconnect
   #ocserv
   #ocproxy
   #openconnect_openssl
   #globalprotect-openconnect
   #gpclient
   #gpauth

    protonvpn-gui                 ##Unofficial proton gui
   #protonvpn-cli                 ##Unofficial pronton cli
   #protonvpn-cli_2               ##Unofficial pronton cli (Another)

   #mieru
   #spoofdpi
   #obfs4
   #tractor
   #softether
   #geph
   #cloak-pt
   #riseup-vpn
   #calyx-vpn
   #brook
   #sshuttle
   #eduvpn-client
   #tor-browser
   #tor

   #v2ray
    v2rayn
   #v2raya
   #v2ray-domain-list-community
   #xray


    warp-plus
   #ivpn
   #ivpn-ui
   #ivpn-service
   #openfortivpn
   #openfortivpn-webview
   #openfortivpn-webview-qt
   #expressvpn
   #mullvad-vpn                   ##Mullvad (not free)
   #geph.gui                      ##Geph vpn gui (not working)
   #geph.cli                      ##Geph vpn cli (not working)
   #carburetor                    ##Another vpn (not working)

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

};}
