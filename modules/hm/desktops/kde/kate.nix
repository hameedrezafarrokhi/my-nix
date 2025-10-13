{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.kde.kate.enable) {

  programs.kate = {
    enable = true;
    package = pkgs.kdePackages.kate;
    editor = {
      brackets = {
        automaticallyAddClosing = false;
        characters = "<>(){}[]'\"`";
        flashMatching = true;
        highlightMatching = true;
        highlightRangeBetween = true;
      };
      indent = {
        autodetect = true;
        backspaceDecreaseIndent = true;
        keepExtraSpaces = false;
        replaceWithSpaces = false;
        showLines = true;
        tabFromEverywhere = false;
        undoByShiftTab = true;
        width = 4;
      };
      inputMode = "normal";  # “normal”, “vi”
      tabWidth = 6;
     #lsp.customServers = null;
    };
  };

};
}
