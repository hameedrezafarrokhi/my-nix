{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.tmux.enable) {

  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    shell = null; # "${pkgs.bash}/bin/bash";
    terminal = "screen";
    secureSocket = true;

   #plugins = { };
    tmuxp.enable = false;
    tmuxinator.enable = false;

    newSession = false;
    mouse = true;
   #prefix = null;
    shortcut = "b";
    resizeAmount = 5;
    reverseSplit = false;
    aggressiveResize = false;
    sensibleOnTop = false;
    escapeTime = 500;
    keyMode = "emacs"; # "vi";
    historyLimit = 2000;
    focusEvents = false;
    disableConfirmationPrompt = false;
    customPaneNavigationAndResize = false;
    clock24 = false;
    baseIndex = 0;

   #extraConfig = '' '';

  };

};}
