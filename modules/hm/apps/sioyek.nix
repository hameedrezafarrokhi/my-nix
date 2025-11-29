{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.sioyek.enable) {

  # documentation:
  # https://sioyek-documentation.readthedocs.io/en/latest/configuration.html#dark-mode-background-color

  programs.sioyek = {
    enable = true;
    package = pkgs.sioyek;
    bindings = {
      "move_up" = "k";
      "move_down" = "j";
      "move_left" = "h";
      "move_right" = "l";
      "screen_down" = [ "d" "" ];
      "screen_up" = [ "u" "" ];
    };
    config = {
     #"background_color" = "1.0 1.0 1.0";

     #"dark_mode_background_color" = "1.0 1.0 1.0";
     #"dark_mode_contrast" = "0.5";
      "ruler_mode" = "1";

     #"link_highlight_color" = "0.4 0.5 0.7";
     #"search_highlight_color" = "0.4 0.5 0.7";
     #"text_highlight_color" = "1.0 0.0 0.0";
     #"synctex_highlight_color" = "0.4 0.5 0.7";

     #"visual_mark_color" = "1.0  0.0  0.0  0.1";
      "visual_mark_next_page_fraction" = "0.5";
      "visual_mark_next_page_threshold" = "0.3";

      "search_url_g" = "https://www.google.com/search?q=";
      "search_url_d" = "https://www.duckduckgo.com/search?q=";
      "middle_click_search_engine" = "g";
      "shift_middle_click_search_engine" = "d";
    };
  };

};}
