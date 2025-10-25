{ config, lib, pkgs, utils, admin, ... }:

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

    fd

    eza
    lsd

  ] ) config.my.software.basic-cli.exclude)

   ++

  config.my.software.basic-cli.include;

  programs = {

    bat = {
      enable = true;
      package = pkgs.bat;
      extraPackages = with pkgs.bat-extras; [
        core batdiff batman
        batwatch batpipe batgrep
       #prettybat
      ];
     #settings = {
     #  italic-text = "always";
     #  map-syntax = [
     #    "*.ino:C++"
     #    ".ignore:Git Ignore"
     #  ];
     #  pager = "less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse";
     #  paging = "never";
     #  theme = "TwoDark";
     #};
    };

    zoxide = {
      enable = true;
      package = pkgs.zoxide;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
     #flags = [
     #  "--no-cmd"
     #  "--cmd j"
     #];
    };

    fzf = {
      fuzzyCompletion = true;
      keybindings = true;
    };

    starship = {
      enable = true;
      package = pkgs.starship;
      interactiveOnly = true;
     #transientPrompt = {
     #  enable = true;
     #  left = ''echo ;
     #  starship module custom.character5; starship module directory; starship module custom.character4'';
     #  right = ''starship module custom.character3; starship module time; starship module custom.character2'';
     #};
      settings = config.home-manager.users.${admin}.programs.starship.settings;
     #presets = [ "nerd-font-symbols" ];
    };

    television = {
      enable = true;
      package = pkgs.television;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    pay-respects = {
      enable = false;
      package = pkgs.pay-respects;
      alias = "fuck";
     #aiIntegration = {  # example
     #  locale = "nl-be";
     #  model = "llama3";
     #  url = "http://127.0.0.1:11434/v1/chat/completions";
     #};
      runtimeRules = [
        {
          command = "xl";
          match_err = [
            {
              pattern = [
                "Permission denied"
              ];
              suggest = [
                ''
                  #[executable(sudo), !cmd_contains(sudo), err_contains(libxl: error:)]
                  sudo {{command}}
                ''
              ];
            }
          ];
        }

      ];
    };

  };

};}
