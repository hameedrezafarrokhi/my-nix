{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.alacritty.enable) {

  programs.alacritty = {

    enable = true;
    package = pkgs.alacritty;
    themePackage = pkgs.alacritty-theme;
    settings = {
      window = {
        title = "Alacritty";
        decorations = "none";
        blur = true;
        opacity = 0.9;
        padding.x = 10;
        padding.y = 10;
        dimensions = {
          columns = 160;
          lines = 80;
        };
       #cursor.style = {
       #  shape = "Beam";
       #  blinking = "Never";
       #};
       #colors = {
       # #transparent_background_colors = true;
       #  draw_bold_text_with_bright_colors = true;
       #};
       #env = {
       #  TERM = "xterm-256color";
       #};
      };
    };
   #theme = "";

  };

};}
