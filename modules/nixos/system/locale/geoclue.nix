{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.geoclue.enable) {

  services.geoclue2 = {
    enable = true;
    package = pkgs.geoclue2;
    submitData = false;
    submissionNick = "geoclue";

    geoProviderUrl = "https://www.googleapis.com/geolocation/v1/geolocate?key=YOUR_KEY";
    submissionUrl = "https://api.beacondb.net/v2/geosubmit";

    enableWifi = true;
    enable3G = true;
    enableCDMA = true;
    enableDemoAgent = false;
    enableModemGPS = true;
    enableNmea = true;

    enableStatic = false;
   #staticAccuracy = ;
   #staticAltitude = ;
   #staticLatitude = ;
   #staticLongitude = ;

    whitelistedAgents = [
      "gnome-shell"
      "io.elementary.desktop.agent-geoclue2"
    ];

   #appConfig = { };
  };

};}
