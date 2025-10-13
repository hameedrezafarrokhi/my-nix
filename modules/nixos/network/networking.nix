{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.network.enable) {

  networking = {

    useDHCP = lib.mkDefault true;

    networkmanager = {
      enable = true;
     #dns = "default";                   # one of "default", "dnsmasq", "systemd-resolved", "none"
     #dhcp = "internal";                 # one of "dhcpcd", "internal"
     #settings = {}; # submodules in INI format
     #logLevel = "WARN";                 # one of "OFF", "ERR", "WARN", "INFO", "DEBUG", "TRACE"
     #ethernet.macAddress = "preserve";  # string or  one of "permanent", "preserve", "random", "stable"
      wifi = {
       #backend = "wpa_supplicant";     # one of "wpa_supplicant", "iwd"
       #macAddress = "preserve";        # string ("00:11:22:33:44:55") or one of "permanent", "preserve", "random", "stable", "stable-ssid"
        powersave = false;
        scanRandMacAddress = true;
      };
      plugins = with pkgs; [
        networkmanager-openvpn
       #networkmanager-fortisslvpn
       #networkmanager-iodine
       #networkmanager-l2tp
       #networkmanager-openconnect
       #networkmanager-sstp
       #networkmanager-strongswan
       #networkmanager-vpnc
      ];
     #ensureProfiles = {
     #  secrets = {
     #    entries = {};
     #    package = pkgs.nm-file-secret-agent;
     #  };
     #  profiles = {};
     #};
     #environmentFiles = [];
    };

   #wireless = {              # ONLY ONE OF THIS OR NETWORKMANAGER
   #  enable = true;
   #  allowAuxiliaryImperativeNetworks = true;
   #  dbusControlled = true;
   #  driver = "nl80211,wext";
   #  fallbackToWPA2 = true;
   #  scanOnLowSignal = false;
   #  userControlled = {
   #    enable = true;
   #    group = "wheel";
   #  };
   #  interfaces = [ ];
   #  iwd = {
   #    enable = true;
   #    package = pkgs.iwd;
   #   #settings = { };
   #  };
   # #networks = { };
   #};

   #proxy = {                                    #MOVE to VPN.NIX
   #  default = "http://user:password@proxy:port/";
   #  noProxy = "127.0.0.1,localhost,internal.domain";
   #};

   #firewall = {
   #  enable = lib.mkForce false;
   #  # Open ports in the firewall.
   # #allowedTCPPorts = [ 80 443 ];
   # #allowedUDPPortRanges = [
   # #  { from = 4000; to = 4007; }
   # #  { from = 8000; to = 8010; }
   # #];
   #};
  };

};}
