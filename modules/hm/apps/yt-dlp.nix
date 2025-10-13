{config, pkgs, lib, ... }:

{
config = lib.mkIf (config.my.apps.yt-dlp.enable) {

  programs.yt-dlp = {
    enable = true;
    package = pkgs.yt-dlp;
    settings = {
     #embed-thumbnail = true;
     #embed-subs = true;
     #sub-langs = "all";
     #downloader = "aria2c";
     #downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
    };
   #extraConfig = "";
  };

};
}
