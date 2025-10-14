{ config, lib, pkgs, admin, ... }:

{ config = lib.mkIf (config.my.software.programs.enable) {

  programs = {

    light = {
      enable = true;
      brightnessKeys = {
        enable = true;
        minBrightness = 0.1;
        step = 2;
      };
    };

    gnupg = {
      package = pkgs.gnupg;
      dirmngr.enable = true;
     #settings = { };
      agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-qt;
        enableExtraSocket = true;
        enableBrowserSocket = true;
        enableSSHSupport = true;
      };
    };

    seahorse.enable = true;
    gnome-disks.enable = true;

    adb.enable = true;
    kdeconnect = {
      enable = true;
      package = lib.mkForce pkgs.kdePackages.kdeconnect-kde;
    };
    droidcam.enable = true;

    firefox = {
      enable = true;
      package = pkgs.firefox;
      languagePacks = [ "en-US" "fa" ];
      nativeMessagingHosts = {
        packages = [ pkgs.uget-integrator pkgs.ff2mpv ];
       #ugetIntegrator = true;
       #tridactyl = true;
       #passff = true;
       #jabref = true;
       #gsconnect = true;
       #fxCast = true;
       #euwebid = true;
       #bukubrow = true;
       #browserpass = true;
       #ff2mpv = true;
      };
     #autoConfig = ""
     #autoConfigFiles = [ ];
     #preferencesStatus = "locked"; # one of "default", "locked", "user", "clear"
     #preferences = {
     #  "browser.tabs.tabmanager.enabled" = false;
     #};
     #policies = { };


    };
    chromium = {
      enable = true;
      enablePlasmaBrowserIntegration = true;
      plasmaBrowserIntegrationPackage = lib.mkForce pkgs.kdePackages.plasma-browser-integration;
    };
   #ladybird.enable = true;

   #evolution = {
   #  enable = true;
   # #plugin = [ pkgs.evolution-ews ];
   #};

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
    yazi = {
      enable = true;
      package = pkgs.yazi;
      plugins = { inherit (pkgs.yaziPlugins.starship); };
     #initLua = ./  .lua;
     #flavors = {};
     #settings = {
     #  yazi = {};
     #  keymap = {};
     #  theme = {};
     #};
    };

    java = {      #For Minecraft
      enable = true;
      binfmt = true;
     #package = pkgs.jdk;
    };

   #openvpn3 = {
   #  enable = true;
   #  package= pkgs.openvpn3;
   #};
   #amnezia-vpn = {
   #  enable = true;
   #  package = pkgs.amnezia-vpn;
   #};
   #appgate-sdp.enable = true;
   #haguichi.enable = true;

    mtr = {
      enable = true;
      package = pkgs.mtr-gui;
    };

    usbtop.enable = true; #btop for usb and bus bandwidth
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
      usbmon.enable = true;
      dumpcap.enable = true;
    };

    nautilus-open-any-terminal = {
      enable = true;
      terminal = config.my.default.terminal;
    };
    file-roller = {
      enable = true;
      package = pkgs.file-roller;
    };

    obs-studio = {
      enable = true;
      package = config.home-manager.users.${admin}.programs.obs-studio.package;
      plugins = config.home-manager.users.${admin}.programs.obs-studio.plugins;
      enableVirtualCamera = true;
    };

    vim = {
      enable = true;
      package = pkgs.vim-full;
      defaultEditor = false;
    };
    neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      withNodeJs = false;
      withPython3 = true;
      withRuby = true;
      defaultEditor = true;
     #configure = { };
      viAlias = false;
      vimAlias = false;
     #runtime = { };
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

    htop = {
      enable = true;
      package = pkgs.htop;
     #settings = {};
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

    gpu-screen-recorder = {
      enable = true;
      package = pkgs.gpu-screen-recorder;
    };

    evince.enable = true;

    kde-pim = {
      enable = false;
      kmail = true;
      kontact = true;
      merkuro = true;
    };
    partition-manager = {
      enable = true;
      package = lib.mkForce pkgs.kdePackages.partitionmanager;
    };

  };

};}
