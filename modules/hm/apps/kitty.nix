{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.apps.kitty.enable) {

  programs.kitty = {
    enable = true;

    shellIntegration = {
      mode = "no-cursor";
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    enableGitIntegration = lib.mkIf (config.my.default.terminal == "kitty") true;

   #environment = ;
   #extraConfig = ;

    font = {
      name = lib.mkDefault "Hack Nerd Font Mono";
      #OpenDyslexicM Nerd Font Mono
     #package = lib.mkDefault pkgs.nerd-fonts.open-dyslexic;
      size = lib.mkDefault 10;
    };

    keybindings = {
     #"ctrl+c" = "copy_or_interrupt";
      "shift+super+v" = "paste_from_buffer a1";
    };

    settings = {
      remember_window_size = false;
      initial_window_width = "122c";
      initial_window_height = "30c";
      window_margin_width = 12;
      tab_bar_edge = "bottom";
      tab_bar_margin_width = 10;
      tab_bar_margin_height = "10 10";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      tab_bar_min_tabs = 1;
      tab_activity_symbol = "none";
      background_opacity = lib.mkDefault 1;
      dynamic_background_opacity = "yes";
      background_blur = "0";

      cursor_trail = 3;
      cursor_trail_decay = "0.1 0.4";

      copy_on_select = "a1";
    };
  };

};
}
