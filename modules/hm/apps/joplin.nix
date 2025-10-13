{ config, pkgs, lib, ... }:

{
config = lib.mkIf (config.my.apps.joplin.enable) {

  programs.joplin-desktop = {
    enable = true;
    package = pkgs.joplin-desktop;
   #extraConfig = {  #example:
   #  "markdown.plugin.mark" = true;
   #  newNoteFocus = "title";
   #};
   #general.editor = kate;
    sync = {
      target = "undefined"; # one of "undefined", "none", "file-system", "onedrive", "nextcloud", "webdav", "dropbox", "s3", "joplin-server", "joplin-cloud"
      interval = "undefined"; # one of "undefined", "disabled", "5m", "10m", "30m", "1h", "12h", "1d"
    };
  };

};
}
