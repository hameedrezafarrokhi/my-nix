{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (config.my.xdg.enable) {

  # location:       /run/current-system/sw/share/xdg-desktop-portal/
  # location:(user) /home/hrf/.config/xdg-desktop-portal/

  environment.pathsToLink = [
    "/libexec"
    "/share" # WARNING FIX ME, LINK ONLY SUBDIRS
    "/share/xdg-desktop-portal"
    "/share/applications"
    "/share/nautilus-python/extensions"
  ];

  # Portals for DEs to interact, i.e. Notifs, FilePicker, etc:
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = config.home-manager.users.${admin}.xdg.portal.extraPortals;
    wlr = {
      enable = true;
     #settings = {
     #  screencast = {
     #    output_name = "HDMI-A-1";
     #    max_fps = 30;
     #    exec_before = "disable_notifications.sh";
     #    exec_after = "enable_notifications.sh";
     #    chooser_type = "simple";
     #    chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
     #  };
     #};
    };

   #configPackages = [ pkgs.gnome-session ];

   #config = {
   #  common = {
   #    default = [
   #      "*" "gtk" "hyprland" "kde"
   #    ];
   #  };
   #  hyprland = {
   #    default = ["hyprland" "gtk" "kde"];
   #  };
   #};
  };

  environment.systemPackages = with pkgs; [
    door-knocker    ##Check if portals working
  ];

};}
