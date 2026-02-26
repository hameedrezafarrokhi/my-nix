{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.kde.ghostwriter.enable) {

  programs.ghostwriter = {
    enable = true;
    package = pkgs.kdePackages.ghostwriter;

   #locale = null;

   #window.sidebarOpen

   #general = {
   #  session = {
   #    rememberRecentFiles
   #    openLastFileOnStartup
   #  };
   #  fileSaving = {
   #    backupLocation
   #    backupFileOnSave
   #    autoSave
   #  };
   #  display = {
   #    showUnbreakableSpace
   #    showCurrentTimeInFullscreen
   #    interfaceStyle
   #    hideMenubarInFullscreen
   #  };
   #};

   #editor = {
   #  typing = {
   #    bulletPointCycling
   #    automaticallyMatchCharacters = {
   #      enable
   #      characters
   #    };
   #  };
   #  tabulation = {
   #    tabWidth
   #    insertSpacesForTabs
   #  };
   #  styling = {
   #    useLargeHeadings
   #    focusMode
   #    emphasisStyle
   #    editorWidth
   #    blockquoteStyle
   #  };
   #};

   #spelling = {
   #  skipRunTogether
   #  liveSpellCheck
   #  ignoredWords
   #  ignoreUppercase
   #  checkerEnabledByDefault
   #  autoDetectLanguage
   #};

   #preview = {
   #  openByDefault
   #  markdownVariant
   #  commandLineOptions
   #};

  };

};}
