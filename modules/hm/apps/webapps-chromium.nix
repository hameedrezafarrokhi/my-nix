{ config, pkgs, lib, ... }:

let

  # AI
  gepiti = pkgs.writeShellScriptBin "GPT" ''
    ${lib.getExe config.my.default.browser-package} --app=https://chatgpt.com/
  '';
  grok = pkgs.writeShellScriptBin "grok" ''
    ${lib.getExe config.my.default.browser-package} --app=https://grok.com/
  '';
  deepseek = pkgs.writeShellScriptBin "deepseek" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.deepseek.com/en
  '';
  claude-code = pkgs.writeShellScriptBin "claude-code" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.anthropic.com/
  '';


  # Nix
  nix-packages = pkgs.writeShellScriptBin "nix-packages" ''
    ${lib.getExe config.my.default.browser-package} --app=https://search.nixos.org/packages?channel=unstable&
  '';
  nix-options = pkgs.writeShellScriptBin "nix-options" ''
    ${lib.getExe config.my.default.browser-package} --app=https://search.nixos.org/options?channel=unstable&
  '';
  nix-status = pkgs.writeShellScriptBin "nix-status" ''
    ${lib.getExe config.my.default.browser-package} --app=https://status.nixos.org/
  '';
  nix-hydra = pkgs.writeShellScriptBin "nix-hydra" ''
    ${lib.getExe config.my.default.browser-package} --app=https://hydra.nixos.org/jobset/nixos/trunk-combined
  '';
  nix-wiki = pkgs.writeShellScriptBin "nix-wiki" ''
    ${lib.getExe config.my.default.browser-package} --app=https://wiki.nixos.org/wiki/NixOS_Wiki
  '';
  nix-github = pkgs.writeShellScriptBin "nix-github" ''
    ${lib.getExe config.my.default.browser-package} --app=https://github.com/NixOS/nixpkgs
  '';
  arch-wiki = pkgs.writeShellScriptBin "arch-wiki" ''
    ${lib.getExe config.my.default.browser-package} --app=https://wiki.archlinux.org/title/Main_page
  '';
  repology = pkgs.writeShellScriptBin "repology" ''
    ${lib.getExe config.my.default.browser-package} --app=https://repology.org/projects/?search=
  '';


  # Email
  gmail = pkgs.writeShellScriptBin "Gmail" ''
    ${lib.getExe config.my.default.browser-package} --app=https://mail.google.com/
  '';
  yahoo-mail = pkgs.writeShellScriptBin "yahoo-mail" ''
    ${lib.getExe config.my.default.browser-package} --app=https://mail.yahoo.com/
  '';
  proton-mail = pkgs.writeShellScriptBin "Proton-mail" ''
    ${lib.getExe config.my.default.browser-package} --app=https://proton.me/mail
  '';


  # Search
  google = pkgs.writeShellScriptBin "google" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.google.com
  '';
  duckduckgo = pkgs.writeShellScriptBin "ddgo" ''
    ${lib.getExe config.my.default.browser-package} --app=https://duckduckgo.com/
  '';
  brave-search = pkgs.writeShellScriptBin "brave-search" ''
    ${lib.getExe config.my.default.browser-package} --app=https://search.brave.com/
  '';
  bing-search = pkgs.writeShellScriptBin "bing-search" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.bing.com/
  '';
  yahoo = pkgs.writeShellScriptBin "yahoo" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.yahoo.com/
  '';
  wikipedia = pkgs.writeShellScriptBin "wikipedia" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.wikipedia.org/
  '';
  google-images = pkgs.writeShellScriptBin "google-images" ''
    ${lib.getExe config.my.default.browser-package} --app=https://images.google.com/
  '';
  imdb = pkgs.writeShellScriptBin "imdb" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.imdb.com/
  '';


  # Video
  youtube = pkgs.writeShellScriptBin "YouTube" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.youtube.com/
  '';
  twitch = pkgs.writeShellScriptBin "TwitchTV" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.twitch.tv/
  '';
  iran-tv = pkgs.writeShellScriptBin "iran-tv" ''
    ${lib.getExe config.my.default.browser-package} --app=https://telewebion.com/channels
  '';


  # Audio
  spotify = pkgs.writeShellScriptBin "Spotify-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.spotify.com/
  '';
  pandora = pkgs.writeShellScriptBin "Pandora-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.pandora.com/
  '';
  soundcloud = pkgs.writeShellScriptBin "SoundCloud-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://soundcloud.com/
  '';
  youtube-music = pkgs.writeShellScriptBin "ytMusic-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://music.youtube.com/
  '';
  radio-online = pkgs.writeShellScriptBin "iHeart-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.iheart.com/podcast/
  '';


  # Social
  whatsapp-web = pkgs.writeShellScriptBin "Whatsapp-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://web.whatsapp.com/
  '';
  instagram-web = pkgs.writeShellScriptBin "Instagram-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.instagram.com/
  '';
  facebook = pkgs.writeShellScriptBin "Facebook-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.facebook.com/
  '';
  twitter-x = pkgs.writeShellScriptBin "X-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://x.com/
  '';
  zoom-web = pkgs.writeShellScriptBin "Zoom-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.zoom.com/
  '';
  discord-web = pkgs.writeShellScriptBin "Discord-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://discord.com/
  '';
  reddit-web = pkgs.writeShellScriptBin "Reddit-Web" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.reddit.com/
  '';


  # Game
  online-games = pkgs.writeShellScriptBin "Online-Games" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.crazygames.com/
  '';
  play-ps2 = pkgs.writeShellScriptBin "Play-PS2" ''
    ${lib.getExe config.my.default.browser-package} --app=https://purei.org/
  '';
  epic-games = pkgs.writeShellScriptBin "Epic-Gmaes" ''
    ${lib.getExe config.my.default.browser-package} --app=https://store.epicgames.com/en-US
  '';
  google-games = pkgs.writeShellScriptBin "Google-Games" ''
    ${lib.getExe config.my.default.browser-package} --app=https://sites.google.com/site/populardoodlegames/home
  '';
  roblox = pkgs.writeShellScriptBin "Roblox" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.roblox.com/
  '';
  yahoo-games = pkgs.writeShellScriptBin "Yahoo-Games" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.yahoo.com/games/
  '';


  # Medical
  up-to-date = pkgs.writeShellScriptBin "up-to-date" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.uptodate.com/
  '';
  medscape = pkgs.writeShellScriptBin "medscape" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.medscape.com/
  '';
 #harrison = pkgs.writeShellScriptBin "google" ''
 #  ${lib.getExe config.my.default.browser-package} --app=https://www.google.com
 #'';


  # Cloud
  google-photos = pkgs.writeShellScriptBin "google-photos" ''
    ${lib.getExe config.my.default.browser-package} --app=https://photos.google.com/
  '';
  dropbpx = pkgs.writeShellScriptBin "Dropbox" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.dropbox.com/
  '';
  borg-base = pkgs.writeShellScriptBin "BorgBase" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.borgbase.com/repositories
  '';


  # Productivity
  photoshop = pkgs.writeShellScriptBin "PhotoShop" ''
    ${lib.getExe config.my.default.browser-package} --app=https://photoshop.adobe.com/
  '';
  office365 = pkgs.writeShellScriptBin "office365" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.office.com/
  '';
  boxySVG = pkgs.writeShellScriptBin "BoxySVG" ''
    ${lib.getExe config.my.default.browser-package} --app=https://boxy-svg.com/app
  '';


  # World
  google-maps = pkgs.writeShellScriptBin "google-maps" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.google.com/maps
  '';
  google-earth = pkgs.writeShellScriptBin "google-earth" ''
    ${lib.getExe config.my.default.browser-package} --app=https://earth.google.com/web/
  '';
  weather-online = pkgs.writeShellScriptBin "weather-online" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.accuweather.com/en/ir/tehran/210841/weather-forecast/210841
  '';
  time-ir = pkgs.writeShellScriptBin "time-ir" ''
    ${lib.getExe config.my.default.browser-package} --app=https://www.time.ir/
  '';


  # Bills
  irancell = pkgs.writeShellScriptBin "irancell" ''
    ${lib.getExe config.my.default.browser-package} --app=https://my.irancell.ir/
  '';
  hamrah = pkgs.writeShellScriptBin "hamrah" ''
    ${lib.getExe config.my.default.browser-package} --app=https://my.mci.ir/
  '';


