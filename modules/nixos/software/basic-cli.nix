{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.basic-cli.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

   #vim                           ##Text editor
   #neovim                        ##Text editor

   #starship                      ##Beautiful bash
   #fzf                           ##Auto complete
   #zoxide                        ##Auto complete
   #bash-completion               ##Auto complete
    tree                          ##ls stuff
    multitail                     ##ls stuff
    tldr                          ##Too long, didnt read!
    jq

    wget
   #python3Full                           # lots of overrides
   #pipx
   #curl
    gcc
    git
   #sparkleshare                  ##Git GUI
    gnumake
    gnutar
    gnugrep
    clapgrep                      ##Grep Gui
    ripgrep
   #bat
   #ninja

    trashy
    net-tools
    iproute2

    cmatrix                       ##Screeansaver fot cli
   #htop                          ##System monitor cli
   #btop

    fd

    eza
    lsd

  ] ) config.my.software.basic-cli.exclude)

   ++

  config.my.software.basic-cli.include;

};}
