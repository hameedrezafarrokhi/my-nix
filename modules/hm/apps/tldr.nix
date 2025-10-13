{ config, pkgs, lib, ... }:

{
config = lib.mkIf (config.my.apps.tldr.enable) {

 #services.tldr-update = {
 #  enable = true;
 #  package = pkgs.tldr;
 #  period = "weekly";
 #};

  programs.tealdeer = {
    enable = true;
    package = pkgs.tealdeer;
    enableAutoUpdates = true;
    settings = {
      display = {
        compact = true;
        use_pager = false;
      };
      updates = {
        auto_update = true;
        auto_update_interval_hours = 720;
      };
     #style = {
     #  foreground = "green";
     #  background = "red";
     #  underline = true;
     #  bold = true;
     #  italic = true;
     #};
     #directories = {
     # #cache_dir = "${config.home.homeDirectory}/.tealdeer-cache/";
     ##custom_pages_dir = "${config.home.homeDirectory}/custom-tldr-pages/";
     #};
    };
  };

};
}
