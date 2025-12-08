{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.gaming.cli-games.enable) {

  environment.systemPackages = with pkgs; [

    vitetris

    gorched
    curseofwar
    pokete

    raylib-games
    tty-solitaire
    solitaire-tui
    solicurses
    ninvaders
    bastet
   #pacman-game   # DARWIN Only
    nsnake
    greed
   #bsdgames      # WARNING MESSES WITH INTERAVTIVE SHELL (Use With Comma)
    moon-buggy
    nudoku
    nethack
    n2048
    _2048-in-terminal
    tcl2048




  ];

};}
