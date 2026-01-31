{ config, lib, pkgs, mypkgs, ... }:

{ config = lib.mkIf (config.my.gaming.cli-games.enable) {

  environment.systemPackages = [

    pkgs.vitetris

    pkgs.gorched
    pkgs.curseofwar
    pkgs.pokete

    pkgs.raylib-games
    pkgs.tty-solitaire
    pkgs.solitaire-tui
    pkgs.solicurses
    pkgs.ninvaders
    pkgs.bastet
   #pkgs.pacman-game   # DARWIN Only
    pkgs.nsnake
    mypkgs.stable.greed
   #pkgs.bsdgames      # WARNING MESSES WITH INTERAVTIVE SHELL (Use With Comma)
    pkgs.moon-buggy
    pkgs.nudoku
    pkgs.nethack
    pkgs.n2048
    pkgs._2048-in-terminal
    pkgs.tcl2048

    (pkgs.writeShellScriptBin "ttetris" ''${config.my.default.terminal} --name tetris --class tetris sh -c 'tetris' '')
    (pkgs.writeShellScriptBin "tcbonsai" ''${config.my.default.terminal} --name cbonsai --class cbonsai sh -c 'cbonsai -li' '')
    (pkgs.writeShellScriptBin "tpipes-rs" ''${config.my.default.terminal} --name pipes-rs --class pipes-rs sh -c 'pipes-rs' '')

  ];

};}
