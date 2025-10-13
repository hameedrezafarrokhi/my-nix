{ config, pkgs, lib, ... }:

let

  cfg = config.my.software;

in

{

  options.my.software = {

    programs.enable = lib.mkEnableOption "options from programs";
    services.enable = lib.mkEnableOption "options from services";

    connectivity.enable = lib.mkEnableOption "connectivity tools";
    codecs.enable = lib.mkEnableOption "various codecs";
    internet.enable = lib.mkEnableOption "browsers mail youtube rss wiki download torrent ...";
    multimedia.enable = lib.mkEnableOption "video-music players photo viewer ...";
    wallpaper.enable = lib.mkEnableOption "wallpaper softwares";
    disk-utils.enable = lib.mkEnableOption "disk utility softwares";
    files.enable = lib.mkEnableOption "file-managers archive search share metadata ...";
    docs.enable = lib.mkEnableOption "office pdf text notes docs ...";
    tools.enable = lib.mkEnableOption "general tools that i was too lazy to catagorize";
    audio-control.enable = lib.mkEnableOption "audio control panels and sound effects";
    daw.enable = lib.mkEnableOption "daw audio-editors audio-recorders music-prouction guitar-stuff ...";
    productivity.enable = lib.mkEnableOption "audio video picture text, productivity ...";
    fetch.enable = lib.mkEnableOption "various fetch scripts ...";
    basic-cli.enable = lib.mkEnableOption "basic cli tui tty stuff ...";
    terminals.enable = lib.mkEnableOption "terminal emulators ...";
    wine.enable = lib.mkEnableOption "wine stuff";
    hardware-monitor.enable = lib.mkEnableOption "hardware info monitoring ...";
    peripherals.enable = lib.mkEnableOption "hardware peripherals software";
    social.enable = lib.mkEnableOption "social media softwares";
    ai.enable = lib.mkEnableOption "ai softwares";
    theming.enable = lib.mkEnableOption "theming softwares and themes";

  };

  imports = [

    ./services.nix
    ./programs.nix

    ./connectivity.nix
    ./codecs.nix
    ./internet.nix
    ./multimedia.nix
    ./wallpaper.nix
    ./disk-utils.nix
    ./files.nix
    ./docs.nix
    ./tools.nix
    ./audio-control.nix
    ./productivity.nix
    ./fetch.nix
    ./basic-cli.nix
    ./terminals.nix
    ./wine.nix
    ./hardware-monitor.nix
    ./peripherals.nix
    ./social.nix
    ./ai.nix
    ./theming.nix
    ./daw.nix

  ];

}
