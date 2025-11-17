{ config, pkgs, lib, ... }:

  with lib.hm.gvariant;

{ config = lib.mkIf (config.my.apps.dockbarx.enable) {

  dconf.settings = {

    "org/dockbarx/dockbarx" = {
      badge-custom-bg-color = false;
      badge-custom-fg-color = false;
      badge-fg-color = "#bf4040";
      launchers = [
        "dolphin;/etc/profiles/per-user/hrf/share/applications/org.kde.dolphin.desktop"
        "kitty;/etc/profiles/per-user/hrf/share/applications/kitty.desktop"
        "brave;/run/current-system/sw/share/applications/brave-browser.desktop"
        "kate;/etc/profiles/per-user/hrf/share/applications/org.kde.kate.desktop"
      ];
      old-menu = true;
      theme = "DockXYZ";
    };

    "org/dockbarx/dockbarx/themes/colors" = {
      color1 = "default";
      color1-alpha = -1;
      color2 = "default";
      color2-alpha = -1;
      color3 = "default";
      color3-alpha = -1;
      color4 = "default";
      color4-alpha = -1;
      color5 = "default";
      color5-alpha = -1;
      color6 = "default";
      color6-alpha = -1;
      color7 = "default";
      color7-alpha = -1;
      color8 = "default";
      color8-alpha = -1;
      popup-style-file = "Colors.tar.gz";
    };

    "org/dockbarx/dockbarx/themes/deep" = {
      color1 = "default";
      color1-alpha = -1;
      color2 = "default";
      color2-alpha = -1;
      color3 = "default";
      color3-alpha = -1;
      color4 = "default";
      color4-alpha = -1;
      color5 = "default";
      color5-alpha = -1;
      color6 = "default";
      color6-alpha = -1;
      color7 = "default";
      color7-alpha = -1;
      color8 = "default";
      color8-alpha = -1;
      popup-style-file = "dbx.tar.gz";
    };

    "org/dockbarx/dockbarx/themes/dmd_glass" = {
      color1 = "#bf4040";
      color1-alpha = 0;
      color2 = "default";
      color2-alpha = -1;
      color3 = "#bf4040";
      color3-alpha = 0;
      color4 = "#bf4040";
      color4-alpha = 0;
      color5 = "default";
      color5-alpha = -1;
      color6 = "default";
      color6-alpha = -1;
      color7 = "default";
      color7-alpha = -1;
      color8 = "default";
      color8-alpha = -1;
      popup-style-file = "Magic_trans.tar.gz";
    };

    "org/dockbarx/dockbarx/themes/dockxyz" = {
      color1 = "#1e2030";
      color1-alpha = 255;
      color2 = "default";
      color2-alpha = -1;
      color3 = "default";
      color3-alpha = -1;
      color4 = "default";
      color4-alpha = -1;
      color5 = "default";
      color5-alpha = -1;
      color6 = "default";
      color6-alpha = -1;
      color7 = "default";
      color7-alpha = -1;
      color8 = "default";
      color8-alpha = -1;
      popup-style-file = "deep.tar.gz";
    };

    "org/dockbarx/dockbarx/themes/glassified" = {
      color1 = "default";
      color1-alpha = -1;
      color2 = "default";
      color2-alpha = -1;
      color3 = "default";
      color3-alpha = -1;
      color4 = "default";
      color4-alpha = -1;
      color5 = "default";
      color5-alpha = -1;
      color6 = "default";
      color6-alpha = -1;
      color7 = "default";
      color7-alpha = -1;
      color8 = "default";
      color8-alpha = -1;
      popup-style-file = "gradent.tar.gz";
    };

    "org/dockbarx/dockbarx/themes/magic_tranparency" = {
      color1 = "default";
      color1-alpha = -1;
      color2 = "default";
      color2-alpha = -1;
      color3 = "default";
      color3-alpha = -1;
      color4 = "default";
      color4-alpha = -1;
      color5 = "default";
      color5-alpha = -1;
      color6 = "default";
      color6-alpha = -1;
      color7 = "default";
      color7-alpha = -1;
      color8 = "default";
      color8-alpha = -1;
      popup-style-file = "Magic_trans.tar.gz";
    };

    "org/dockbarx/dockbarx/themes/sunny_colors" = {
      color1 = "default";
      color1-alpha = -1;
      color2 = "default";
      color2-alpha = -1;
      color3 = "default";
      color3-alpha = -1;
      color4 = "default";
      color4-alpha = -1;
      color5 = "default";
      color5-alpha = -1;
      color6 = "default";
      color6-alpha = -1;
      color7 = "default";
      color7-alpha = -1;
      color8 = "default";
      color8-alpha = -1;
      popup-style-file = "Radiance.tar.gz";
    };

    "org/dockbarx/dockx" = {
      behavior = "dodge active window"; # "dodge windows"; # "dodge active window";
      position = "left";
      theme-file = "invisible.tar.gz";
      type = "dock";
    };

   #"org/dockbarx/dockx/themes/dbx/tar/gz" = {
   #  colors = {
   #    bg_color = "default";
   #    bg_alpha = "default";
   #    bar2_bg_color = "default";
   #    bar2_bg_alpha = "default";
   #  };
   #};

  };

  home.packages = [

    pkgs.dockbarx

  ];

};}
