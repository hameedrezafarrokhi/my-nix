{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.network.avahi.enable) {

  services.avahi = {
    enable = true;
    package = pkgs.avahi;
    hostName = config.networking.hostName;
   #domainName = "local";
   #browseDomains = [ ];

    openFirewall = true;
    wideArea = true;
    reflector = false;
    allowPointToPoint = false;

    ipv6 = config.networking.enableIPv6;
    ipv4 = true;

    publish = {
      enable = false;
      domain = false;
      addresses = false;
      workstation = false;
      userServices = false;
      hinfo = false;
    };

   #nssmdns4 = false;
   #nssmdns6 = false;

   #cacheEntriesMax = null;
   #extraServiceFiles = { };
   #allowInterfaces = null;
   #denyInterfaces = null;
   #extraConfig = '' '';


  };

};}