in

{ config = lib.mkIf (

      config.my.apps.webapps.enable &&
      lib.elem config.my.default.browser-alt-name [

        "brave"
        "ungoogled-chromium"
        "chromium"
        "google-chrome"
        "vivaldi"
        "microsoft-edge"
        "qutebrowser"
        "qutebrowser-qt5"
        "kdePackages.falkon"

      ]
  ) {

  xdg.desktopEntries = {

    "google-seacrh"  = { name="Google"         ;exec="google"        ; };
    "duckduckgo"     = { name="duckduckgo"     ;exec="ddgo"          ; };
    "brave-search"   = { name="brave-search"   ;exec="brave-search"  ; };
    "yahoo"          = { name="yahoo"          ;exec="bing-search"   ; };
    "bing-search"    = { name="bing-search"    ;exec="yahoo"         ; };
    "wikipedia"      = { name="wikipedia"      ;exec="wikipedia"     ; };
    "google-images"  = { name="google-images"  ;exec="google-images" ; };
    "imdb"           = { name="imdb"           ;exec="imdb"          ; };

    "gepiti"         = { name="gepiti"         ;exec="GPT"           ; };
    "grok"           = { name="grok"           ;exec="grok"          ; };
    "deepseek"       = { name="deepseek"       ;exec="deepseek"      ; };
    "claude-code"    = { name="claude-code"    ;exec="claude-code"   ; };

    "nix-packages"   = { name="nix-packages"   ;exec="nix-packages"  ; };
    "nix-options"    = { name="nix-options"    ;exec="nix-options"   ; };
    "nix-status"     = { name="nix-status"     ;exec="nix-status"    ; };
    "nix-hydra"      = { name="nix-hydra"      ;exec="nix-hydra"     ; };
    "nix-wiki"       = { name="nix-wiki"       ;exec="nix-wiki"      ; };
    "nix-github"     = { name="nix-github"     ;exec="nix-github"    ; };

    "arch-wiki"      = { name="arch-wiki"      ;exec="arch-wiki"     ; };
    "repology"       = { name="repology"       ;exec="repology"      ; };

    "gmail"          = { name="gmail"          ;exec="Gmail"         ; };
    "yahoo-mail"     = { name="yahoo-mail"     ;exec="yahoo-mail"    ; };
    "proton-mail"    = { name="proton-mail"    ;exec="Proton-mail"   ; };

    "youtube"        = { name="youtube"        ;exec="YouTube"       ; };
    "twitch"         = { name="twitch"         ;exec="TwitchTV"      ; };
    "iran-tv"        = { name="iran-tv"        ;exec="iran-tv"       ; };

    "spotify"        = { name="spotify"        ;exec="Spotify-Web"   ; };
    "pandora"        = { name="pandora"        ;exec="Pandora-Web"   ; };
    "soundcloud"     = { name="soundcloud"     ;exec="SoundCloud-Web"; };
    "youtube-music"  = { name="youtube-music"  ;exec="ytMusic-Web"   ; };
    "radio-online"   = { name="radio-online"   ;exec="iHeart-Web"    ; };

    "whatsapp-web"   = { name="whatsapp-web"   ;exec="Whatsapp-Web"  ; };
    "instagram-web"  = { name="instagram-web"  ;exec="Instagram-Web" ; };
    "facebook"       = { name="facebook"       ;exec="Facebook-Web"  ; };
    "twitter-x"      = { name="twitter-x"      ;exec="X-Web"         ; };
    "zoom-web"       = { name="zoom-web"       ;exec="Zoom-Web"      ; };
    "discord-web"    = { name="discord-web"    ;exec="Discord-Web"   ; };
    "reddit-web"     = { name="reddit-web"     ;exec="Reddit-Web"    ; };

    "online-games"   = { name="online-games"   ;exec="Online-Games"  ; };
    "play-ps2"       = { name="play-ps2"       ;exec="Play-PS2"      ; };
    "epic-games"     = { name="epic-games"     ;exec="Epic-Gmaes"    ; };
    "google-games"   = { name="google-games"   ;exec="Google-Games"  ; };
    "roblox"         = { name="roblox"         ;exec="Roblox"        ; };
    "yahoo-games"    = { name="yahoo-games"    ;exec="Yahoo-Games"   ; };

    "up-to-date"     = { name="up-to-date"     ;exec="up-to-date"    ; };
    "medscape"       = { name="medscape"       ;exec="medscape"      ; };

    "google-photos"  = { name="google-photos"  ;exec="google-photos" ; };
    "dropbpx"        = { name="dropbpx"        ;exec="Dropbox"       ; };
    "borg-base"      = { name="borg-base"      ;exec="BorgBase"      ; };

    "photoshop"      = { name="photoshop"      ;exec="PhotoShop"     ; };
    "office365"      = { name="office365"      ;exec="office365"     ; };
    "boxySVG"        = { name="boxySVG"        ;exec="BoxySVG"       ; };

    "google-maps"    = { name="google-maps"    ;exec="google-maps"   ; };
    "google-earth"   = { name="google-earth"   ;exec="google-earth"  ; };
    "weather-online" = { name="weather-online" ;exec="weather-online"; };
    "time-ir"        = { name="time-ir"        ;exec="time-ir"       ; };

    "irancell"       = { name="irancell"       ;exec="irancell"      ; };
    "hamrah"         = { name="hamrah"         ;exec="hamrah"        ; };

  };

  home.packages = [

    google                 # "google"
    duckduckgo             # "ddgo"
    brave-search           # "brave-search"
    yahoo                  # "bing-search"
    bing-search            # "yahoo"
    wikipedia              # "wikipedia"
    google-images          # "google-images"
    imdb                   # "imdb"

    gepiti                 # "GPT"
    grok                   # "grok"
    deepseek               # "deepseek"
    claude-code            # "claude-code"

    nix-packages           # "nix-packages"
    nix-options            # "nix-options"
    nix-status             # "nix-status"
    nix-hydra              # "nix-hydra"
    nix-wiki               # "nix-wiki"
    nix-github             # "nix-github"

    arch-wiki              # "arch-wiki"
    repology               # "repology"
                           #
    gmail                  # "Gmail"
    yahoo-mail             # "yahoo-mail"
    proton-mail            # "Proton-mail"

    youtube                # "YouTube"
    twitch                 # "TwitchTV"
    iran-tv                # "iran-tv"

    spotify                # "Spotify-Web"
    pandora                # "Pandora-Web"
    soundcloud             # "SoundCloud-Web"
    youtube-music          # "ytMusic-Web"
    radio-online           # "iHeart-Web"

    whatsapp-web           # "Whatsapp-Web"
    instagram-web          # "Instagram-Web"
    facebook               # "Facebook-Web"
    twitter-x              # "X-Web"
    zoom-web               # "Zoom-Web"
    discord-web            # "Discord-Web"
    reddit-web             # "Reddit-Web"

    online-games           # "Online-Games"
    play-ps2               # "Play-PS2"
    epic-games             # "Epic-Gmaes"
    google-games           # "Google-Games"
    roblox                 # "Roblox"
    yahoo-games            # "Yahoo-Games"

    up-to-date             # "up-to-date"
    medscape               # "medscape"

    google-photos          # "google-photos"
    dropbpx                # "Dropbox"
    borg-base              # "BorgBase"

    photoshop              # "PhotoShop"
    office365              # "office365"
    boxySVG                # "BoxySVG"

    google-maps            # "google-maps"
    google-earth           # "google-earth"
    weather-online         # "weather-online"
    time-ir                # "time-ir"

    irancell               # "irancell"
    hamrah                 # "hamrah"

  ];


};}
