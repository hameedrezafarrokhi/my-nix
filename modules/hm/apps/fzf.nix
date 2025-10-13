{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.fzf.enable) {

  programs.fzf = {
    enable = true;
    package = pkgs.fzf;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
   #defaultCommand = "fd --type f";
   #defaultOptions = [ ];
   #fileWidgetCommand = "fd --type f";
   #fileWidgetOptions = [ ];
   #changeDirWidgetCommand = null;
   #changeDirWidgetOptions = [ ];
   #historyWidgetOptions = [ ];
   #colors = {
   #  bg = "#1e1e1e";
   #  "bg+" = "#1e1e1e";
   #  fg = "#d4d4d4";
   #  "fg+" = "#d4d4d4";
   #};
    tmux.enableShellIntegration = true;
   #tmux.shellIntegrationOptions = [ ];
  };

};}
