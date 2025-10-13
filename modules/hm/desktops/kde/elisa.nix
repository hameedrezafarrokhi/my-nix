{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.kde.elisa.enable) {

  programs.elisa = {
    enable = true;
    package = pkgs.kdePackages.elisa;
    appearance = {
     #colorScheme = "Krita dark orange";   # not needed, default sets myStuff
      defaultFilesViewPath = "${config.home.homeDirectory}/Music";
      defaultView = "frequentlyPlayed"; #  “nowPlaying”, “recentlyPlayed”, “frequentlyPlayed”, “allAlbums”, “allArtists”, “allTracks”, “allGenres”, “files”, “radios”
     #embeddedView = null; # “albums”, “artists”, “genres”
      showNowPlayingBackground = true;
      showProgressOnTaskBar = true;
    };
    indexer = {
      paths = [
        "${config.home.homeDirectory}/Music"
        "${config.home.homeDirectory}/Downloads"
	  ];
      ratingsStyle = "favourites";  # “stars”, “favourites”
      scanAtStartup = true;
    };
    player = {
      minimiseToSystemTray = true;
      playAtStartup = false;
     #useAbsolutePlaylistPaths = true;
    };
  };

};
}
