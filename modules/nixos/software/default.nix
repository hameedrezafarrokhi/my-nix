{ config, pkgs, lib, ... }:

let

  cfg = config.my.software;

in

{

  options.my.software = {

    ai = {
      enable = lib.mkEnableOption "ai softwares";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    audio-control = {
      enable = lib.mkEnableOption "audio control panels and sound effects";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    basic-cli = {
      enable = lib.mkEnableOption "basic cli tui tty stuff ...";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    codecs = {
      enable = lib.mkEnableOption "various codecs";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    daw = {
      enable = lib.mkEnableOption "daw audio-editors audio-recorders music-prouction guitar-stuff ...";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    disk-utils = {
      enable = lib.mkEnableOption "disk utility softwares";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    docs = {
      enable = lib.mkEnableOption "office pdf text notes docs ...";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    fetch = {
      enable = lib.mkEnableOption "various fetch scripts ...";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    files = {
      enable = lib.mkEnableOption "file-managers archive search share metadata ...";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    hardware-monitor = {
      enable = lib.mkEnableOption "hardware info monitoring ...";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    internet = {
      enable = lib.mkEnableOption "browsers mail youtube rss wiki download torrent ...";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    multimedia = {
      enable = lib.mkEnableOption "video-music players photo viewer ...";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    peripherals = {
      enable = lib.mkEnableOption "hardware peripherals software";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    productivity = {
      enable = lib.mkEnableOption "audio video picture text, productivity ...";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    social = {
      enable = lib.mkEnableOption "social media softwares";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    terminals = {
      enable = lib.mkEnableOption "terminal emulators ...";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    theming = {
      enable = lib.mkEnableOption "theming softwares and themes";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    tools = {
      enable = lib.mkEnableOption "general tools that i was too lazy to catagorize";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    wallpaper = {
      enable = lib.mkEnableOption "wallpaper softwares";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };
    wine = {
      enable = lib.mkEnableOption "wine stuff";
      exclude = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
      include = lib.mkOption { default = [ ]; type = lib.types.listOf lib.types.package; };
    };

  };

  imports = [

    ./ai.nix
    ./audio-control.nix
    ./basic-cli.nix
    ./codecs.nix
    ./daw.nix
    ./disk-utils.nix
    ./docs.nix
    ./fetch.nix
    ./files.nix
    ./hardware-monitor.nix
    ./internet.nix
    ./multimedia.nix
    ./peripherals.nix
    ./productivity.nix
    ./social.nix
    ./terminals.nix
    ./theming.nix
    ./tools.nix
    ./wallpaper.nix
    ./wine.nix

  ];

}
