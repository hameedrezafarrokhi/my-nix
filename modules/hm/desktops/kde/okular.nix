{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.kde.okular.enable) {

  programs.okular = {
    enable = true;
    package = pkgs.kdePackages.okular;
    general = {
      mouseMode = null; # “Browse”, “Zoom”, “RectSelect”, “TextSelect”, “TableSelect”, “Magnifier”, “TrimSelect”
      obeyDrm = false;
      openFileInTabs = true;
      showScrollbars = true;
      smoothScrolling = true;
      viewContinuous = true;
      viewMode = null;  # “Single”, “Facing”, “FacingFirstCentered”, “Summary”
      zoomMode = null;  # “100%”, “fitWidth”, “fitPage”, “autoFit”
    };
    performance = {
      enableTransparencyEffects = true;
      memoryUsage = null; # “Low”, “Normal”, “Aggressive”, “Greedy”
    };
    accessibility = {
      highlightLinks = null;
      changeColors = {
        enable = false;
        blackWhiteContrast = null; # between 2 6
        blackWhiteThreshold = null; # between 2 253
        mode = null; # “Inverted”, “Paper”, “Recolor”, “BlackWhite”, “InvertLightness”, “InvertLumaSymmetric”, “InvertLuma”, “HueShiftPositive”, “HueShiftNegative”
        paperColor = null; # RGB Colors
        recolorBackground = null; # RGB Colors
        recolorForeground = null; # RGB Colors
      };
    };
  };

};
}
