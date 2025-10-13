{ config, pkgs, lib, ... }:

let

  cfg = config.my.cinnamon;

in

{

  options.my.cinnamon.enable = lib.mkEnableOption "cinnamon";

  config = lib.mkIf cfg.enable {

    dconf.settings = {

     #"org/cinnamon" = {
     #  enabled-applets = [ "panel1:left:0:menu@cinnamon.org:0" "panel1:left:1:separator@cinnamon.org:1" "panel1:left:2:grouped-window-list@cinnamon.org:2" "panel1:right:0:systray@cinnamon.org:3" "panel1:right:1:xapp-status@cinnamon.org:4" "panel1:right:2:notifications@cinnamon.org:5" "panel1:right:3:printers@cinnamon.org:6" "panel1:right:4:removable-drives@cinnamon.org:7" "panel1:right:5:keyboard@cinnamon.org:8" "panel1:right:6:favorites@cinnamon.org:9" "panel1:right:7:network@cinnamon.org:10" "panel1:right:8:sound@cinnamon.org:11" "panel1:right:9:power@cinnamon.org:12" "panel1:right:10:calendar@cinnamon.org:13" "panel1:right:11:cornerbar@cinnamon.org:14" ];
     #  next-applet-id = 15;
     #};

     #"org/cinnamon/desktop/background/slideshow" = {
     #  delay = 15;
     #  image-source = "directory:///home/hrf/Pictures";
     #};

      "org/cinnamon/desktop/peripherals/keyboard" = {
        numlock-state = true;
      };

     #"org/cinnamon/desktop/sound" = {
     #  event-sounds = false;
     #};

     #"org/cinnamon/gestures" = {
     #  swipe-down-2 = "PUSH_TILE_DOWN::end";
     #  swipe-down-3 = "TOGGLE_OVERVIEW::end";
     #  swipe-down-4 = "VOLUME_DOWN::end";
     #  swipe-left-2 = "PUSH_TILE_LEFT::end";
     #  swipe-left-3 = "WORKSPACE_NEXT::end";
     #  swipe-left-4 = "WINDOW_WORKSPACE_PREVIOUS::end";
     #  swipe-right-2 = "PUSH_TILE_RIGHT::end";
     #  swipe-right-3 = "WORKSPACE_PREVIOUS::end";
     #  swipe-right-4 = "WINDOW_WORKSPACE_NEXT::end";
     #  swipe-up-2 = "PUSH_TILE_UP::end";
     #  swipe-up-3 = "TOGGLE_EXPO::end";
     #  swipe-up-4 = "VOLUME_UP::end";
     #  tap-3 = "MEDIA_PLAY_PAUSE::end";
     #};

      "org/cinnamon/settings-daemon/peripherals/keyboard" = {
        numlock-state = "on";
      };

     #"org/cinnamon/settings-daemon/plugins/color" = {
     #  night-light-last-coordinates = mkTuple [ 35.4 51.26 ];
     #};

    };

  };

}
