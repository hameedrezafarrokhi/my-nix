{ config, pkgs, lib, inputs, nix-path, ... }:

  let

    scheme ="dark";
    global-package = myGlobalCatppuccin;
    wallpaper = "${config.home.homeDirectory}/Pictures/Wallpapers/astronaut-macchiato.png";
    wallpaper-alt = "file:///home/${config.home.username}/Pictures/Wallpapers/astronaut-macchiato.png";

    gtk-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}-standard";
    gtk-decoration = ":minimize,maximize,close";
    gtk-package = myGTKCatppuccin;
    gtk2-package = myGTKCatppuccin;
    gtk-icon = "Papirus-Dark";
    gtk-icon-package = myIconCatppuccin;

    gtk-cursor = "catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}-cursors";
    gtk-cursor-package = myCursorCatppuccin;
    x-cursor = "catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}-cursors";
    x-cursor-package = myCursorCatppuccin;
    plasma-cursor = "catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}-cursors";
    plasma-cursor-package = myCursorCatppuccin;
    hypr-cursor = "catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}-cursors";
    hypr-cursor-package = myCursorCatppuccin;
    cursor-size = 24;

    qt-platform = "kvantum"; # "qt6ct"; (breaks plasma) # "kde"; (WORKS, but breaks qt) # "qtct"; (its qt5ct, breaks plasma) # "kvantum";
    qt-name = "Kvantum";
    qt-package = pkgs.kdePackages.qtstyleplugin-kvantum;
    qt-icon = "Papirus-Dark";
    qt-icon-package = myIconCatppuccin;
    kvantum-package = myKvantumCatppuccin;
    kvantum-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}";
    plasma-package = myKDECatppuccin;
    plasma-look = "Catppuccin-${myStuff.myCat.myGlobal-FlavC}-${myStuff.myCat.myGlobal-ColorC}";
    plasma-theme = "default";
    plasma-widget = "Catppuccin-${myStuff.myCat.myGlobal-FlavC}-${myStuff.myCat.myGlobal-ColorC}";
    plasma-color = "Catppuccin${myStuff.myCat.myGlobal-FlavC}${myStuff.myCat.myGlobal-ColorC}";
    plasma-splash = "Catppuccin-${myStuff.myCat.myGlobal-FlavC}-${myStuff.myCat.myGlobal-ColorC}";
    plasma-decoration-name = "__aurorae__svg__Catppuccin${myStuff.myCat.myGlobal-FlavC}-Classic";
    plasma-decoration-platform = "org.kde.kwin.aurorae";
    plasma-decoration-right = [ "minimize" "maximize" "close" ];
    plasma-decoration-left = [ "application-menu" "on-all-desktops" "keep-above-windows" ];

    cinnamon-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}-standard";
    cinnamon-package = myGTKCatppuccin;
    mate-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}-standard";
    mate-package = myGTKCatppuccin;
    xfce-theme = "Prune";
    xfce-package = myGTKCatppuccin;

    openbox-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}";

    i3status-theme = "ctp-${myStuff.myCat.myGlobal-Flav}";
    i3status-icon = "material-nf";
    i3BarPos = "top";
    i3BarMode = "dock";

   #konsole-scheme = ./Konsole-catppuccin-macchiato.colorscheme;
    konsole-theme = "Konsole-catppuccin-${myStuff.myCat.myGlobal-Flav}";
    kate-theme = "Catppuccin ${myStuff.myCat.myGlobal-FlavC}";
    kate-ui = "Catppuccin ${myStuff.myCat.myGlobal-FlavC} ${myStuff.myCat.myGlobal-ColorC}";
    kwrite-theme = "Catppuccin ${myStuff.myCat.myGlobal-FlavC}";
    kwrite-color = "Catppuccin ${myStuff.myCat.myGlobal-FlavC} ${myStuff.myCat.myGlobal-ColorC}";
    marknote-theme = "Catppuccin ${myStuff.myCat.myGlobal-FlavC} ${myStuff.myCat.myGlobal-ColorC}";
    okular-theme = "Catppuccin ${myStuff.myCat.myGlobal-FlavC} ${myStuff.myCat.myGlobal-ColorC}";
    dolphin-theme = "Catppuccin ${myStuff.myCat.myGlobal-FlavC} ${myStuff.myCat.myGlobal-ColorC}";
    alacritty-theme = "catppuccin_${myStuff.myCat.myGlobal-Flav}";
    ghostty-theme = "light:catppuccin-${myStuff.myCat.myGlobal-Flav},dark:catppuccin-${myStuff.myCat.myGlobal-Flav}";
    ghostty-theme-name = "catppuccin-${myStuff.myCat.myGlobal-Flav}";

    freetube-base = "catppuccinMocha";
    freetube-main = "CatppuccinMochaSapphire";
    freetube-sec = "CatppuccinMochaBlue";

    superfile-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}";

    fish-theme = "Catppuccin ${myStuff.myCat.myGlobal-FlavC}";

    tv-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}";
    tv-preview = "TwoDark";

    bat-theme = "Catppuccin ${myStuff.myCat.myGlobal-FlavC}";
    bat-source = pkgs.fetchurl {
      url = "https://github.com/catppuccin/bat/blob/main/themes/Catppuccin%20${myStuff.myCat.myGlobal-FlavC}.tmTheme";
      sha256 = "sha256-8BKmij32yf+/3N92pKTLpDSOAz1yWd1I/+pNQ4ewu0c=";
    };
    yazi-bat = "catppuccin-macchiato-yazi";

    btop-theme = "catppuccin_${myStuff.myCat.myGlobal-Flav}";

    cava-theme = "catppuccin_${myStuff.myCat.myGlobal-Flav}";

    dunst-theme = "catppuccin_${myStuff.myCat.myGlobal-Flav}";

    catppuccinifier-flav = "${myStuff.myCat.myGlobal-Flav}";
    catppuccinifier-flavC = "${myStuff.myCat.myGlobal-FlavC}";
    catppuccinifier-acc = "${myStuff.myCat.myGlobal-Color}";
    catppuccinifier-accC = "${myStuff.myCat.myGlobal-ColorC}";

    onboard-theme = "${pkgs.onboard}/share/onboard/themes/ModelM.theme";
    onboard-color = "${pkgs.onboard}/share/onboard/themes/Granite.colors";
    onboard-layout = "${pkgs.onboard}/share/onboard/layouts/Full Keyboard.onboard";
    onboard-key = "dish";

    nvim-package = pkgs.vimPlugins.catppuccin-nvim;
    nvim-theme = "catppuccin-nvim";
    nvim-config = ''
      lua << EOF
        local compile_path = vim.fn.stdpath("cache") .. "/catppuccin-nvim"
        vim.fn.mkdir(compile_path, "p")
        vim.opt.runtimepath:append(compile_path)

        require("catppuccin").setup({
        ["compile_path"] = (compile_path),
        ["flavour"] = "${myStuff.myCat.myGlobal-Flav}"
      })

        vim.api.nvim_command("colorscheme catppuccin")
      EOF
    '';

    xfce4-terminal-theme = "Catppuccin-${myStuff.myCat.myGlobal-FlavC}";

   #obs-theme = "Catppuccin";
   #obs-theme-name = "Catppuccin_${myStuff.myCat.myGlobal-FlavC}";
   #obs-obt-source = pkgs.fetchurl {
   #  url = "https://github.com/catppuccin/obs/blob/main/themes/Catppuccin.obt";
   #  sha256 = "sha256-80pWKD8b6oKn99pTAbjf+zjplr8zMlQRiziNcggVdfk=";
   #};
   #obs-ovt-source = pkgs.fetchurl {
   #  url = "https://github.com/catppuccin/obs/blob/main/themes/${obs-theme-name}.ovt";
   #  sha256 = "sha256-xkhyYB/u6qvwycrVizFKkKAshuEMetSjN5lNQO+Q2UU=";
   #};


    MonoSpace = "Comic Mono";
    Mono-X = "Comic Mono,  10";
    MonoAlt = "Monofur Nerd Font Mono";
    MonoRofi = "Comic Mono 10";
    MonoOnboard = "Monofur Nerd Font Mono bold";
    MonoSt = "Comic Mono:style:Regular:pixelsize=10";
    MonoURxvt = "xft:Comic Mono:size=10";
    Sans = "Comic Sans MS";
    Sans-X = "Comic Sans MS,  10";
    Serif = "Comic Sans MS";
    Emoji = "Blobmoji";

    Poly1 = "Comic Mono:size=10.5:weight=medium;3";
    Poly2 = "Hack Nerd Font:size=10.5:weight=medium;3";
    PolySymbols = "Symbols Nerd Font:size=10.5:weight=medium;3";

    i3Style = "Bold Semi-Condensed";
    i3BarStyle = "Regular Semi-Condensed";

    dunstFont = "Comic Sans 10";

    rofiMenuFont = "Comic Mono 12";

    bspTabFont = "monospace:size=11";

    MonoSize = 10;
    MonoSizeKitty = 9;
    MonoSizeAlacritty = 9.5;
    MonoSizePlasma = 11;
    MonoSizePlasmaSmall = 8;
    MonoSizeI3 = 9.0;
    MonoSizeI3Bar = 10.0;
    SansSize = 10;
    MangohudSize = 24;

    sound = "ocean";

    starship1 =           "#3B4252";
    starship2 =           "#434C5E";
    starship3 =           "#4C566A";
    starship4 =           "#86BBD8";
    starship5 =           "#06969A";
    starship6 =           "#33658A";

    Rosewater =  "#f4dbd6";  alt-Rosewater = "f4dbd6";  rgb-Rosewater = "rgb(244, 219, 214)";  rgb-alt-Rosewater = "244,219,214";
    Flamingo =   "#f0c6c6";  alt-Flamingo =  "f0c6c6";  rgb-Flamingo =  "rgb(240, 198, 198)";  rgb-alt-Flamingo =  "240,198,198";
    Pink =       "#f5bde6";  alt-Pink =      "f5bde6";  rgb-Pink =      "rgb(245, 189, 230)";  rgb-alt-Pink =      "245,189,230";
    Mauve =      "#c6a0f6";  alt-Mauve =     "c6a0f6";  rgb-Mauve =     "rgb(198, 160, 246)";  rgb-alt-Mauve =     "198,160,246";
    Red =        "#ed8796";  alt-Red =       "ed8796";  rgb-Red =       "rgb(237, 135, 150)";  rgb-alt-Red =       "237,135,150";
    Maroon =     "#ee99a0";  alt-Maroon =    "ee99a0";  rgb-Maroon =    "rgb(238, 153, 160)";  rgb-alt-Maroon =    "238,153,160";
    Peach =      "#f5a97f";  alt-Peach =     "f5a97f";  rgb-Peach =     "rgb(245, 169, 127)";  rgb-alt-Peach =     "245,169,127";
    Yellow =     "#eed49f";  alt-Yellow =    "eed49f";  rgb-Yellow =    "rgb(238, 212, 159)";  rgb-alt-Yellow =    "238,212,159";
    Green =      "#a6da95";  alt-Green =     "a6da95";  rgb-Green =     "rgb(166, 218, 149)";  rgb-alt-Green =     "166,218,149";
    Teal =       "#8bd5ca";  alt-Teal =      "8bd5ca";  rgb-Teal =      "rgb(139, 213, 202)";  rgb-alt-Teal =      "139,213,202";
    Sky =        "#91d7e3";  alt-Sky =       "91d7e3";  rgb-Sky =       "rgb(145, 215, 227)";  rgb-alt-Sky =       "145,215,227";
    Sapphire =   "#7dc4e4";  alt-Sapphire =  "7dc4e4";  rgb-Sapphire =  "rgb(125, 196, 228)";  rgb-alt-Sapphire =  "125,196,228";
    Blue =       "#8aadf4";  alt-Blue =      "8aadf4";  rgb-Blue =      "rgb(138, 173, 244)";  rgb-alt-Blue =      "138,173,244";
    Lavender =   "#b7bdf8";  alt-Lavender =  "b7bdf8";  rgb-Lavender =  "rgb(183, 189, 248)";  rgb-alt-Lavender =  "183,189,248";

    Text =       "#cad3f5";  alt-Text =      "cad3f5";  rgb-Text =      "rgb(202, 211, 245)";  rgb-alt-Text =      "202,211,245";
    Subtext1 =   "#b8c0e0";  alt-Subtext1 =  "b8c0e0";  rgb-Subtext1 =  "rgb(184, 192, 224)";  rgb-alt-Subtext1 =  "184,192,224";
    Subtext0 =   "#a5adcb";  alt-Subtext0 =  "a5adcb";  rgb-Subtext0 =  "rgb(165, 173, 203)";  rgb-alt-Subtext0 =  "165,173,203";
    Overlay2 =   "#939ab7";  alt-Overlay2 =  "939ab7";  rgb-Overlay2 =  "rgb(147, 154, 183)";  rgb-alt-Overlay2 =  "147,154,183";
    Overlay1 =   "#8087a2";  alt-Overlay1 =  "8087a2";  rgb-Overlay1 =  "rgb(128, 135, 162)";  rgb-alt-Overlay1 =  "128,135,162";
    Overlay0 =   "#6e738d";  alt-Overlay0 =  "6e738d";  rgb-Overlay0 =  "rgb(110, 115, 141)";  rgb-alt-Overlay0 =  "110,115,141";
    Surface2 =   "#5b6078";  alt-Surface2 =  "5b6078";  rgb-Surface2 =    "rgb(91, 96, 120)";  rgb-alt-Surface2 =    "91,96,120";
    Surface1 =   "#494d64";  alt-Surface1 =  "494d64";  rgb-Surface1 =    "rgb(73, 77, 100)";  rgb-alt-Surface1 =    "73,77,100";
    Surface0 =   "#363a4f";  alt-Surface0 =  "363a4f";  rgb-Surface0 =     "rgb(54, 58, 79)";  rgb-alt-Surface0 =     "54,58,79";
    Base =       "#24273a";  alt-Base =      "24273a";  rgb-Base =         "rgb(36, 39, 58)";  rgb-alt-Base =         "36,39,58";
    Mantle =     "#1e2030";  alt-Mantle =    "1e2030";  rgb-Mantle =       "rgb(30, 32, 48)";  rgb-alt-Mantle =       "30,32,48";
    Crust =      "#181926";  alt-Crust =     "181926";  rgb-Crust =        "rgb(24, 25, 38)";  rgb-alt-Crust =        "24,25,38";

    CRosewater = "#F4DBD6";  Calt-Rosewater ="F4DBD6";
    CFlamingo =  "#F0C6C6";  Calt-Flamingo = "F0C6C6";
    CPink =      "#F5BDE6";  Calt-Pink =     "F5BDE6";
    CMauve =     "#C6A0F6";  Calt-Mauve =    "C6A0F6";
    CRed =       "#ED8796";  Calt-Red =      "ED8796";
    CMaroon =    "#EE99A0";  Calt-Maroon =   "EE99A0";
    CPeach =     "#F5A97F";  Calt-Peach =    "F5A97F";
    CYellow =    "#EED49F";  Calt-Yellow =   "EED49F";
    CGreen =     "#A6DA95";  Calt-Green =    "A6DA95";
    CTeal =      "#8BD5CA";  Calt-Teal =     "8BD5CA";
    CSky =       "#91D7E3";  Calt-Sky =      "91D7E3";
    CSapphire =  "#7DC4E4";  Calt-Sapphire = "7DC4E4";
    CBlue =      "#8AADF4";  Calt-Blue =     "8AADF4";
    CLavender =  "#B7BDF8";  Calt-Lavender = "B7BDF8";

    CText =      "#CAD3F5";  Calt-Text =     "CAD3F5";
    CSubtext1 =  "#B8C0E0";  Calt-Subtext1 = "B8C0E0";
    CSubtext0 =  "#A5ADCB";  Calt-Subtext0 = "A5ADCB";
    COverlay2 =  "#939AB7";  Calt-Overlay2 = "939AB7";
    COverlay1 =  "#8087A2";  Calt-Overlay1 = "8087A2";
    COverlay0 =  "#6E738D";  Calt-Overlay0 = "6E738D";
    CSurface2 =  "#5B6078";  Calt-Surface2 = "5B6078";
    CSurface1 =  "#494D64";  Calt-Surface1 = "494D64";
    CSurface0 =  "#363A4F";  Calt-Surface0 = "363A4F";
    CBase =      "#24273A";  Calt-Base =     "24273A";
    CMantle =    "#1E2030";  Calt-Mantle =   "1E2030";
    CCrust =     "#181926";  Calt-Crust =    "181926";

    Transparent = "#FF00000"; alt-Transparent = "#FF00000";
    Black-Transparent = "#00000000"; alt-Black-Transparent = "00000000";

    base00 =     "24273a";  alt-base00 =   "#24273a";  # base
    base01 =     "1e2030";  alt-base01 =   "#1e2030";  # mantle
    base02 =     "363a4f";  alt-base02 =   "#363a4f";  # surface0
    base03 =     "494d64";  alt-base03 =   "#494d64";  # surface1
    base04 =     "5b6078";  alt-base04 =   "#5b6078";  # surface2
    base05 =     "cad3f5";  alt-base05 =   "#cad3f5";  # text
    base06 =     "f4dbd6";  alt-base06 =   "#f4dbd6";  # rosewater
    base07 =     "b7bdf8";  alt-base07 =   "#b7bdf8";  # lavender
    base08 =     "ed8796";  alt-base08 =   "#ed8796";  # red
    base09 =     "f5a97f";  alt-base09 =   "#f5a97f";  # peach
    base0A =     "eed49f";  alt-base0A =   "#eed49f";  # yellow
    base0B =     "a6da95";  alt-base0B =   "#a6da95";  # green
    base0C =     "8bd5ca";  alt-base0C =   "#8bd5ca";  # teal
    base0D =     "8aadf4";  alt-base0D =   "#8aadf4";  # blue
    base0E =     "c6a0f6";  alt-base0E =   "#c6a0f6";  # mauve
    base0F =     "f0c6c6";  alt-base0F =   "#f0c6c6";  # flamingo

    myStuff.myCat = {
      myGlobal-Flav   = "macchiato";
      myGlobal-FlavC  = "Macchiato";
      myGlobal-Color  = "sapphire";
      myGlobal-ColorC = "Sapphire";
    };

    myGlobalCatppuccin = pkgs.catppuccin.override {
      variant = myStuff.myCat.myGlobal-Flav;
      accent = myStuff.myCat.myGlobal-Color;
      themeList = [ "alacritty" "bat" /*"bottom"*/ "btop" /*"element"*/ "grub" /*"hyprland"*/ /*"k9s"*/ /*"kvantum"*/ /*"lazygit"*/
                    /*"lxqt"*/ "qt5ct" "refind" "rofi" "starship" /*"thunderbird"*/ "waybar" ];
    };

    myKDECatppuccin = pkgs.catppuccin-kde.override {
      flavour = [ myStuff.myCat.myGlobal-Flav ];
      accents = [ myStuff.myCat.myGlobal-Color ];
      winDecStyles = [ "classic" ];
    };

    myCursorCatppuccin = pkgs.catppuccin-cursors."${myStuff.myCat.myGlobal-Flav}${myStuff.myCat.myGlobal-ColorC}";

    myIconCatppuccin = pkgs.catppuccin-papirus-folders.override {
      flavor = myStuff.myCat.myGlobal-Flav;
      accent = myStuff.myCat.myGlobal-Color;
    };

    myKvantumCatppuccin = (pkgs.catppuccin-kvantum.override {
      variant = myStuff.myCat.myGlobal-Flav;
      accent = myStuff.myCat.myGlobal-Color;
    }).overrideAttrs (old: {
      installPhase = old.installPhase + ''
        sed -i 's/^\(shadowless_popup=\)false/\1true/' \
          $out/share/Kvantum/catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}/*.kvconfig
      '';});

    myGTKCatppuccin = pkgs.catppuccin-gtk.override {
      variant = myStuff.myCat.myGlobal-Flav;
      accents = [ myStuff.myCat.myGlobal-Color ];
      size = "standard";
     #tweaks = [ "black" ];
    };

   #fehw = pkgs.writeShellScriptBin "fehw" ''
   #  if [ -f "$HOME/.fehbg" ]; then
   #      "$HOME/.fehbg"
   #  else
   #      ${pkgs.feh}/bin/feh --bg-fill ${wallpaper}
   #  fi
   #'';

    fehw = pkgs.writeShellScriptBin "fehw" ''
      FEHBG="$HOME/.fehbg"
      LIVEBG="$HOME/.live-bg"

      if [[ -f "$FEHBG" && -f "$LIVEBG" ]]; then
          if [[ "$FEHBG" -nt "$LIVEBG" ]]; then
              pkill paperview-rs & sh -c "$FEHBG"
              exit 0
          else
              pkill paperview-rs & sh -c "$FEHBG" && sleep 3 && sh -c "$LIVEBG"
              exit 0
          fi
      elif [[ -f "$LIVEBG" ]]; then
          pkill paperview-rs & sh -c "$LIVEBG"
          exit 0
      elif [[ -f "$FEHBG" ]]; then
          pkill paperview-rs & sh -c "$FEHBG"
          exit 0
      else
          ${pkgs.feh}/bin/feh --bg-fill ${wallpaper}
      fi
    '';

    betterlock-init = pkgs.writeShellScriptBin "betterlock-init" ''
      FEHBG="$HOME/.fehbg"
      FALLBACK_WALLPAPER="${wallpaper}"
      wallpaper=""
      if [[ -f "$FEHBG" ]]; then
          wallpaper=$(grep -oE "'[^']+\.(jpg|jpeg|png|webp)'" "$FEHBG" | tail -n 1 | tr -d "'")
      fi
      if [[ -z "$wallpaper" || ! -f "$wallpaper" ]]; then
          wallpaper="$FALLBACK_WALLPAPER"
      fi
      betterlockscreen -u "$wallpaper" --fx dimblur --dim 50 --blur 0.5
    '';

    feh-cycle = pkgs.writeShellScriptBin "feh-cycle" ''
      ${builtins.readFile ./feh-cycle.sh}
    '';

    feh-rofi = pkgs.writeShellScriptBin "feh-rofi" ''
      dir="${config.home.homeDirectory}/Pictures/Wallpapers/${config.my.theme}/" # ends with a /
      cd $dir
      wallpaper="none is selected"
      set="feh --bg-fill"
      view="feh -F"
      selectpic(){
          wallpaper=$(ls $dir | rofi -dmenu -p "select: ($wallpaper)" -theme $HOME/.config/rofi/themes/main.rasi)

          if [[ $wallpaper == "qq" ]]; then
              exit
          else
              action
          fi
      }
      action(){
        whattodo=$(echo -e "view\nset" | rofi -dmenu -p "action ($wallpaper)" -theme $HOME/.config/rofi/themes/main.rasi)
          if [[ $whattodo == "set" ]]; then
              set_wall
          else
              view_wall
          fi
      }
      set_wall(){
          $set $wallpaper && pkill feh &
      }
      view_wall(){
          $view $wallpaper &
          set_after_view
      }
      set_after_view(){
        setorno=$(echo -e "set\nback" | rofi -dmenu -p "set it? ($wallpaper)" -theme $HOME/.config/rofi/themes/main.rasi)

        if [[ $setorno == "set" ]]; then
            set_wall
        else
            pkill feh &
            sleep 1 &
            feh-rofi &
        fi
      }
      selectpic
    '';

    live-bg = pkgs.writeShellScriptBin "live-bg" ''
      LIVE_BG="$HOME/.live-bg"
      LIVE_DIR="$HOME/Pictures/live-wallpapers"
      RES="${config.my.display.primary.x}:${config.my.display.primary.y}:0:0"
      DEFAULT_FOLDER=1
      DEFAULT_SPEED=10
      pkill paperview-rs 2>/dev/null && touch $HOME/.fehbg && exit 0
      if [[ -f "$LIVE_BG" ]]; then
          touch $HOME/.live-bg
          bash "$LIVE_BG"
          exit 0
      fi
      CMD="paperview-rs --bg \"$RES:$LIVE_DIR/$DEFAULT_FOLDER/:$DEFAULT_SPEED\""
      echo "#!/bin/bash" > "$LIVE_BG"
      echo "$CMD" >> "$LIVE_BG"
      chmod +x "$LIVE_BG"
      eval "$CMD"
    '';

    live-bg-cycle = pkgs.writeShellScriptBin "live-bg-cycle" ''
      LIVE_BG="$HOME/.live-bg"
      LIVE_DIR="$HOME/Pictures/live-wallpapers"
      RES="${config.my.display.primary.x}:${config.my.display.primary.y}:0:0"
      DEF_FOLDER=1
      DEF_SPEED=10
      ACTION="$1"
      pkill paperview-rs 2>/dev/null
      if [[ -f "$LIVE_BG" ]]; then
          CUR_FOLDER=$(grep -oP 'live-wallpapers/\K[0-9]+' "$LIVE_BG")
          CUR_SPEED=$(grep -oP ':[0-9]+$' "$LIVE_BG" | tr -d :)
      fi
      [[ -z "$CUR_FOLDER" ]] && CUR_FOLDER=$DEF_FOLDER
      [[ -z "$CUR_SPEED"  ]] && CUR_SPEED=$DEF_SPEED
      MAX=$(ls -d "$LIVE_DIR"/*/ 2>/dev/null | wc -l)
      if [[ "$ACTION" == "+" ]]; then
          ((CUR_FOLDER++))
          ((CUR_FOLDER > MAX)) && CUR_FOLDER=1
      elif [[ "$ACTION" == "-" ]]; then
          ((CUR_FOLDER--))
          ((CUR_FOLDER < 1)) && CUR_FOLDER=$MAX
      else
          exit 1
      fi
      CMD="paperview-rs --bg \"$RES:$LIVE_DIR/$CUR_FOLDER/:$CUR_SPEED\""
      printf '#!/bin/bash\n%s\n' "$CMD" > "$LIVE_BG"
      chmod +x "$LIVE_BG"
      eval "$CMD"
    '';

    live-bg-speed = pkgs.writeShellScriptBin "live-bg-speed" ''
      LIVE_BG="$HOME/.live-bg"
      LIVE_DIR="$HOME/Pictures/live-wallpapers"
      RES="${config.my.display.primary.x}:${config.my.display.primary.y}:0:0"
      DEF_FOLDER=1
      DEF_SPEED=10
      ACTION="$1"
      pkill paperview-rs 2>/dev/null
      if [[ -f "$LIVE_BG" ]]; then
          CUR_FOLDER=$(sed -n 's|.*/live-wallpapers/\([0-9]\+\)/.*|\1|p' "$LIVE_BG")
          CUR_SPEED=$(sed -n 's|.*:\([0-9]\+\)".*|\1|p' "$LIVE_BG")
      fi
      [[ -z "$CUR_FOLDER" ]] && CUR_FOLDER=$DEF_FOLDER
      [[ -z "$CUR_SPEED"  ]] && CUR_SPEED=$DEF_SPEED
      if [[ "$ACTION" == "+" ]]; then
          CUR_SPEED=$((CUR_SPEED + 1))
      elif [[ "$ACTION" == "-" ]]; then
          CUR_SPEED=$((CUR_SPEED - 1))
          ((CUR_SPEED < 1)) && CUR_SPEED=1
      else
          exit 1
      fi
      CMD="paperview-rs --bg \"$RES:$LIVE_DIR/$CUR_FOLDER/:$CUR_SPEED\""
      printf '#!/bin/bash\n%s\n' "$CMD" > "$LIVE_BG"
      chmod +x "$LIVE_BG"
      eval "$CMD"
    '';

    live-bg-pause = pkgs.writeShellScriptBin "live-bg-pause" ''
      PROC="paperview-rs"
      PID=$(pgrep -n "$PROC")
      if [ -z "$PID" ]; then
          echo "Process not running"
          exit 1
      fi
      STATE=$(ps -o state= -p "$PID")
      if [[ "$STATE" == *T* ]]; then
          kill -CONT "$PID"
          echo "Resumed $PROC"
      else
          kill -STOP "$PID"
          echo "Paused $PROC"
      fi
    '';

    live-bg-speed-manual = pkgs.writeShellScriptBin "live-bg-speed-manual" ''
      FILE="$HOME/.live-bg"
      [ -f "$FILE" ] || exit 0
      SPEED=$(rofi -dmenu -p "Speed" -theme $HOME/.config/rofi/themes/power.rasi)
      [ -z "$SPEED" ] && exit 0
      sed -i "s/:\([0-9]\+\)\"$/:$SPEED\"/" "$FILE"
      pkill paperview-rs && $HOME/.live-bg
    '';

    bsp-border-color = pkgs.writeShellScriptBin "bsp-border-color" ''
      direction=$1
      TMPFILE="/tmp/.bspwm_border_color_index"
      color0="${Red}"
      color1="${Peach}"
      color2="${Blue}"
      color3="${Sapphire}"
      color4="${Sky}"
      color5="${Teal}"
      color6="${Green}"
      color7="${Yellow}"
      color8="${Maroon}"
      color9="${Mauve}"
      color10="${Rosewater}"
      color11="${Flamingo}"
      color12="${Pink}"
      color13="${Base}"
      color14="${Lavender}"
      NUM_COLORS=15
      if [ -f "$TMPFILE" ]; then
          index=$(cat "$TMPFILE")
      else
          index=0
      fi
      if ! [ "$index" -eq "$index" ] 2>/dev/null; then
          index=0
      fi
      if [ $index -ge $NUM_COLORS ] || [ $index -lt 0 ]; then
          index=0
      fi
      if [ "$direction" = "next" ]; then
          index=$(( (index + 1) % NUM_COLORS ))
      elif [ "$direction" = "prev" ]; then
          index=$(( (index - 1 + NUM_COLORS) % NUM_COLORS ))
      else
          echo "Usage: $0 next|prev"
          exit 1
      fi
      case $index in
          0) color="$color0" ;;
          1) color="$color1" ;;
          2) color="$color2" ;;
          3) color="$color3" ;;
          4) color="$color4" ;;
          5) color="$color5" ;;
          6) color="$color6" ;;
          7) color="$color7" ;;
          8) color="$color8" ;;
          9) color="$color9" ;;
          10) color="$color10" ;;
          11) color="$color11" ;;
          12) color="$color12" ;;
          13) color="$color13" ;;
          14) color="$color14" ;;
          *) color="$color0" ;;
      esac
      bspc config focused_border_color "$color"
      echo "$index" > "$TMPFILE"
    '';

    bsp-tabbed = pkgs.callPackage ../desktops/bspwm/tabbed/bsp-tabbed.nix {
      customConfig = ''
        static char *font         = "${bspTabFont}";
        static char *normbgcolor  = "${Surface0}";
        static char *normfgcolor  = "${Text}";
        static char *selbgcolor   = "${Base}";
        static char *selfgcolor   = "${Text}";
        static char *urgbgcolor   = "${Red}";
        static char *urgfgcolor   = "${Crust}";
        static char before[]      = "<";
        static char after[]       = ">";
        static char titletrim[]   = "...";
        static int  tabwidth      = 200;
        static int  foreground    = 1;
        static int  urgentswitch  = 0;
        static int  newposition   = -1; // attach new windows at the end
        //static int newposition  = 0;
        static int npisrelative = 0;

        #define SETPROP(p) { \
        .v = (char *[]){ "/bin/sh", "-c", \
            "prop=\"`xwininfo -children -id $1 | grep '^     0x' |" \
            "sed -e's@^ *\\(0x[0-9a-f]*\\) \"\\([^\"]*\\)\".*@\\1 \\2@' |" \
            "xargs -0 printf %b | dmenu -l 10 -w $1`\" &&" \
            "xprop -id $1 -f $0 8s -set $0 \"$prop\"", \
            p, winid, NULL \
        } \
        }

        #define MODKEY ControlMask
        static const Key keys[] = {
            /* modifier             key           function     argument */
            { MODKEY|ShiftMask,     XK_Return,    focusonce,   { 0 } },
            { MODKEY|ShiftMask,     XK_Return,    spawn,       { 0 } },

            { MODKEY|ShiftMask,     XK_l,         rotate,      { .i = +1 } },
            { MODKEY|ShiftMask,     XK_h,         rotate,      { .i = -1 } },
            { MODKEY|ShiftMask,     XK_j,         movetab,     { .i = -1 } },
            { MODKEY|ShiftMask,     XK_k,         movetab,     { .i = +1 } },
            { MODKEY,               XK_Tab,       rotate,      { .i = 0 } },

            { MODKEY,               XK_grave,     spawn,       SETPROP("_TABBED_SELECT_TAB") },
            { MODKEY,               XK_1,         move,        { .i = 0 } },
            { MODKEY,               XK_2,         move,        { .i = 1 } },
            { MODKEY,               XK_3,         move,        { .i = 2 } },
            { MODKEY,               XK_4,         move,        { .i = 3 } },
            { MODKEY,               XK_5,         move,        { .i = 4 } },
            { MODKEY,               XK_6,         move,        { .i = 5 } },
            { MODKEY,               XK_7,         move,        { .i = 6 } },
            { MODKEY,               XK_8,         move,        { .i = 7 } },
            { MODKEY,               XK_9,         move,        { .i = 8 } },
            { MODKEY,               XK_0,         move,        { .i = 9 } },

            { MODKEY,               XK_q,         killclient,  { 0 } },

            { MODKEY,               XK_u,         focusurgent, { 0 } },
            { MODKEY|ShiftMask,     XK_u,         toggle,      { .v = (void*) &urgentswitch } },

            { 0,                    XK_F11,       fullscreen,  { 0 } },
        };
      '';
    };
    bsptab = pkgs.callPackage ../desktops/bspwm/tabbed/bsptab.nix { tabbed = bsp-tabbed; };

  in

{ config = lib.mkIf (config.my.theme == "catppuccin-uni") {

  home.packages = [

    pkgs.catppuccinifier-cli
    pkgs.catppuccin-qt5ct

    global-package

    gtk-package
    qt-package
    kvantum-package
    plasma-package
    xfce-package
    mate-package
    cinnamon-package

    gtk-icon-package
    qt-icon-package

    gtk-cursor-package
    x-cursor-package
    plasma-cursor-package
    hypr-cursor-package

    betterlock-init
    fehw
    feh-cycle
    feh-rofi

    live-bg
    live-bg-speed
    live-bg-cycle
    live-bg-pause
    live-bg-speed-manual

    bsp-border-color
    bsp-tabbed
    bsptab

  ];

  gtk = {
    enable = true;
    colorScheme = scheme;

    theme = {
      package = gtk-package;
      name = gtk-theme;
    };
    iconTheme = {
      package = lib.mkForce gtk-icon-package;
      name = gtk-icon;
    };
    cursorTheme = {
      package = gtk-cursor-package;
      name = gtk-cursor;
      size = cursor-size;
    };
    font = {
     #package = pkgs.corefonts;
      name = Sans;
      size = SansSize;
    };

    gtk2 = {
      force = true;
      configLocation = "${config.home.homeDirectory}/.gtkrc-2.0";
    };

    gtk3.bookmarks = [
      "file:///home/${config.home.username}/Documents"
      "file:///home/${config.home.username}/Downloads"
      "file:///home/${config.home.username}/Music"
      "file:///home/${config.home.username}/Pictures"
      "file:///home/${config.home.username}/Videos"
      "file:///home/${config.home.username}/nixos"
      "file:///"
      "file:///mnt/windows"
      "file:///mnt/media"
    ];
  };

  qt = {
    enable = true;
   #platformTheme.name = qt-platform; # WARNING BE CAREFUL, QT BREAKS A LOT
    style = {
      name = qt-name; # WARNING style name for kvantum platform is "Kvantun", and for qtct platform is "kvantum" (lower case!)
      package = qt-package;
    };
  };

 #home.sessionVariables = {
 #  QT_QPA_PLATFORMTHEME = lib.mkForce "";
 #};

 #services.screen-locker.lockCmd = lib.mkIf config.xsession.enable "\${pkgs.i3lock}/bin/i3lock -n -c ${Base} -f -k ";

  services.xsettingsd = lib.mkIf config.xsession.enable {
    settings = {
      "Net/SoundThemeName" = sound;
      "Net/IconThemeName" = gtk-icon;
      "Net/ThemeName" = gtk-theme;
      "Gtk/CursorThemeName" = gtk-cursor;
      "Gtk/FontName" = Sans-X;
      "Gtk/DecorationLayout" = gtk-decoration;
      "Gtk/EnableAnimations" = 1;
      "Gtk/PrimaryButtonWarpsSlider" = 1;
      "Gtk/ToolbarStyle" = 3;
      "Gtk/MenuImages" = 1;
      "Gtk/ButtonImages" = 1;
      "Gtk/CursorThemeSize" = cursor-size;
    };
  };
  xsession.initExtra = lib.mkIf config.xsession.enable ''
    xsetroot -solid ${Base} &
    hsetroot -cover ${wallpaper} &
    xrdb -load ${config.xresources.path} &
    xrdb -merge ${config.xresources.path} &
    xsetroot -cursor_name left_ptr &
    ${config.services.dunst.package}/bin/dunst &
    ${fehw}/bin/fehw &
    ${betterlock-init}/bin/betterlock-init &
    #${pkgs.betterlockscreen}/bin/betterlockscreen -u ${wallpaper} --fx dimblur --dim 50 --blur 0.5 &
  '';
  xsession.profileExtra = lib.mkIf config.xsession.enable ''
    xsetroot -cursor_name left_ptr &
  '';
  xresources.properties = lib.mkIf config.xsession.enable {
    #! basics
    "*background" =   Base;
    "*foreground" =   Text;
    "*cursorColor" =  Rosewater;
    #! black
    "*color0" =       Surface1;
    "*color8" =       Surface2;
    #! red
    "*color1" =       Red;
    "*color9" =       Red;
    #! green
    "*color2" =       Green;
    "*color10" =      Green;
    #! yellow
    "*color3" =       Yellow;
    "*color11" =      Yellow;
    #! blue
    "*color4" =       Blue;
    "*color12" =      Blue;
    #! magenta
    "*color5" =       Pink;
    "*color13" =      Pink;
    #! cyan
    "*color6" =       Teal;
    "*color14" =      Teal;
    #! white
    "*color7" =       Subtext1;
    "*color15" =      Subtext0;
    "Xft.antialias" = 1;
    "Xft.hinting" = 1;
    "Xft.autohint" = 0;
    "Xft.hintstyle" = "hintslight";
    "Xft.rgba" = "rgb";
    "Xft.lcdfilter" = "lcddefault";
   #"Xft.dpi" = 140;
    "XTerm*faceName" = MonoSpace;
    "XTerm*faceSize" = MonoSize;
    "URxvt.font" = MonoURxvt;
    "dmenu.selbackground" = Base;
    "dmenu.selforeground" = Text;
   #"*background" = "[background_opacity]#fafafa";
   #"st.font" = MonoSt;
   #"st.alpha" = 0.80; # For Transparent 0.60
   #"st.borderpx" = 10; # inner border
   #dwm.normbgcolor: #FAFAFA
   #dwm.normbordercolor: #FAFAFA
   #dwm.normfgcolor: #2E3440
   #dwm.selfgcolor: #FAFAFA
   #dwm.selbordercolor: #B48EAD
   #dwm.selbgcolor: #81A1C1
  };
 #xsession = lib.mkIf config.xsession.enable {   # DEPRICATED
 #  pointerCursor = {
 #    defaultCursor = x-cursor;
 #    name = x-cursor;
 #   #package = x-cursor-package;
 #    size = cursor-size;
 #  };
 #};

  services.flatpak = lib.mkIf config.my.flatpak.enable {
    overrides = {
      global = {
        Environment = {
         #GTK_THEME = gtk-theme;
         #GTK_ICON_THEME = gtk-icon;
          QT_STYLE_OVERRIDE = qt-name;
          QT_QPA_PLATFORMTHEME = qt-platform;
          XCURSOR_THEME = x-cursor;
          HYPRCURSOR_THEME = hypr-cursor;
        };
      };
    };
  };

  home.pointerCursor = {
    enable = true;
    package = gtk-cursor-package;
    name = gtk-cursor;
    size = cursor-size;
    dotIcons.enable = true;
    gtk.enable = true;
    sway.enable = lib.mkIf (config.wayland.windowManager.sway.enable) true;
    hyprcursor = lib.mkIf config.my.hypr.hyprland.enable {
      enable = true;
      size = cursor-size;
    };
    x11 = lib.mkIf config.xsession.enable {
      enable = true;
      defaultCursor = x-cursor;
    };
  };

  fonts = lib.mkIf config.my.fonts.enable {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = lib.mkForce [ MonoSpace ];
        serif = lib.mkForce [ Serif ];
        sansSerif = lib.mkForce [ Sans ];
        emoji = lib.mkForce [ Emoji ];
      };
    };
  };

  xsession.windowManager.i3.config = lib.mkIf config.xsession.windowManager.i3.enable {
    fonts = {
      names = [ MonoSpace Sans ];
      style = i3Style;
      size = MonoSizeI3;
    };
    startup = [ { command = "fehw"; always = true; } ];
    colors = {
      urgent = {
        background = Base;
        border = Peach;
        childBorder = Peach;
        indicator = Overlay0;
        text = Text;
      };
      placeholder = {
        background = Base;
        border = Overlay0;
        childBorder = Overlay0;
        indicator = Overlay0;
        text = Text;
      };
      unfocused = {
        background = Base;
        border = Overlay0;
        childBorder = Overlay0;
        indicator = Rosewater;
        text = Text;
      };
      focusedInactive = {
        background = Base;
        border = Overlay0;
        childBorder = Overlay0;
        indicator = Rosewater;
        text = Text;
      };
      focused = {
        background = Base;
        border = Lavender;
        childBorder = Lavender;
        indicator = Rosewater;
        text = Text;
      };
      background = Base;
    };
    bars = [
      {
        position = i3BarPos;
        workspaceNumbers = true;
        workspaceButtons = true;
        trayPadding = 1;
        trayOutput = "primary";
        statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-top.toml";
        mode = i3BarMode;
        id = i3BarPos;
       #extraConfig
        hiddenState = "hide";
        command = "i3bar";
        fonts = {
          names = [ MonoSpace Sans ];
          style = i3BarStyle;
          size = MonoSizeI3Bar;
        };
        colors = {
          separator = Sapphire;
          focusedBackground = Base;
          focusedWorkspace = {
            background = Sapphire;
            border = Base;
            text = Crust;
          };
          activeWorkspace = {
            background = Surface2;
            border = Base;
            text = Text;
          };
          inactiveWorkspace = {
            background = Base;
            border = Base;
            text = Text;
          };
          urgentWorkspace = {
            background = Red;
            border = Base;
            text = Crust;
          };
          bindingMode = {
            background = Peach;
            border = Base;
            text = Crust;
          };
          background = Base;
          statusline = Text;
          focusedStatusline = Text;
          focusedSeparator = Base;
        };
      }
    ];
  };
  programs.i3status-rust = lib.mkIf config.programs.i3status-rust.enable {
    bars = {
      top = {
        icons = i3status-icon;
        theme = i3status-theme;
       #settings = {
       #  theme =  {
       #    theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}";
       #    overrides = {
       #      idle_bg = "#123456";
       #      idle_fg = "#abcdef";
       #    };
       #  };
       #};
      };
    };
  };
  wayland.windowManager.sway.config = lib.mkIf config.wayland.windowManager.sway.enable {
    fonts = config.xsession.windowManager.i3.config.fonts;
    colors = config.xsession.windowManager.i3.config.colors;
    bars = config.xsession.windowManager.i3.config.bars;
  };
  xsession.windowManager.bspwm = lib.mkIf config.xsession.windowManager.bspwm.enable {
    extraConfig = ''
      #bspc rule -a '*' type=dialog state=floating border_color="${Yellow}"
      bspc rule -a ".blueman-manager-wrapped" border_color="${Blue}"
      fehw &
  '';
    settings = {
      presel_feedback_color = Overlay1;
      active_border_color = Lavender;
      focused_border_color = Lavender;
      normal_border_color = Overlay0;
    };
    startupPrograms = [
     #"feh --bg-fill ${wallpaper}"
    ];
  };

  programs.plasma = lib.mkIf config.programs.plasma.enable {
    kwin = {
      titlebarButtons = { # “more-window-actions”, “application-menu”, “on-all-desktops”, “minimize”, “maximize”, “close”, “help”, “shade”, “keep-below-windows”, “keep-above-windows”
        left = plasma-decoration-left;
        right = plasma-decoration-right;
      };
    };
    workspace = {
      lookAndFeel = plasma-look;      # Global Theme  # plasma-apply-lookandfeel --list
      widgetStyle = plasma-widget;
      theme = plasma-theme;           # Plasma Style  # # plasma-apply-desktoptheme --list-themes
      colorScheme = plasma-color;     # plasma-apply-colorscheme --list-schemes
      windowDecorations = {
        theme = plasma-decoration-name;       # see the theme key in as in below
        library = plasma-decoration-platform; # see the library key in the org.kde.kdecoration2 section of $HOME/.config/kwinrc after imperatively applying the window decoration via the System Settings app.
      };
      cursor = { # plasma-apply-cursortheme --list-themes
        theme = plasma-cursor;
        size = cursor-size;
      };
      iconTheme = qt-icon;
      splashScreen = { # $HOME/.config/ksplashrc
        theme = plasma-splash;
       #engine = null;
      };
     #soundTheme = "freedesktop";
      wallpaper = wallpaper;
      wallpaperBackground = { # only one of below
        blur = true;
       #color = "219.99.99";
      };
      wallpaperFillMode = "preserveAspectCrop";   # “pad”, “preserveAspectCrop”, “preserveAspectFit”, “stretch”, “tile”, “tileHorizontally”, “tileVertically”
     #wallpaperPictureOfTheDay = {
     #  provider = null;  # “apod”, “bing”, “flickr”, “natgeo”, “noaa”, “wcpotd”, “epod”, “simonstalenhag”
     #  updateOverMeteredConnection = false;
     #};
     #wallpaperSlideShow = {
     #  interval = 300;
     #  path = [ "" "" ];
     #};
    };
    kscreenlocker.appearance.wallpaper = wallpaper;
    fonts = {
      fixedWidth = {
        family = MonoSpace;
       #styleName = "";                    # Overrides both Style and Weight
       #style = "normal";                  # “italic”, “normal”, “oblique”
       #weight = "normal";                 # 1 and 1000 (both inclusive) or one of “black”, “bold”, “demiBold”, “extraBold”, “extraLight”, “light”, “medium”, “normal”, “thin”
        pointSize = MonoSizePlasma;
       #pixelSize = <nuumber>;             # mutually exclusive with point size
       #capitalization = "mixedCase";      # “allLowercase”, “allUppercase”, “capitalize”, “mixedCase”, “smallCaps”
       #underline = false;

       #styleHint = "anyStyle";            # “anyStyle”, “courier”, “cursive”, “decorative”, “fantasy”, “helvetica”, “monospace”, “oldEnglish”, “sansSerif”, “serif”, “system”, “times”, “typewriter”
       #styleStrategy = {
       #  antialiasing = "default";        # “default”, “disable”, “prefer”
       #  matchingPrefer = "default";      # “default”, “exact”, “quality”
       #  noFontMerging = false;
       #  noSubpixelAntialias = false;
       #  prefer = "default";              # “bitmap”, “default”, “device”, “forceOutline”, “outline”
       #  preferNoShaping = false;
       #};

       #letterSpacing = 0;
       #letterSpacingType = "percentage";  # “absolute”, “percentage”
       #wordSpacing = 0;
       #stretch = "anyStretch";            # integer between 1 and 4000 (both inclusive) or one of “anyStretch”, “condensed”, “expanded”, “extraCondensed”, “extraExpanded”, “semiCondensed”, “semiExpanded”, “ultraCondensed”, “ultraExpanded”, “unstretched”
       #strikeOut = false;
       #fixedPitch = false;
      };
      general = {
        family = Sans;
        pointSize = SansSize;
      };
      menu = {
        family = Sans;
        pointSize = SansSize;
      };
      small = {
        family = Sans;
        pointSize = MonoSizePlasmaSmall;
      };
      toolbar = {
        family = Sans;
        pointSize = SansSize;
      };
      windowTitle = {
        family = Sans;
        pointSize = SansSize;
      };
    };
    file = {
      "/.config/dolphinrc" = {
        "UiSettings" = {
          "ColorScheme" = dolphin-theme; # "*"
        };
      };
      "/.config/okularrc" = {
        "UiSettings" = {
          "ColorScheme" = okular-theme;
        };
      };
      "/.config/kwriterc" = {
        "KTextEditor Renderer" = {
          "Color Theme" = kwrite-theme;
          "Auto Color Theme Selection" = false;
        };
        "UiSettings" = {
          "ColorScheme" = kwrite-color;
        };
      };
      "/.config/marknoterc" = {
        "General" = {
          "colorScheme" = marknote-theme;
        };
        "UiSettings" = {
          "ColorScheme" = marknote-theme;
        };
      };
     #"/.config/kdedefaults/kdegloblas" = {
     #  "Icons" = {
     #    "Theme" = qt-icon; # "*"
     #  };
     #};
    };
  };

  programs.gnome-shell = lib.mkIf config.my.gnome.enable {
    enable = true;
   #extensions = [ ];
    theme = {
      package = gtk-package;
      name = gtk-theme;
    };
  };

  dconf.settings = {

     # Cinnamon
    "org/cinnamon/desktop/interface" = lib.mkIf config.my.cinnamon.enable {
      gtk-theme = gtk-theme;
      icon-theme = gtk-icon;
    };
    "org/cinnamon/theme" = lib.mkIf config.my.cinnamon.enable {
      name = cinnamon-theme;
    };
    "org/cinnamon/desktop/background" = lib.mkIf config.my.cinnamon.enable {
      picture-uri = wallpaper-alt;
    };

     # Mate
    "org/mate/marco/general" = lib.mkIf config.my.mate.enable {
      theme = mate-theme;
    };
    "org/mate/desktop/background" = lib.mkIf config.my.mate.enable {
      picture-filename = wallpaper;
      picture-options = "wallpaper";
    };
    "org/mate/desktop/interface" = lib.mkIf config.my.mate.enable {
      gtk-theme = gtk-theme;
      icon-theme = gtk-icon;
    };
    "org/mate/desktop/peripherals/mouse" = lib.mkIf config.my.mate.enable {
      cursor-theme = gtk-cursor;
    };

     # Onboard
    "org/onboard" = lib.mkIf config.my.apps.onboard.enable {
      layout = onboard-layout;
      theme = onboard-theme;
    };
    "org/onboard/theme-settings" = lib.mkIf config.my.apps.onboard.enable {
      color-scheme = onboard-color;
      key-label-font = MonoOnboard;
      key-style = onboard-key;

      background-gradient = 0.0;
      key-shadow-size = 80.0;
      key-shadow-strength = 80.0;
      key-size = 98.0;
      key-stroke-gradient = 40.0;
      key-stroke-width = 100.0;
      roundrect-radius = 22.0;
    };

  };

  xfconf.settings = lib.mkIf config.my.xfce.enable {
    xsettings = {
      "Net/SoundThemeName" = sound;
      "Net/IconThemeName" = gtk-icon;
      "Net/ThemeName" = gtk-theme;
      "Gtk/CursorThemeName" = gtk-cursor;
      "Gtk/FontName" = Sans-X;
      "Gtk/DecorationLayout" = gtk-decoration;
      "Gtk/EnableAnimations" = 1;
      "Gtk/PrimaryButtonWarpsSlider" = 1;
      "Gtk/ToolbarStyle" = 3;
      "Gtk/MenuImages" = 1;
      "Gtk/ButtonImages" = 1;
      "Gtk/CursorThemeSize" = cursor-size;
      "Gtk/MonospaceFontName" = Mono-X;
    };
    xfwm4 = {
      "general/theme" = xfce-theme;
    };
    xfce4-desktop = {
      "backdrop/screen0/monitor0/image-path" = wallpaper;
      "backdrop/screen0/monitorLVDS-1/workspace0/last-image" = wallpaper;
    };
    xfce4-terminal = {
      "scheme-name" = xfce4-terminal-theme;
    };
  };

  programs = {
    konsole = lib.mkIf config.my.kde.konsole.enable {
      customColorSchemes = {
        ${konsole-theme} = pkgs.writeTextFile {
          name = "${konsole-theme}.colorscheme";
          text = ''
            [Background]
            Color=${rgb-alt-Base}
            [BackgroundFaint]
            Color=${rgb-alt-Base}
            [BackgroundIntense]
            Color=${rgb-alt-Base}
            [Color0]
            Color=${rgb-alt-Overlay0}
            [Color0Faint]
            Color=${rgb-alt-Overlay0}
            [Color0Intense]
            Color=${rgb-alt-Overlay0}
            [Color1]
            Color=${rgb-alt-Red}
            [Color1Faint]
            Color=${rgb-alt-Red}
            [Color1Intense]
            Color=${rgb-alt-Red}
            [Color2]
            Color=${rgb-alt-Green}
            [Color2Faint]
            Color=${rgb-alt-Green}
            [Color2Intense]
            Color=${rgb-alt-Green}
            [Color3]
            Color=${rgb-alt-Yellow}
            [Color3Faint]
            Color=${rgb-alt-Yellow}
            [Color3Intense]
            Color=${rgb-alt-Yellow}
            [Color4]
            Color=${rgb-alt-Blue}
            [Color4Faint]
            Color=${rgb-alt-Blue}
            [Color4Intense]
            Color=${rgb-alt-Blue}
            [Color5]
            Color=${rgb-alt-Mauve}
            [Color5Faint]
            Color=${rgb-alt-Mauve}
            [Color5Intense]
            Color=${rgb-alt-Mauve}
            [Color6]
            Color=${rgb-alt-Sky}
            [Color6Faint]
            Color=${rgb-alt-Sky}
            [Color6Intense]
            Color=${rgb-alt-Sky}
            [Color7]
            Color=${rgb-alt-Text}
            [Color7Faint]
            Color=${rgb-alt-Text}
            [Color7Intense]
            Color=${rgb-alt-Text}
            [Foreground]
            Color=${rgb-alt-Text}
            [ForegroundFaint]
            Color=${rgb-alt-Text}
            [ForegroundIntense]
            Color=${rgb-alt-Text}
            [General]
            Blur=false
            ColorRandomization=false
            Description=Catppuccin Macchiato
            Opacity=1
            Wallpaper=
          '';
        };
      };
      ui.colorScheme = konsole-theme;
      profiles = {
        ${config.home.username} = {
          colorScheme=konsole-theme;
          font = {
            name = MonoAlt;
            size = MonoSizePlasma;
          };
        };
      };
    };
    kate = lib.mkIf config.my.kde.kate.enable {
      enable=true;
      editor = {
        theme = {
          name=kate-theme;
         #src = ""; # absolute path to theme
        };
        font = {       # Same settings as plasma fonts
          family = MonoSpace;
          pointSize = MonoSize;
        };
      };
      ui.colorScheme=kate-ui;
    };
    kitty = lib.mkIf config.programs.kitty.enable {
      settings = {
        background = Base;
        foreground = Text;
        tab_bar_background = Base;
        tab_bar_margin_color = Base;
        active_tab_foreground = Text;
        active_tab_background = starship6;
        inactive_tab_foreground = Text;
        inactive_tab_background = starship1;
        selection_foreground = Base;
        selection_background = Rosewater;
        cursor = Rosewater;
        cursor_text_color = Base;
        url_color = Rosewater;
        active_border_color = Lavender;
        inactive_border_color = Overlay0;
        bell_border_color = Yellow;
        wayland_titlebar_color = "system";
        macos_titlebar_color = "system";
        mark1_foreground = Base;
        mark1_background = Lavender;
        mark2_foreground = Base;
        mark2_background = Mauve;
        mark3_foreground = Base;
        mark3_background = Sapphire;
        color0  = Surface1;   # black
        color8  = Surface2;
        color1  = Red;        # red
        color9  = Red;
        color2  = Green;      # green
        color10 = Green;
        color3  = Yellow;     # yellow
        color11 = Yellow;
        color4  = Blue;       # blue
        color12 = Blue;
        color5  = Pink;       # magenta
        color13 = Pink;
        color6  = Teal;       # cyan
        color14 = Teal;
        color7  =  Subtext1;  # white
        color15 = Subtext0;
      };
      font = {
        name = lib.mkForce MonoSpace;
        size = lib.mkForce MonoSizeKitty;
      };
    };
    alacritty = lib.mkIf config.programs.alacritty.enable {
      theme = alacritty-theme;
      settings = {
        font = {
         #glyph_offset = { x = 1, y = 0 }
          size = lib.mkForce MonoSizeAlacritty;
          normal = {
            family = lib.mkForce MonoSpace;
            style = "Regular";
          };
          bold = {
            family = lib.mkForce MonoSpace;
            style = "Bold";
          };
          italic = {
            family = lib.mkForce MonoSpace;
            style = "Italic";
          };
        };
      };
    };
    ghostty = lib.mkIf config.programs.ghostty.enable {
      settings = {
        theme = ghostty-theme;
        font-size = 10;
      };
      themes = {
        ${ghostty-theme-name} = {
          background = alt-Base;
          cursor-color = alt-Rosewater;
          cursor-text = alt-Crust;
          foreground = alt-Text;
          palette = [
             "0=${alt-base03}"
             "1=${alt-base08}"
             "2=${alt-base0B}"
             "3=${alt-base0A}"
             "4=${alt-base0D}"
             "5=${Pink}"
             "6=${alt-base0C}"
             "7=${Subtext0}"
             "8=${alt-base04}"
             "9=${alt-base08}"
            "10=${alt-base0B}"
            "11=${alt-base0A}"
            "12=${alt-base0D}"
            "13=${Pink}"
            "14=${alt-base0C}"
            "15=${Subtext1}"
          ];
          selection-background = alt-Rosewater;
          selection-foreground = alt-Crust;
          split-divider-color = alt-Surface0;
        };
      };
    };
    freetube = lib.mkIf config.programs.freetube.enable {
      settings = {
        baseTheme = freetube-base;
        mainColor = freetube-main;
        secColor = freetube-sec;
      };
    };
    superfile = lib.mkIf config.programs.superfile.enable {
      settings = {
        theme = superfile-theme;
        transparent_background = false;
      };
     #themes = {};
    };
    rofi = lib.mkIf config.programs.rofi.enable {
      font = MonoRofi;
      theme = {
        "@theme" = "${config.my.theme}";
        "@import" = "${config.my.theme}-color";
      };
    };
    waybar = lib.mkIf config.programs.waybar.enable {
      style = lib.mkBefore ''
        @define-color rosewater ${Rosewater};
        @define-color flamingo  ${Flamingo};
        @define-color pink      ${Pink};
        @define-color mauve     ${Mauve};
        @define-color red       ${Red};
        @define-color maroon    ${Maroon};
        @define-color peach     ${Peach};
        @define-color yellow    ${Yellow};
        @define-color green     ${Green};
        @define-color teal      ${Teal};
        @define-color sky       ${Sky};
        @define-color sapphire  ${Sapphire};
        @define-color blue      ${Blue};
        @define-color lavender  ${Lavender};
        @define-color text      ${Text};
        @define-color subtext1  ${Subtext1};
        @define-color subtext0  ${Subtext0};
        @define-color overlay2  ${Overlay2};
        @define-color overlay1  ${Overlay1};
        @define-color overlay0  ${Overlay0};
        @define-color surface2  ${Surface2};
        @define-color surface1  ${Surface1};
        @define-color surface0  ${Surface0};
        @define-color base      ${Base};
        @define-color mantle    ${Mantle};
        @define-color crust     ${Crust};
        * {
          min-height: 0;
          margin: 1;
          padding: 1;
          font-family: "${MonoSpace}";
          font-size: 10pt;
          font-weight: 700;
          padding-bottom: 0px;
        }
        tooltip {
          background: @crust;
          border: 2px solid @subtext0;
        }
        #window {
        	margin: 0px 5px 0px 5px;
        	padding-left: 10px;
        	padding-right: 10px;
        	background-color: @base;
        	color: @text;
        }
        window#waybar.empty #window {
        	background-color: transparent;
        	border-bottom: none;
        	border-right: none;
        }
        window#waybar {
          background-color:@base;
          color: @text;
        }
        /* Workspaces */
        #workspaces {
          margin: 0px 0px 0px 0px;
          padding: 0px;
          background-color: @base;
          color: @rosewater;
        }
        #workspaces button {
          margin: 0px 0px 0px 0px;
          padding-left: 0px;
          padding-right: 0px;
          background-color: @base;
          color: @text;
        }
        #workspaces button.active {
            padding: 0 0px 0 0px;
            color: @base;
            background-color: @sapphire;
        }
        #workspaces button.urgent {
        	color: @red;
        }
        #custom-gpu-util {
          margin: 0px 5px 0px 5px;
          padding-left: 10px;
          padding-right: 10px;
          background-color: @base;
          color: @text;
        }
        #tray {
          margin: 0px 0px 0px 0px;
          padding-left: 4px;
          padding-right: 4px;
          background-color: @base;
          color: @rosewater;
        }
        #idle_inhibitor {
          margin: 1px 10px 0px 10px;
          padding-left: 4px;
          padding-right: 4px;
          background-color: @base;
          color: @red;
        }
        #idle_inhibitor.activated {
          color: @green;
        }
        #network {
          margin: 0px 0px 0px 0px;
          padding-left: 0px;
          padding-right: 0px;
          background-color: @base;
          color: @rosewater;
        }
        #network.linked {
          color: @green;
        }
        #network.disconnected,
        #network.disabled {
          color: @red;
        }
        #custom-cliphist {
        	color: @rosewater;
        	margin: 0px 0px 0px 0px;
            padding-left: 0px;
            padding-right: 0px;
            background-color: @base;

        }
        #custom-gpu-temp,
        #custom-clipboard {
          margin: 0px 0px 0px 5px;
          padding-left: 0px;
          padding-right: 0px;
          color: @text;
          background-color: @base;
        }
        #cpu {
          margin: 0px 0px 0px 0px;
          padding-left: 0px;
          padding-right: 4px;
          color: @text;
          background-color: @base;
        }
        #custom-cpuicon {
          margin: 0px 0px 0px 0px;
          padding: 0px 10px 0px 0px;
          color: @maroon;
          background-color: @base;
        }
        #custom-diskicon {
          margin: 0px 0px 0px 0px;
          padding: 0px 6px 0px 10px;
          color: @green;
          background-color: @base;
        }
        #disk {
          margin: 0px 0px 0px 0;
          padding-left: 2px;
          padding-right: 0px;
          color: @text;
          background-color: @base;
        }
        #custom-notification {
        background-color: @base;
        color: @yellow;
        padding: 3px 4px 0px 4px;
        margin-right: 0px;
        font-size: 14px;
        font-family: "JetBrainsMono Nerd Font";
        }
        #custom-memoryicon {
          margin: 0px 4px 0px 2px;
          color: @mauve;
          padding: 0 0px 0 0px;
          background-color: @base;
        }
        #memory {
          margin: 0px 0px 0px 0px;
          padding-left: 5px;
          padding-right: 10px;
          color: @text;
          background-color: @base;
        }
        #custom-tempicon {
          margin: 0px 0px 0px 0px;
          color: @red;
          padding: 0px 4px 0px 2px;
          background-color: @base;
        }
        #temperature {
          margin: 0px 0px 0px 0px;
          padding-left: 0px;
          padding-right: 0px;
          color: @text;
          background-color: @base;
        }
        #custom-playerctl {
          margin: 0px 0px 0px 0px;
          padding-left: 0px;
          padding-right: 0px;
          color: @text;
          background-color: @base;
        }
        #battery,
        #backlight,
        #bluetooth,
        #pulseaudio {
        	margin-right: 0px;
        	margin-left: 0px;
        	padding-left: 4px;
          	padding-right: 4px;
              color: @flamingo;
              background-color: @base;
        }
        #battery,
        #bluetooth {
        	margin-left: 0px;
        	margin-right: 0px;
        	padding-left: 0px;
        	padding-right: 0px;
              color: @blue;
              background-color: @base;
        }
        #clock {
          margin: 0px 0px 0px 0px;
          padding-left: 4px;
          padding-right: 4px;
          color: @peach;
          background-color: @base;
        }
        #custom-clockicon {
          margin: 0px 0px 0px 0px;
          color: @maroon;
          padding: 0px 4px 0px 4px;
          background-color: @base;
          color: @peach;
        }
        #taskbar {
            padding: 0px 0px 0px 0px;
            margin: 0 0px;
            padding-left: 4px;
            padding-right: 0px;
            color: @text;
            background-color: @base;
        }
        #taskbar button {
            padding: 0px 10px 0px 4px;
            margin: 0px 0px;
            padding-left: 0px;
            padding-right: 4px;
            color: @text;
            background-color: @surface0;
        }
        #taskbar button.active {
            padding-left: 10px;
            padding-right: 0px;
            background-color: @sapphire;
            color: @base;
        }
        #mode {
          margin: 0px 0px 0px 0px;
          padding-left: 0px;
          padding-right: 0px;
          background-color: @base;
          color: @green;
        }
        #custom-apps {
          margin: 0px 0px 0px 0px;
          padding-left: 10px;
          padding-right: 10px;
          background-color: @base;
          color: @text;
        }
        #custom-windowicon {
        margin: 0px 0px 0px 0px;
        padding: 3px 4px 0px 4px;
        background-color: @base;
        color: @sapphire;
        }

      '';
    };
    ashell.settings = lib.mkIf config.programs.ashell.enable {
      appearance = {
        style = "Gradient";  # "Islands"
        font_name = Sans;
      };
      primary_color = Base;
      success_color = Green;
      text_color = Text;
      workspace_colors = [ Overlay2 Text ];
      special_workspace_colors = [ Sapphire Rosewater ];
      appearance.danger_color = {
        base = Base;
        weak = Subtext0;
      };
      appearance.background_color = {
        base = Base;
        weak = Subtext1;
        strong = Mantle;
      };
      appearance.secondary_color = {
      base = Overlay2;
      };
    };
    television = lib.mkIf config.programs.television.enable {
      settings = {
        ui.theme = tv-theme;
        previewers.file.theme = tv-preview;
      };
    };
    starship = lib.mkIf config.programs.starship.enable {
      settings = {
        format = lib.concatStrings [
         "[](${starship1})"
         "$python"
         "$username"
         "[](bg:${starship2} fg:${starship1})"
         "$directory"
         "[](fg:${starship2} bg:${starship3})"
         "$git_branch"
         "$git_status"
         "[](fg:${starship3} bg:${starship4})"
         "$c"
         "$elixir"
         "$elm"
         "$golang"
         "$haskell"
         "$java"
         "$julia"
         "$nodejs"
         "$nim"
         "$rust"
         "[](fg:${starship4} bg:${starship5})"
         "$docker_context"
         "[](fg:${starship5} bg:${starship6})"
         "$time"
         "[ ](fg:${starship6})"
         ];
        command_timeout = 5000;
        username = {
         show_always = true;
         style_user = "bg:${starship1}";
         style_root = "bg:${starship1}";
         format = "[$user ]($style)";
        };
        directory = {
         style = "bg:${starship2}";
         format = "[ $path ]($style)";
         truncation_length = 3;
         truncation_symbol = "…/";
        };
        directory.substitutions = {
         "Documents" = "󰈙 ";
         "Downloads" = " ";
         "Music" = " ";
         "Pictures" = " ";
        };
        time = {
         disabled = false;
         time_format = "%R"; # Hour:Minute Format
         style = "bg:${starship6}";
         format ="[ $time ]($style)";
        };
        c = {
         symbol = " ";
         style = "bg:${starship4}";
         format = "[ $symbol ($version) ]($style)";
        };
        docker_context = {
         symbol = " ";
         style = "bg:${starship5}";
         format = "[ $symbol $context ]($style)$path";
        };
        elixir = {
         symbol = " ";
         style = "bg:${starship4}";
         format = "[ $symbol ($version) ]($style)";
        };
        elm = {
         symbol = " ";
         style = "bg:${starship4}";
         format = "[ $symbol ($version) ]($style)";
        };
        git_branch = {
         symbol = "";
         style = "bg:${starship3}";
         format = "[ $symbol $branch ]($style)";
        };
        git_status = {
         style = "bg:${starship3}";
         format = "[$all_status$ahead_behind ]($style)";
        };
        golang = {
         symbol = " ";
         style = "bg:${starship4}";
         format = "[ $symbol ($version) ]($style)";
        };
        haskell = {
         symbol = " ";
         style = "bg:${starship4}";
         format = "[ $symbol ($version) ]($style)";
        };
        java = {
         symbol = " ";
         style = "bg:${starship4}";
         format = "[ $symbol ($version) ]($style)";
        };
        julia = {
         symbol = " ";
         style = "bg:${starship4}";
         format = "[ $symbol ($version) ]($style)";
        };
        nodejs = {
         symbol = "";
         style = "bg:${starship4}";
         format = "[ $symbol ($version) ]($style)";
        };
        nim = {
         symbol = " ";
         style = "bg:${starship4}";
         format = "[ $symbol ($version) ]($style)";
        };
        python = {
         style = "bg:${starship1}";
         format = "[(\($virtualenv\) )]($style)";
        };
        rust = {
         symbol = "";
         style = "bg:${starship4}";
         format = "[ $symbol ($version) ]($style)";
        };
       #character = {
       #  format = lib.concatStrings [
       #    "[](bg:${starship1} fg:${starship1})"
       #    "[](bg:${starship1} fg:${starship1})"
       #    "[](bg:${starship1} fg:${starship1})"
       #  ];
       #};
        custom.character2 = {
          command = "";
          format = "[](fg:${starship6})";
          when = true;
          style = "fg:${starship6}";
        };
        custom.character3 = {
          command = "";
          when = true;
          format = "[ ](fg:${starship6})";
          style = "fg:${starship6}";
        };
        custom.character4 = {
          command = "";
          format = "[ ](fg:${starship2})";
          when = true;
          style = "fg:${starship2}";
        };
        custom.character5 = {
          command = "";
          format = "[](fg:${starship2})";
          when = true;
          style = "fg:${starship2}";
        };
      };
    };
    bat = lib.mkIf config.programs.bat.enable {
      config.theme = bat-theme;
      themes = {
        "${bat-theme}" = {
          src = bat-source;
         #file = "${bat-theme}.tmTheme";
        };
      };
    };
    btop = lib.mkIf config.programs.btop.enable {
      settings = {
        color_theme = "${btop-theme}.theme";
      };
      themes = {
        "${btop-theme}" = ''
          # Main background, empty for terminal default, need to be empty if you want transparent background
          theme[main_bg]="${Base}"
          # Main text color
          theme[main_fg]="${Text}"
          # Title color for boxes
          theme[title]="${Text}"
          # Highlight color for keyboard shortcuts
          theme[hi_fg]="${Blue}"
          # Background color of selected item in processes box
          theme[selected_bg]="${Surface1}"
          # Foreground color of selected item in processes box
          theme[selected_fg]="${Blue}"
          # Color of inactive/disabled text
          theme[inactive_fg]="${Overlay1}"
          # Color of text appearing on top of graphs, i.e uptime and current network graph scaling
          theme[graph_text]="${Rosewater}"
          # Background color of the percentage meters
          theme[meter_bg]="${Surface1}"
          # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
          theme[proc_misc]="${Rosewater}"
          # CPU, Memory, Network, Proc box outline colors
          theme[cpu_box]="${Mauve}" #Mauve
          theme[mem_box]="${Green}" #Green
          theme[net_box]="${Maroon}" #Maroon
          theme[proc_box]="${Blue}" #Blue
          # Box divider line and small boxes line color
          theme[div_line]="${Overlay0}"
          # Temperature graph color (Green -> Yellow -> Red)
          theme[temp_start]="${Green}"
          theme[temp_mid]="${Yellow}"
          theme[temp_end]="${Red}"
          # CPU graph colors (Teal -> Lavender)
          theme[cpu_start]="${Teal}"
          theme[cpu_mid]="${Sapphire}"
          theme[cpu_end]="${Lavender}"
          # Mem/Disk free meter (Mauve -> Lavender -> Blue)
          theme[free_start]="${Mauve}"
          theme[free_mid]="${Lavender}"
          theme[free_end]="${Blue}"
          # Mem/Disk cached meter (Sapphire -> Lavender)
          theme[cached_start]="${Sapphire}"
          theme[cached_mid]="${Blue}"
          theme[cached_end]="${Lavender}"
          # Mem/Disk available meter (Peach -> Red)
          theme[available_start]="${Peach}"
          theme[available_mid]="${Maroon}"
          theme[available_end]="${Red}"
          # Mem/Disk used meter (Green -> Sky)
          theme[used_start]="${Green}"
          theme[used_mid]="${Teal}"
          theme[used_end]="${Sky}"
          # Download graph colors (Peach -> Red)
          theme[download_start]="${Peach}"
          theme[download_mid]="${Maroon}"
          theme[download_end]="${Red}"
          # Upload graph colors (Green -> Sky)
          theme[upload_start]="${Green}"
          theme[upload_mid]="${Teal}"
          theme[upload_end]="${Sky}"
          # Process box color gradient for threads, mem and cpu usage (Sapphire -> Mauve)
          theme[process_start]="${Sapphire}"
          theme[process_mid]="${Lavender}"
          theme[process_end]="${Mauve}"
        '';
      };
    };
    cava = lib.mkIf config.programs.cava.enable {
      settings = {
        color = {
          theme = cava-theme;
        };
      };
    };
    fzf = lib.mkIf config.programs.fzf.enable {
      colors = {
        bg = CBase;
        "bg+" = CSurface0;
        spinner = CRosewater;
        hl = CRed;
        fg = CText;
        header = CRed;
        info = CMauve;
        pointer = CRosewater;
        marker = CLavender;
        "fg+" = CText;
        prompt = CMauve;
        "hl+" = CRed;
        selected-bg = CSurface1;
        border = COverlay0;
        label = CText;
      };
    };
    gh-dash = lib.mkIf config.programs.gh-dash.enable {
      settings = {
        theme = {
          colors = {
            text = {
              primary = Text;
              secondary = Sapphire;
              inverted = Crust;
              faint = Subtext1;
              warning = Yellow;
              success = Green;
              error = Red;
            };
            background = {
              selected = Surface0;
            };
            border = {
              primary = Sapphire;
              secondary = Surface1;
              faint = Surface0;
            };
          };
        };
      };
    };
    mangohud = lib.mkIf config.programs.mangohud.enable {
      settings = {
        legacy_layout = "false";
        round_corners = 10;
        background_alpha = 0.8;
        background_color = Calt-Base;
        table_columns = 3;
        font_size = MangohudSize;
        text_color = Calt-Text;
        text_outline_color = Calt-Surface0;
        gpu_color = Calt-Green;
        gpu_load_color = "${Calt-Text},${Calt-Peach},${Calt-Red}";
        vram_color = Calt-Mauve;
        cpu_color = Calt-Blue;
        cpu_load_color = "${Calt-Text},${Calt-Peach},${Calt-Red}";
        ram_color = Calt-Pink;
        engine_color = Calt-Red;
        fps_color = "${Calt-Red},${Calt-Yellow},${Calt-Green}";
        fps_color_change = "${Calt-Red},${Calt-Yellow},${Calt-Green}";
        wine_color = Calt-Red;
        frametime_color = Calt-Green;
        media_player_color = Calt-Lavender;
        battery_color = Calt-Red;
        io_color = Calt-Pink;
      };
    };
    mpv = lib.mkIf config.programs.mpv.enable {
      config = {
        background-color = Base;
        osd-back-color = Crust;
        osd-border-color = Crust;
        osd-color = Text;
        osd-shadow-color = Base;
        "script-opts-append=stats-border_color" = alt-Mauve;
        "script-opts-append=stats-font_color" = alt-Pink;
        "script-opts-append=stats-plot_bg_border_color" = alt-Yellow;
        "script-opts-append=stats-plot_bg_color" = alt-Mauve;
        "script-opts-append=stats-plot_color" = alt-Yellow;
        "script-opts-append=uosc-color" = "foreground=${alt-Sapphire},foreground_text=${alt-Surface0},background=${alt-Base},background_text=${alt-Text},curtain=${alt-Mantle},success=${alt-Green},error=${alt-Red}";

      };
      scriptOpts = {
        uosc.color = "background=${alt-Base},background_text=${alt-Text},foreground=${alt-Text},foreground_text=${alt-Base},success=${alt-Green},error=${alt-Red}";
        modernz = {
          seekbarfg_color = Peach;
          seekbarbg_color = Sapphire;
          seekbar_cache_color = Sapphire;
          window_title_color = Blue;
          window_controls_color = Blue;

          title_color = Text;
          time_color = Text;
          chapter_title_color = Text;
          cache_info_color = Text;

          middle_buttons_color = Peach;
          side_buttons_color = Mauve;
          playpause_color = Green;
          hover_effect_color = Pink;
        };
      };
    };
    neovim = lib.mkIf config.programs.neovim.enable {
      plugins = [
        {
          plugin = nvim-package;
          config = nvim-config;
        }
      ];
    };
    sioyek.config = lib.mkIf config.programs.sioyek.enable {
      "background_color" = Base;
      "text_highlight_color" = Yellow;
      "visual_mark_color" = Overlay0;
      "search_highlight_color" = Yellow;
      "link_highlight_color" = Blue;
      "synctex_highlight_color" = Green;
      "highlight_color_a" = Yellow;
      "highlight_color_b" = Green;
      "highlight_color_c" = Sky;
      "highlight_color_d" = Maroon;
      "highlight_color_e" = Mauve;
      "highlight_color_f" = Red;
      "highlight_color_g" = Yellow;
      "custom_background_color" = Base;
      "custom_text_color" = Text;
      "ui_text_color" = Text;
      "ui_background_color" = Surface0;
      "ui_selected_text_color" = Text;
      "ui_selected_background_color" = Surface2;
      "status_bar_color" = Surface0;
      "status_bar_text_color" = Text;
    };
    swaylock.settings = lib.mkIf config.programs.swaylock.enable {
      bs-hl-color = alt-Rosewater;
      caps-lock-bs-hl-color = alt-Rosewater;
      caps-lock-key-hl-color = alt-Green;
      color = alt-Base;
      inside-caps-lock-color = alt-Black-Transparent;
      inside-clear-color = alt-Black-Transparent;
      inside-color = alt-Black-Transparent;
      inside-ver-color = alt-Black-Transparent;
      inside-wrong-color = alt-Black-Transparent;
      key-hl-color = alt-Green;
      layout-bg-color = alt-Black-Transparent;
      layout-border-color = alt-Black-Transparent;
      layout-text-color = alt-Text;
      line-caps-lock-color = alt-Black-Transparent;
      line-clear-color = alt-Black-Transparent;
      line-color = alt-Black-Transparent;
      line-ver-color = alt-Black-Transparent;
      line-wrong-color = alt-Black-Transparent;
      ring-caps-lock-color = alt-Peach;
      ring-clear-color = alt-Rosewater;
      ring-color = alt-Lavender;
      ring-ver-color = alt-Blue;
      ring-wrong-color = alt-Maroon;
      separator-color = alt-Black-Transparent;
      text-caps-lock-color = alt-Peach;
      text-clear-color = alt-Rosewater;
      text-color = alt-Text;
      text-ver-color = alt-Blue;
      text-wrong-color = alt-Maroon;
    };

    qutebrowser.settings = {
      hints.border = "1px solid ${Base}";
      colors = {
        completion = {
          category = { bg = Base; fg = Green; border = { bottom = Mantle; top = Overlay2; }; };
          even.bg = Mantle;
          fg = Subtext0;
          item.selected = { bg = Surface2; border = { bottom = Surface2; top = Surface2; }; fg = Text; match.fg = Rosewater; };
          match.fg = Text;
          odd.bg = Crust;
          scrollbar = { bg = Crust; fg = Surface2; };
        };
        contextmenu = {
          disabled = { bg = Mantle; fg = Overlay0; };
          menu = { bg = Base; fg = Text; };
          selected = { bg = Overlay0; fg = Rosewater; }; };
        downloads = {
          bar.bg = Base;
          error = { bg = Base; fg = Red; };
          start = { bg = Base; fg = Blue; };
          stop = { bg = Base; fg = Green; }; };
        hints = { bg = Peach; fg = Mantle; match.fg = Subtext1; /*border = "1px solid ${Mantle}";*/ };
        keyhint = { bg = Mantle; fg = Text; suffix.fg = Subtext1; };
        messages = {
          error = { bg = Overlay0; fg = Red; border = Mantle; };
          info = { bg = Overlay0; fg = Text; border = Mantle; };
          warning = { bg = Overlay0; fg = Peach; border = Mantle; };
        };
        prompts = { bg = Mantle; border = "1px solid ${Overlay0}"; fg = Text; selected.bg = Surface2; selected.fg = Rosewater; };
        statusbar = {
          caret = { bg = Base; fg = Peach; selection = { bg = Base; fg = Peach; }; };
          command = { bg = Base; fg = Text; private = { bg = Base; fg = Subtext1; }; };
          insert = { bg = Crust; fg = Rosewater; };
          normal = { bg = Base; fg = Text; };
          passthrough = { bg = Base; fg = Peach; };
          private = { bg = Mantle; fg = Subtext1; };
          progress.bg = Base;
          url = { error.fg = Red; fg = Text; hover.fg = Sky; success = { http.fg = Green; https.fg = Text; }; warn.fg = Yellow; };
        };
        tabs = {
          bar.bg = Crust;
          even = { bg = Surface2; fg = Overlay2; };
          indicator = { error = Red; start = Sapphire; stop = Text; };
          odd = { bg = Surface1; fg = Overlay2; };
          pinned = { even = { bg = Sapphire; fg = Base; }; odd = { bg = Sky; fg = Crust; };
            selected = { even = { bg = Crust; fg = Overlay0; }; odd = { bg = Mantle; fg = Text; }; }; };
          selected = { even = { bg = Base; fg = Text; }; odd = { bg = Base; fg = Text; }; };
        };
        tooltip = { bg = Crust; fg = Rosewater; };
      };
    };
    yazi.theme = {
      mgr = {
        cwd = { fg = Teal; };
        hovered = { fg = Base; bg = Sapphire; };
        preview_hovered = { fg = Base; bg = Text; };
        find_keyword = { fg = Yellow; italic = true; };
        find_position = { fg = Pink; bg = "reset"; italic = true; };
        marker_copied = { fg = Green; bg = Green; };
        marker_cut = { fg = Red; bg = Red; };
        marker_marked = { fg = Teal; bg = Teal; };
        marker_selected = { fg = Sapphire; bg = Sapphire; };
        count_copied = { fg = Base; bg = Green; };
        count_cut = { fg = Base; bg = Red; };
        count_selected = { fg = Base; bg = Sapphire; };
        border_symbol = "│";
        border_style = { fg = Overlay1; };
        syntect_theme = "${nix-path}/modules/hm/theme/bat-themes/${yazi-bat}.tmTheme";
      };
      tabs = { active = { fg = Base; bg = Text; bold = true; }; inactive = { fg = Text; bg = Surface1; }; };
      mode = {
        normal_main = { fg = Base; bg = Sapphire; bold = true; };
        normal_alt = { fg = Sapphire; bg = Surface0; };
        select_main = { fg = Base; bg = Green; bold = true; };
        select_alt = { fg = Green; bg = Surface0; };
        unset_main = { fg = Base; bg = Flamingo; bold = true; };
        unset_alt = { fg = Flamingo; bg = Surface0; };
      };
      status = {
        sep_left = { open = ""; close = ""; };
        sep_right = { open = ""; close = ""; };
        progress_label  = { fg = "#ffffff"; bold = true; };
        progress_normal = { fg = Blue; bg = Surface1; };
        progress_error  = { fg = Red; bg = Surface1; };
        perm_type = { fg = Blue; };
        perm_read = { fg = Yellow; };
        perm_write = { fg = Red; };
        perm_exec = { fg = Green; };
        perm_sep = { fg = Overlay1; };
      };
      input = { border = { fg = Sapphire; }; title = {}; value = {}; selected = { reversed = true; }; };
      pick = { border = { fg = Sapphire; }; active = { fg = Pink; }; inactive = {}; };
      confirm = {
        border = { fg = Sapphire; };
        title = { fg = Sapphire; };
        content = {};
        list = {};
        btn_yes = { reversed = true; };
        btn_no = {};
      };
      cmp = { border = { fg = Sapphire; }; };
      tasks = { border = { fg = Sapphire; }; title = {}; hovered = { underline = true; }; };
      which = {
      mask = { bg = Surface0; };
      cand = { fg = Teal; };
      rest = { fg = Overlay2; };
      desc = { fg = Pink; };
      separator = "  ";
      separator_style = { fg = Surface2; };
      };
      help = {
      on = { fg = Teal; };
      run = { fg = Pink; };
      desc = { fg = Overlay2; };
      hovered = { bg = Surface2; bold = true; };
      footer = { fg = Text; bg = Surface1; };
      };
      notify = {
        title_info = { fg = Teal; };
        title_warn = { fg = Yellow; };
        title_error = { fg = Red; };
      };
      filetype = {
        rules = [
          # Media
          { mime = "image/*"; fg = Teal; }
          { mime = "{audio,video}/*"; fg = Yellow; }
          # Archives
          { mime = "application/*zip"; fg = Pink; }
          { mime = "application/x-{tar,bzip*,7z-compressed,xz,rar}"; fg = Pink; }
          # Documents
          { mime = "application/{pdf,doc,rtf}"; fg = Green; }
          # Fallback
          { name = "*"; fg = Text; }
          { name = "*/"; fg = Sapphire; }
        ];
      };
      spot = {
        border = { fg = Sapphire; };
        title = { fg = Sapphire; };
        tbl_cell = { fg = Sapphire; reversed = true; };
        tbl_col = { bold = true; };
      };
      icon = {
        files = let m = name: text: fg: { inherit name text fg; }; in [
          (m "kritadisplayrc" "" Mauve) (m ".gtkrc-2.0" "" Rosewater) (m "bspwmrc" "" Mantle) (m "webpack" "󰜫" Sapphire) (m "tsconfig.json" "" Sapphire)
          (m ".vimrc" "" Green) (m "gemfile$" "" Crust) (m "xmobarrc" "" Red) (m "avif" "" Overlay1)
          (m "fp-info-cache" "" Rosewater) (m ".zshrc" "" Green) (m "robots.txt" "󰚩" Overlay0) (m "dockerfile" "󰡨" Blue)
          (m ".git-blame-ignore-revs" "" Peach) (m ".nvmrc" "" Green) (m "hyprpaper.conf" "" Teal) (m ".prettierignore" "" Blue)
          (m "rakefile" "" Crust) (m "code_of_conduct" "" Red) (m "cmakelists.txt" "" Text) (m ".env" "" Yellow)
          (m "copying.lesser" "" Yellow) (m "readme" "󰂺" Rosewater) (m "settings.gradle" "" Surface2) (m "gruntfile.coffee" "" Peach)
          (m ".eslintignore" "" Surface1) (m "kalgebrarc" "" Blue) (m "kdenliverc" "" Blue) (m ".prettierrc.cjs" "" Blue)
          (m "cantorrc" "" Blue) (m "rmd" "" Sapphire) (m "vagrantfile$" "" Overlay0) (m ".Xauthority" "" Peach)
          (m "prettier.config.ts" "" Blue) (m "node_modules" "" Red) (m ".prettierrc.toml" "" Blue) (m "build.zig.zon" "" Peach)
          (m ".ds_store" "" Surface1) (m "PKGBUILD" "" Blue) (m ".prettierrc" "" Blue) (m ".bash_profile" "" Green)
          (m ".npmignore" "" Red) (m ".mailmap" "󰊢" Peach) (m ".codespellrc" "󰓆" Green) (m "svelte.config.js" "" Peach)
          (m "eslint.config.ts" "" Surface1) (m "config" "" Overlay1) (m ".gitlab-ci.yml" "" Red) (m ".gitconfig" "" Peach)
          (m "_gvimrc" "" Green) (m ".xinitrc" "" Peach) (m "checkhealth" "󰓙" Blue) (m "sxhkdrc" "" Mantle)
          (m ".bashrc" "" Green) (m "tailwind.config.mjs" "󱏿" Sapphire) (m "ext_typoscript_setup.txt" "" Peach) (m "commitlint.config.ts" "󰜘" Teal)
          (m "py.typed" "" Yellow) (m ".nanorc" "" Base) (m "commit_editmsg" "" Peach) (m ".luaurc" "" Blue)
          (m "fp-lib-table" "" Rosewater) (m ".editorconfig" "" Rosewater) (m "justfile" "" Overlay1) (m "kdeglobals" "" Blue)
          (m "license.md" "" Yellow) (m ".clang-format" "" Overlay1) (m "docker-compose.yaml" "󰡨" Blue) (m "copying" "" Yellow)
          (m "go.mod" "" Sapphire) (m "lxqt.conf" "" Blue) (m "brewfile" "" Crust) (m "gulpfile.coffee" "" Red)
          (m ".dockerignore" "󰡨" Blue) (m ".settings.json" "" Surface2) (m "tailwind.config.js" "󱏿" Sapphire) (m ".clang-tidy" "" Overlay1)
          (m ".gvimrc" "" Green) (m "nuxt.config.cjs" "󱄆" Teal) (m "xsettingsd.conf" "" Peach) (m "nuxt.config.js" "󱄆" Teal)
          (m "eslint.config.cjs" "" Surface1) (m "sym-lib-table" "" Rosewater) (m ".condarc" "" Green) (m "xmonad.hs" "" Red)
          (m "tmux.conf" "" Green) (m "xmobarrc.hs" "" Red) (m ".prettierrc.yaml" "" Blue) (m ".pre-commit-config.yaml" "󰛢" Yellow)
          (m "i3blocks.conf" "" Text) (m "xorg.conf" "" Peach) (m ".zshenv" "" Green) (m "vlcrc" "󰕼" Peach)
          (m "license" "" Yellow) (m "unlicense" "" Yellow) (m "tmux.conf.local" "" Green) (m ".SRCINFO" "󰣇" Blue)
          (m "tailwind.config.ts" "󱏿" Sapphire) (m "security.md" "󰒃" Subtext1) (m "security" "󰒃" Subtext1) (m ".eslintrc" "" Surface1)
          (m "gradle.properties" "" Surface2) (m "code_of_conduct.md" "" Red) (m "PrusaSlicerGcodeViewer.ini" "" Peach) (m "PrusaSlicer.ini" "" Peach)
          (m "procfile" "" Overlay1) (m "mpv.conf" "" Base) (m ".prettierrc.json5" "" Blue) (m "i3status.conf" "" Text)
          (m "prettier.config.mjs" "" Blue) (m ".pylintrc" "" Overlay1) (m "prettier.config.cjs" "" Blue) (m ".luacheckrc" "" Blue)
          (m "containerfile" "󰡨" Blue) (m "eslint.config.mjs" "" Surface1) (m "gruntfile.js" "" Peach) (m "bun.lockb" "" Rosewater)
          (m ".gitattributes" "" Peach) (m "gruntfile.ts" "" Peach) (m "pom.xml" "" Surface0) (m "favicon.ico" "" Yellow)
          (m "package-lock.json" "" Surface0) (m "build" "" Green) (m "package.json" "" Red) (m "nuxt.config.ts" "󱄆" Teal)
          (m "nuxt.config.mjs" "󱄆" Teal) (m "mix.lock" "" Overlay1) (m "makefile" "" Overlay1) (m "gulpfile.js" "" Red)
          (m "lxde-rc.xml" "" Overlay1) (m "kritarc" "" Mauve) (m "gtkrc" "" Rosewater) (m "ionic.config.json" "" Blue)
          (m ".prettierrc.mjs" "" Blue) (m ".prettierrc.yml" "" Blue) (m ".npmrc" "" Red) (m "weston.ini" "" Yellow)
          (m "gulpfile.babel.js" "" Red) (m "i18n.config.ts" "󰗊" Overlay1) (m "commitlint.config.js" "󰜘" Teal) (m ".gitmodules" "" Peach)
          (m "gradle-wrapper.properties" "" Surface2) (m "hypridle.conf" "" Teal) (m "vercel.json" "▲" Rosewater) (m "hyprlock.conf" "" Teal)
          (m "go.sum" "" Sapphire) (m "kdenlive-layoutsrc" "" Blue) (m "gruntfile.babel.js" "" Peach) (m "compose.yml" "󰡨" Blue)
          (m "i18n.config.js" "󰗊" Overlay1) (m "readme.md" "󰂺" Rosewater) (m "gradlew" "" Surface2) (m "go.work" "" Sapphire)
          (m "gulpfile.ts" "" Red) (m "gnumakefile" "" Overlay1) (m "FreeCAD.conf" "" Red) (m "compose.yaml" "󰡨" Blue)
          (m "eslint.config.js" "" Surface1) (m "hyprland.conf" "" Teal) (m "docker-compose.yml" "󰡨" Blue) (m "groovy" "" Surface2)
          (m "QtProject.conf" "" Green) (m "platformio.ini" "" Peach) (m "build.gradle" "" Surface2) (m ".nuxtrc" "󱄆" Teal)
          (m "_vimrc" "" Green) (m ".zprofile" "" Green) (m ".xsession" "" Peach) (m "prettier.config.js" "" Blue)
          (m ".babelrc" "" Yellow) (m "workspace" "" Green) (m ".prettierrc.json" "" Blue) (m ".prettierrc.js" "" Blue)
          (m ".Xresources" "" Peach) (m ".gitignore" "" Peach) (m ".justfile" "" Overlay1)
        ];
        exts = let m = name: text: fg: { inherit name text fg; }; in [
          (m "otf" "" Rosewater) (m "import" "" Rosewater) (m "krz" "" Mauve) (m "adb" "" Teal) (m "ttf" "" Rosewater) (m "webpack" "󰜫" Sapphire) (m "dart" "" Surface2) (m "vsh" "" Overlay1) (m "doc" "󰈬" Surface2) (m "zsh" "" Green) (m "ex" "" Overlay1) (m "hx" "" Peach) (m "fodt" "" Sapphire) (m "mojo" "" Peach) (m "templ" "" Yellow) (m "nix" "" Sapphire) (m "cshtml" "󱦗" Surface1) (m "fish" "" Surface2) (m "ply" "󰆧" Overlay1) (m "sldprt" "󰻫" Green) (m "gemspec" "" Crust) (m "mjs" "" Yellow) (m "csh" "" Surface2) (m "cmake" "" Text) (m "fodp" "" Peach) (m "vi" "" Yellow) (m "msf" "" Blue) (m "blp" "󰺾" Blue) (m "less" "" Surface1) (m "sh" "" Surface2) (m "odg" "" Yellow) (m "mint" "󰌪" Green) (m "dll" "" Crust) (m "odf" "" Red) (m "sqlite3" "" Rosewater) (m "Dockerfile" "󰡨" Blue) (m "ksh" "" Surface2) (m "rmd" "" Sapphire) (m "wv" "" Sapphire) (m "xml" "󰗀" Peach) (m "markdown" "" Text) (m "qml" "" Green) (m "3gp" "" Peach) (m "pxi" "" Blue) (m "flac" "" Overlay0) (m "gpr" "" Mauve) (m "huff" "󰡘" Surface1) (m "json" "" Yellow) (m "gv" "󱁉" Surface2) (m "bmp" "" Overlay1) (m "lock" "" Subtext1) (m "sha384" "󰕥" Overlay1) (m "cobol" "⚙" Surface2) (m "cob" "⚙" Surface2) (m "java" "" Red) (m "cjs" "" Yellow) (m "qm" "" Sapphire) (m "ebuild" "" Surface1) (m "mustache" "" Peach) (m "terminal" "" Green) (m "ejs" "" Yellow) (m "brep" "󰻫" Green) (m "rar" "" Yellow) (m "gradle" "" Surface2) (m "gnumakefile" "" Overlay1) (m "applescript" "" Overlay1) (m "elm" "" Sapphire) (m "ebook" "" Peach) (m "kra" "" Mauve) (m "tf" "" Surface2) (m "xls" "󰈛" Surface2) (m "fnl" "" Yellow) (m "kdbx" "" Green) (m "kicad_pcb" "" Rosewater) (m "cfg" "" Overlay1) (m "ape" "" Sapphire) (m "org" "" Teal) (m "yml" "" Overlay1) (m "swift" "" Peach) (m "eln" "" Overlay0) (m "sol" "" Sapphire) (m "awk" "" Surface2) (m "7z" "" Yellow) (m "apl" "⍝" Peach) (m "epp" "" Peach) (m "app" "" Surface1) (m "dot" "󱁉" Surface2) (m "kpp" "" Mauve) (m "eot" "" Rosewater) (m "hpp" "" Overlay1) (m "spec.tsx" "" Surface2) (m "hurl" "" Red) (m "cxxm" "" Sapphire) (m "c" "" Blue) (m "fcmacro" "" Red) (m "sass" "" Red) (m "yaml" "" Overlay1) (m "xz" "" Yellow) (m "material" "󰔉" Overlay0) (m "json5" "" Yellow) (m "signature" "λ" Peach) (m "3mf" "󰆧" Overlay1) (m "jpg" "" Overlay1) (m "xpi" "" Peach) (m "fcmat" "" Red) (m "pot" "" Sapphire) (m "bin" "" Surface1) (m "xlsx" "󰈛" Surface2) (m "aac" "" Sapphire) (m "kicad_sym" "" Rosewater) (m "xcstrings" "" Sapphire) (m "lff" "" Rosewater) (m "xcf" "" Surface2) (m "azcli" "" Overlay0) (m "license" "" Yellow) (m "jsonc" "" Yellow) (m "xaml" "󰙳" Surface1) (m "md5" "󰕥" Overlay1) (m "xm" "" Sapphire) (m "sln" "" Surface2) (m "jl" "" Overlay1) (m "ml" "" Peach) (m "http" "" Blue) (m "x" "" Blue) (m "wvc" "" Sapphire) (m "wrz" "󰆧" Overlay1) (m "csproj" "󰪮" Surface1) (m "wrl" "󰆧" Overlay1) (m "wma" "" Sapphire) (m "woff2" "" Rosewater) (m "woff" "" Rosewater) (m "tscn" "" Overlay1) (m "webmanifest" "" Yellow) (m "webm" "" Peach) (m "fcbak" "" Red) (m "log" "󰌱" Text) (m "wav" "" Sapphire) (m "wasm" "" Surface2) (m "styl" "" Green) (m "gif" "" Overlay1) (m "resi" "" Red) (m "aiff" "" Sapphire) (m "sha256" "󰕥" Overlay1) (m "igs" "󰻫" Green) (m "vsix" "" Surface2) (m "vim" "" Green) (m "diff" "" Surface1) (m "drl" "" Maroon) (m "erl" "" Overlay0) (m "vhdl" "󰍛" Green) (m "🔥" "" Peach) (m "hrl" "" Overlay0) (m "fsi" "" Sapphire) (m "mm" "" Sapphire) (m "bz" "" Yellow) (m "vh" "󰍛" Green) (m "kdb" "" Green) (m "gz" "" Yellow) (m "cpp" "" Sapphire) (m "ui" "" Surface2) (m "txt" "󰈙" Green) (m "spec.ts" "" Sapphire) (m "ccm" "" Red) (m "typoscript" "" Peach) (m "typ" "" Teal) (m "txz" "" Yellow) (m "test.ts" "" Sapphire) (m "tsx" "" Surface2) (m "mk" "" Overlay1) (m "webp" "" Overlay1) (m "opus" "" Overlay0) (m "bicep" "" Sapphire) (m "ts" "" Sapphire) (m "tres" "" Overlay1) (m "torrent" "" Teal) (m "cxx" "" Sapphire) (m "iso" "" Flamingo) (m "ixx" "" Sapphire) (m "hxx" "" Overlay1) (m "gql" "" Red) (m "tmux" "" Green) (m "ini" "" Overlay1) (m "m3u8" "󰲹" Red) (m "image" "" Flamingo) (m "tfvars" "" Surface2) (m "tex" "" Surface1) (m "cbl" "⚙" Surface2) (m "flc" "" Rosewater) (m "elc" "" Overlay0) (m "test.tsx" "" Surface2) (m "twig" "" Green) (m "sql" "" Rosewater) (m "test.jsx" "" Sapphire) (m "htm" "" Peach) (m "gcode" "󰐫" Overlay0) (m "test.js" "" Yellow) (m "ino" "" Sapphire) (m "tcl" "󰛓" Surface2) (m "cljs" "" Sapphire) (m "tsconfig" "" Peach) (m "img" "" Flamingo) (m "t" "" Sapphire) (m "fcstd1" "" Red) (m "out" "" Surface1) (m "jsx" "" Sapphire) (m "bash" "" Green) (m "edn" "" Sapphire) (m "rss" "" Peach) (m "flf" "" Rosewater) (m "cache" "" Rosewater) (m "sbt" "" Red) (m "cppm" "" Sapphire) (m "svelte" "" Peach) (m "mo" "∞" Overlay1) (m "sv" "󰍛" Green) (m "ko" "" Rosewater) (m "suo" "" Surface2) (m "sldasm" "󰻫" Green) (m "icalendar" "" Surface0) (m "go" "" Sapphire) (m "sublime" "" Peach) (m "stl" "󰆧" Overlay1) (m "mobi" "" Peach) (m "graphql" "" Red) (m "m3u" "󰲹" Red) (m "cpy" "⚙" Surface2) (m "kdenlive" "" Blue) (m "pyo" "" Yellow) (m "po" "" Sapphire) (m "scala" "" Red) (m "exs" "" Overlay1) (m "odp" "" Peach) (m "dump" "" Rosewater) (m "stp" "󰻫" Green) (m "step" "󰻫" Green) (m "ste" "󰻫" Green) (m "aif" "" Sapphire) (m "strings" "" Sapphire) (m "cp" "" Sapphire) (m "fsscript" "" Sapphire) (m "mli" "" Peach) (m "bak" "󰁯" Overlay1) (m "ssa" "󰨖" Yellow) (m "toml" "" Red) (m "makefile" "" Overlay1) (m "php" "" Overlay1) (m "zst" "" Yellow) (m "spec.jsx" "" Sapphire) (m "kbx" "󰯄" Overlay0) (m "fbx" "󰆧" Overlay1) (m "blend" "󰂫" Peach) (m "ifc" "󰻫" Green) (m "spec.js" "" Yellow) (m "so" "" Rosewater) (m "desktop" "" Surface1) (m "sml" "λ" Peach) (m "slvs" "󰻫" Green) (m "pp" "" Peach) (m "ps1" "󰨊" Overlay0) (m "dropbox" "" Overlay0) (m "kicad_mod" "" Rosewater) (m "bat" "" Green) (m "slim" "" Peach) (m "skp" "󰻫" Green) (m "css" "" Blue) (m "xul" "" Peach) (m "ige" "󰻫" Green) (m "glb" "" Peach) (m "ppt" "󰈧" Red) (m "sha512" "󰕥" Overlay1) (m "ics" "" Surface0) (m "mdx" "" Sapphire) (m "sha1" "󰕥" Overlay1) (m "f3d" "󰻫" Green) (m "ass" "󰨖" Yellow) (m "godot" "" Overlay1) (m "ifb" "" Surface0) (m "cson" "" Yellow) (m "lib" "" Crust) (m "luac" "" Sapphire) (m "heex" "" Overlay1) (m "scm" "󰘧" Rosewater) (m "psd1" "󰨊" Overlay0) (m "sc" "" Red) (m "scad" "" Yellow) (m "kts" "" Overlay0) (m "svh" "󰍛" Green) (m "mts" "" Sapphire) (m "nfo" "" Yellow) (m "pck" "" Overlay1) (m "rproj" "󰗆" Green) (m "rlib" "" Peach) (m "cljd" "" Sapphire) (m "ods" "" Green) (m "res" "" Red) (m "apk" "" Green) (m "haml" "" Rosewater) (m "d.ts" "" Peach) (m "razor" "󱦘" Surface1) (m "rake" "" Crust) (m "patch" "" Surface1) (m "cuh" "" Overlay1) (m "d" "" Red) (m "query" "" Green) (m "psb" "" Sapphire) (m "nu" ">" Green) (m "mov" "" Peach) (m "lrc" "󰨖" Yellow) (m "pyx" "" Blue) (m "pyw" "" Blue) (m "cu" "" Green) (m "bazel" "" Green) (m "obj" "󰆧" Overlay1) (m "pyi" "" Yellow) (m "pyd" "" Yellow) (m "exe" "" Surface1) (m "pyc" "" Yellow) (m "fctb" "" Red) (m "part" "" Teal) (m "blade.php" "" Red) (m "git" "" Peach) (m "psd" "" Sapphire) (m "qss" "" Green) (m "csv" "" Green) (m "psm1" "󰨊" Overlay0) (m "dconf" "" Rosewater) (m "config.ru" "" Crust) (m "prisma" "" Overlay0) (m "conf" "" Overlay1) (m "clj" "" Green) (m "o" "" Surface1) (m "mp4" "" Peach) (m "cc" "" Red) (m "kicad_prl" "" Rosewater) (m "bz3" "" Yellow) (m "asc" "󰦝" Surface2) (m "png" "" Overlay1) (m "android" "" Green) (m "pm" "" Sapphire) (m "h" "" Overlay1) (m "pls" "󰲹" Red) (m "ipynb" "" Peach) (m "pl" "" Sapphire) (m "ads" "" Rosewater) (m "sqlite" "" Rosewater) (m "pdf" "" Red) (m "pcm" "" Overlay0) (m "ico" "" Yellow) (m "a" "" Rosewater) (m "R" "󰟔" Surface2) (m "ogg" "" Overlay0) (m "pxd" "" Blue) (m "kdenlivetitle" "" Blue) (m "jxl" "" Overlay1) (m "nswag" "" Green) (m "nim" "" Yellow) (m "bqn" "⎉" Surface2) (m "cts" "" Sapphire) (m "fcparam" "" Red) (m "rs" "" Peach) (m "mpp" "" Sapphire) (m "fdmdownload" "" Teal) (m "pptx" "󰈧" Red) (m "jpeg" "" Overlay1) (m "bib" "󱉟" Yellow) (m "vhd" "󰍛" Green) (m "m" "" Blue) (m "js" "" Yellow) (m "eex" "" Overlay1) (m "tbc" "󰛓" Surface2) (m "astro" "" Red) (m "sha224" "󰕥" Overlay1) (m "xcplayground" "" Peach) (m "el" "" Overlay0) (m "m4v" "" Peach) (m "m4a" "" Sapphire) (m "cs" "󰌛" Green) (m "hs" "" Overlay1) (m "tgz" "" Yellow) (m "fs" "" Sapphire) (m "luau" "" Blue) (m "dxf" "󰻫" Green) (m "download" "" Teal) (m "cast" "" Peach) (m "qrc" "" Green) (m "lua" "" Sapphire) (m "lhs" "" Overlay1) (m "md" "" Text) (m "leex" "" Overlay1) (m "ai" "" Yellow) (m "lck" "" Subtext1) (m "kt" "" Overlay0) (m "bicepparam" "" Overlay1) (m "hex" "" Overlay0) (m "zig" "" Peach) (m "bzl" "" Green) (m "cljc" "" Green) (m "kicad_dru" "" Rosewater) (m "fctl" "" Red) (m "f#" "" Sapphire) (m "odt" "" Sapphire) (m "conda" "" Green) (m "vala" "" Surface2) (m "erb" "" Crust) (m "mp3" "" Sapphire) (m "bz2" "" Yellow) (m "coffee" "" Yellow) (m "cr" "" Rosewater) (m "f90" "󱈚" Surface2) (m "jwmrc" "" Overlay0) (m "c++" "" Red) (m "fcscript" "" Red) (m "fods" "" Green) (m "cue" "󰲹" Red) (m "srt" "󰨖" Yellow) (m "info" "" Yellow) (m "hh" "" Overlay1) (m "sig" "λ" Peach) (m "html" "" Peach) (m "iges" "󰻫" Green) (m "kicad_wks" "" Rosewater) (m "hbs" "" Peach) (m "fcstd" "" Red) (m "gresource" "" Rosewater) (m "sub" "󰨖" Yellow) (m "ical" "" Surface0) (m "crdownload" "" Teal) (m "pub" "󰷖" Yellow) (m "vue" "" Green) (m "gd" "" Overlay1) (m "fsx" "" Sapphire) (m "mkv" "" Peach) (m "py" "" Yellow) (m "kicad_sch" "" Rosewater) (m "epub" "" Peach) (m "env" "" Yellow) (m "magnet" "" Surface1) (m "elf" "" Surface1) (m "fodg" "" Yellow) (m "svg" "󰜡" Peach) (m "dwg" "󰻫" Green) (m "docx" "󰈬" Surface2) (m "pro" "" Yellow) (m "db" "" Rosewater) (m "rb" "" Crust) (m "r" "󰟔" Surface2) (m "scss" "" Red) (m "cow" "󰆚" Peach) (m "gleam" "" Pink) (m "v" "󰍛" Green) (m "kicad_pro" "" Rosewater) (m "liquid" "" Green) (m "zip" "" Yellow)
        ];
      };
    };

   #btop.settings = { color_theme = "catppuccin_macchiato.theme"; };
  };

  services = {
    polybar = lib.mkIf config.services.polybar.enable {
      settings = {
       #colors ={
       #  background = "#0d1117";
       #  background-alt = "#2f363d";
       #  foreground = "#d0d7de";
       #  primary = "#D29922";
       #  secondary = "#539bf5";
       #  alert = "#D29922";
       #  disabled = "#4e5b55";
       #  border = "#0f2923";
       #};
        "bar/example" = {
          background = Base;
          foreground = Text;
          line-size = "3pt";
          border-size = "4pt";
          border-color = Mantle;
          padding-left = 2;
          padding-right = 2;
          module-margin = 1;
          separator = "|";
          separator-foreground = Base;
          font-0 = Poly1;
          font-1 = PolySymbols;
          font-2 = Poly2;
         #font-1 = "FontAwesome:size=12;3";
         #font-2 = "Hack Nerd Font:size=12;3";
        };
        "module/xwindow" = {
          format-prefix-foreground = Sapphire;
        };
        "module/xworkspaces" = {
          label = {
            active = {
             #foreground = Base;
              foreground = Sapphire;
             #background = Sapphire;
              background = Base;
             #underline= Blue;
              underline= Base;
            };
            urgent.background = Red;
            empty.foreground = Mantle;
          };
        };
        "module/filesystem" = {
         #label-mounted = %{F#F0C674}%mountpoint%%{F-} %percentage_used%%;
          label-unmounted-foreground = Red;
          label-mounted-foreground = Lavender;
          format-mounted-foreground = Green;
          format-mounted-prefix-foreground = Green;
          format-prefix-foreground = Green;
          format-foreground = Green;
          format-prefix-mounted-foreground = Green;
        };
        "module/pulseaudio" = {
          format-volume-prefix-foreground = Flamingo;
          label-muted-foreground = Red;
        };
        "module/lock" = {
          format-foreground = Red;
          format-background = Base;
        };
        "module/memory" = {
          format-prefix-foreground = Mauve;
        };
        "module/cpu" = {
          format-prefix-foreground = Maroon;
        };
        "network-base" = {
         #label-disconnected = %{F#F0C674}%ifname%%{F#707880} disconnected;
        };
        "module/wlan" = {
         #label-connected = %{F#F0C674}%ifname%%{F-} %essid% %local_ip%;
        };
        "module/eth" = {
         #label-connected = %{F#F0C674}%ifname%%{F-} %local_ip%;
        };
        "module/hour" = {
          label-foreground = Peach; # Flamingo;
          format-prefix-foreground = Rosewater;
        };
        "module/date" = {
          label-foreground = Flamingo; # Peach;
          format-prefix-foreground = Rosewater;
        };
        "module/tray" = {
          tray-foreground = Text;
        };
        "module/idle" = {
          label-foreground = Green;
        };
        "module/networkspeedup" = {
          format-connected-prefix-foreground = Red;
         #label-connected-background = #FF0000
        };
        "module/networkspeeddown" = {
          format-connected-prefix-foreground = Blue;
         #label-connected-background = #FF0000
        };
        "module/networkspeedup-wired" = {
          format-connected-prefix-foreground = Red;
         #label-connected-background = #FF0000
        };
        "module/networkspeeddown-wired" = {
          format-connected-prefix-foreground = Blue;
         #label-connected-background = #FF0000
        };
        "module/notif" = {
          label-foreground = Yellow;
        };
        "module/bspwm" = {
          label-foreground = Sky;
        };
        "module/keyboard-layout" = {
          label-foreground = Teal;
        };
        "module/power" = {
          label-foreground = Red;
        };
        "module/apps" = {
          label-foreground = Sapphire;
        };
        "module/picom" = {
          label-foreground = Mauve;
        };
        "module/player" = {
          label-foreground = Overlay2;
          format-prefix-foreground = Mauve;
        };
        "module/pp" = {
          label-foreground = Rosewater;
        };
      };
    };

    dunst = lib.mkIf (config.services.dunst.enable) {
      settings = {
        global = {
         #icon_path = '' '';
          offset = "(27,60)";
          width = "(180, 600)";
          height = "(0, 750)";
          padding = 7;
          horizontal_padding = 7;
          gap_size = 5;
         #transparency = 15;
         #frame_width = 1;
         #frame_color = "#607566";
          font = dunstFont;
          corner_radius = 5;
          min_icon_size = 32;
          max_icon_size = 32;
          format = ''<b>%s</b>\n%b'';
        };
        urgency_low = {
         #foreground = Text;
         #background = Base;
         #frame_color = Green;
        };
        urgency_normal = {
         #foreground = Text;
         #background = Base;
         #frame_color = Sapphire;
        };
        urgency_critical = {
         #background = Red;
         #foreground = Crust;
         #frame_color = Yellow;
        };
      };
     #iconTheme = {
     #  package = ;
     #  name = ;
     #  size = ;
     #};
    };

  };

  home.file = {
    gtk = {
      source = "${gtk-package}/share/themes/${gtk-theme}";
      target = ".themes/${gtk-theme}";
      recursive = true;
    };
    gtk2 = {
      source = "${gtk2-package}/share/themes/${gtk-theme}";
      target = ".local/share/themes/${gtk-theme}";
      recursive = true;
    };

    wallpapers = {
      source = "${inputs.assets}/wallpapers/";
      target = "Pictures/Wallpapers";
     #recursive = true;
    };
    themed-wallpapers = {
      source = "${inputs.assets}/wallpapers/${config.my.theme}/";
      target = "Pictures/themed-wallpapers";
      recursive = true;
    };
    live-wallpapers = {
      source = "${inputs.assets}/live-wallpapers/";
      target = "Pictures/live-wallpapers";
      recursive = true;
    };

    face-icons = {
      source = "${inputs.assets}/icons/";
      target = "Pictures/icons/";
      recursive = true;
    };

   #faces = {
   #  source = "${inputs.assets}/icons/faces/";
   #  target = ".face/";
   #  recursive = true;
   #};

   #icons = {
   #  target = ".icons/${gtk-icon}/";
   #  source = "${pkgs.papirus-icon-theme}/share/icons/${gtk-icon}/";
   #  recursive = true;
   #};
    cursor-icon = {
      source = "${gtk-icon-package}/share/icons";
      target = ".icons/";
      recursive = true;
    };
    cursor-icon2 = {
      source = "${gtk-icon-package}/share/icons";
      target = ".local/share/icons/";
      recursive = true;
    };
    openbox = {  # Needs To Be Writable
      source = "${inputs.catppuccin-openbox}/themes/${openbox-theme}/openbox-3/";
      target = ".themes/${openbox-theme}/openbox-3/";
      recursive = true;
    };

  };

  xdg.configFile = {

    catppuccinifier = {
      target = "com.lighttigerxiv.catppuccinifier/settings.json";
      text = builtins.toJSON {
        "theme" = catppuccinifier-flav;
        "accent" = catppuccinifier-acc;
      };
    };
    catppuccinifier-gui = {
      target = "catppuccinifier.toml";
      source = (pkgs.formats.toml {}).generate "catppuccinifier.toml" {
        theme = catppuccinifier-flavC;
        accent = catppuccinifier-accC;
        show_titlebar = false;
      };
    };

   #"obs-studio/themes/${obs-theme}.obt".source = obs-obt-source;
   #"obs-studio/themes/${obs-theme-name}.ovt".source = obs-ovt-source;

    "television/themes/${tv-theme}.toml".text = ''
      # general
      background = '${Base}'
      border_fg = '${Surface1}'
      text_fg = '${Text}'
      dimmed_text_fg = '${Overlay0}'
      # input
      input_text_fg = '${Sapphire}'
      result_count_fg = '${Sapphire}'
      # results
      result_name_fg = '${Blue}'
      result_line_number_fg = '${Yellow}'
      result_value_fg = '${Lavender}'
      selection_fg = '${Green}'
      selection_bg = '${Surface0}'
      match_fg = '${Green}'
      # preview
      preview_title_fg = '${Sapphire}'
      # modes
      channel_mode_fg = '${Base}'
      channel_mode_bg = '${Sapphire}'
      remote_control_mode_fg = '${Base}'
      remote_control_mode_bg = '${Green}'
    '';

    Kvantum = {
      target = "Kvantum/kvantum.kvconfig";
      text = ''
        [General]
        theme=${kvantum-theme}
        icon_theme=${qt-icon}
      '';
    };

   #"Kvantum/${kvantum-theme}".source = "${config.catppuccin.sources.kvantum}/share/Kvantum/${kvantum-theme}";
    "Kvantum/${kvantum-theme}".source = "${kvantum-package}/share/Kvantum/${kvantum-theme}";

    "fish/themes/${fish-theme}.theme".text = ''
      # name: 'Catppuccin Macchiato'
      # url: 'https://github.com/catppuccin/fish'
      # preferred_background: ${alt-Base}

      fish_color_normal ${alt-Text}
      fish_color_command ${alt-Blue}
      fish_color_param ${alt-Flamingo}
      fish_color_keyword ${alt-Red}
      fish_color_quote ${alt-Green}
      fish_color_redirection ${alt-Pink}
      fish_color_end ${alt-Peach}
      fish_color_comment ${alt-Overlay1}
      fish_color_error ${alt-Red}
      fish_color_gray ${alt-Overlay0}
      fish_color_selection --background=${alt-Surface0}
      fish_color_search_match --background=${alt-Surface0}
      fish_color_option ${alt-Green}
      fish_color_operator ${alt-Pink}
      fish_color_escape ${alt-Maroon}
      fish_color_autosuggestion ${alt-Overlay0}
      fish_color_cancel ${alt-Red}
      fish_color_cwd ${alt-Yellow}
      fish_color_user ${alt-Teal}
      fish_color_host ${alt-Blue}
      fish_color_host_remote ${alt-Green}
      fish_color_status ${alt-Red}
      fish_pager_color_progress ${alt-Overlay0}
      fish_pager_color_prefix ${alt-Pink}
      fish_pager_color_completion ${alt-Text}
      fish_pager_color_description ${alt-Overlay0}
    '';

    "cava/themes/${cava-theme}" = {
      text = ''
        [color]
        background = '${Base}'

        gradient = 1

        gradient_color_1 = '${Teal}'
        gradient_color_2 = '${Sky}'
        gradient_color_3 = '${Sapphire}'
        gradient_color_4 = '${Blue}'
        gradient_color_5 = '${Mauve}'
        gradient_color_6 = '${Pink}'
        gradient_color_7 = '${Maroon}'
        gradient_color_8 = '${Red}'
      '';
    };

    "dunst/dunstrc.d/00-${dunst-theme}.conf" = {
      text = ''
        [global]
        frame_color = "${Blue}"
        separator_color= frame
        highlight = "${Blue}"

        [urgency_low]
        background = "${Base}"
        foreground = "${Text}"

        [urgency_normal]
        background = "${Base}"
        foreground = "${Text}"

        [urgency_critical]
        background = "${Base}"
        foreground = "${Text}"
        frame_color = "${Peach}"
      '';
    };

    rofi-power = {
      target = "rofi/themes/power.rasi";
      text = ''
        * {
            bg: ${Mantle};
            background-color: @bg;
            font: "${rofiMenuFont}";
        }
        configuration {
            show-icons: true;
            icon-theme: "${gtk-icon}";
            location: 0;
            display-drun: "Launch:";
        }
        window {
            width: 20%;
            transparency: "real";
            orientation: vertical;
            border-color: ${Crust};
            border-radius: 0px;
        }
        mainbox {
            children: [inputbar, listview];
        }
        element {
            padding: 4 8;
            text-color: ${Sapphire};
            background-color: ${Crust};
            border-radius: 5px;
        }
        element.selected {
            text-color: ${Text};
            background-color: ${Mantle};
        }
        element-text {
            background-color: inherit;
            text-color: inherit;
        }
        element-icon {
            size: 16 px;
            background-color: inherit;
            padding: 0 6 0 0;
            alignment: vertical;
        }
        element.selected.active {
            background-color: ${Mantle};
            text-color: ${Text};
        }
        element.alternate.normal {
            background-color: ${Mantle};
            text-color: ${Text};
        }
        element.alternate.active {
            background-color: ${Mantle};
            text-color: ${Text};
        }
        element.selected.normal {
            background-color: ${Red};
            text-color: ${Crust};
        }
        element.normal.active {
            background-color: ${Mantle};
            text-color: ${Text};
        }
        element.normal.normal {
            background-color: ${Mantle};
            text-color: ${Text};
        }
        element.normal.urgent {
            background-color: ${Red};
            text-color: ${Crust};
        }
        listview {
            columns: 1;
            lines: 7;
            padding: 8 0;
            fixed-height: true;
            fixed-columns: true;
            fixed-lines: true;
            border: 0 10 6 10;
        }
        inputbar {
            padding: 10 0 0;
            margin: 0 0 0 0;
        }
        entry {
            text-color: ${Red};
            padding: 10 10 0 0;
            margin: 0 -2 0 0;
        }
        prompt {
            text-color: ${Blue};
            padding: 10 6 0 10;
            margin: 0 -2 0 0;
        }
      '';
    };

    rofi-main = {
      target = "rofi/themes/main.rasi";
      text = ''
        * {
            bg: ${Mantle};
            fg: ${Text};
            selection: ${Sapphire};
            border: ${Crust};
            urgent: ${Red};
            text-dark: ${Crust};
            comment:${Subtext0};
            background-color: @bg;
          }
          configuration {
            show-icons: true;
            icon-theme: "${gtk-icon}";
            location: 0;
            font: "${rofiMenuFont}";
            display-drun: "Launch:";
          }
          window {
            width: 45%;
            transparency: "real";
            orientation: vertical;
            border-color: @border;
            border-radius: 0px;
          }
          mainbox {
            children: [inputbar, listview];
          }
          element {
            padding: 4 12;
            text-color: @fg;
            border-radius: 5px;
          }
          element selected {
            text-color: @bg;
            background-color: @selection;
          }
          element-text {
            background-color: inherit;
            text-color: inherit;
          }
          element-icon {
            size: 16 px;
            background-color: inherit;
            padding: 0 6 0 0;
            alignment: vertical;
          }
          element.selected.active {
           	background-color: @bg;
           	text-color: @fg;
          }
          element.alternate.normal {
          	background-color: @bg;
          	text-color: @fg;
          }
          element.alternate.active {
          	background-color: @selection;
          	text-color: @bg;
          }
          element.selected.normal {
          	background-color: @selection;
          	text-color: @bg;
          }
          element.normal.active {
          	background-color: @bg;
          	text-color: @fg;
          }
          element.normal.normal {
          	background-color: @bg;
          	text-color: @fg;
          }
          element.normal.urgent {
          	background-color: @urgent;
          	text-color: @bg;
          }
          listview {
            columns: 2;
            lines: 9;
            padding: 8 0;
            fixed-height: true;
            fixed-columns: true;
            fixed-lines: true;
            border: 0 10 6 10;
          }
          entry {
            text-color: @fg;
            padding: 10 10 0 0;
            margin: 0 -2 0 0;
          }
          inputbar {
            padding: 10 0 0;
            margin: 0 0 0 0;
          }
          prompt {
            text-color: @selection;
            padding: 10 6 0 10;
            margin: 0 -2 0 0;
          }
      '';
    };

    rofi-keybinds = {
      target = "rofi/themes/keybinds.rasi";
      text = ''
        * {
            bg: ${Mantle};
            background-color: @bg;
            font: "${rofiMenuFont}";
        }
        configuration {
            show-icons: true;
            icon-theme: "${gtk-icon}";
            location: 0;
            display-drun: "Launch:";
        }
        window {
            width: 70%;
            transparency: "real";
            orientation: vertical;
            border-color: ${Crust};
            border-radius: 0px;
        }
        mainbox {
            children: [inputbar, listview];
        }
        element {
            padding: 4 8;
            text-color: ${Sapphire};
            background-color: ${Crust};
            border-radius: 5px;
        }
        element.selected {
            text-color: ${Text};
            background-color: ${Mantle};
        }
        element-text {
            background-color: inherit;
            text-color: inherit;
        }
        element-icon {
            size: 16 px;
            background-color: inherit;
            padding: 0 6 0 0;
            alignment: vertical;
        }
        element.selected.active {
            background-color: ${Mantle};
            text-color: ${Text};
        }
        element.alternate.normal {
            background-color: ${Mantle};
            text-color: ${Text};
        }
        element.alternate.active {
            background-color: ${Mantle};
            text-color: ${Text};
        }
        element.selected.normal {
            background-color: ${Red};
            text-color: ${Crust};
        }
        element.normal.active {
            background-color: ${Mantle};
            text-color: ${Text};
        }
        element.normal.normal {
            background-color: ${Mantle};
            text-color: ${Text};
        }
        element.normal.urgent {
            background-color: ${Red};
            text-color: ${Crust};
        }
        listview {
            columns: 1;
            lines: 16;
            padding: 8 0;
            fixed-height: true;
            fixed-columns: true;
            fixed-lines: true;
            border: 0 10 6 10;
        }
        inputbar {
            padding: 10 0 0;
            margin: 0 0 0 0;
        }
        entry {
            text-color: ${Red};
            padding: 10 10 0 0;
            margin: 0 -2 0 0;
        }
        prompt {
            text-color: ${Blue};
            padding: 10 6 0 10;
            margin: 0 -2 0 0;
        }
      '';
    };

  };

  xdg.dataFile = {
    "rofi/themes/${config.my.theme}.rasi".text = ''
      * {
        selected-active-foreground:  @background;
        lightfg:                     @text;
        separatorcolor:              @foreground;
        urgent-foreground:           @red;
        alternate-urgent-background: @lightbg;
        lightbg:                     @mantle;
        background-color:            transparent;
        border-color:                @foreground;
        normal-background:           @background;
        selected-urgent-background:  @red;
        alternate-active-background: @lightbg;
        spacing:                     2;
        alternate-normal-foreground: @foreground;
        urgent-background:           @background;
        selected-normal-foreground:  @lightbg;
        active-foreground:           @blue;
        background:                  @base;
        selected-active-background:  @blue;
        active-background:           @background;
        selected-normal-background:  @lightfg;
        alternate-normal-background: @lightbg;
        foreground:                  @text;
        selected-urgent-foreground:  @background;
        normal-foreground:           @foreground;
        alternate-urgent-foreground: @red;
        alternate-active-foreground: @blue;
      }
      element {
          padding: 1px ;
          cursor:  pointer;
          spacing: 5px ;
          border:  0;
      }
      element normal.normal {
          background-color: @normal-background;
          text-color:       @normal-foreground;
      }
      element normal.urgent {
          background-color: @urgent-background;
          text-color:       @urgent-foreground;
      }
      element normal.active {
          background-color: @active-background;
          text-color:       @active-foreground;
      }
      element selected.normal {
          background-color: @selected-normal-background;
          text-color:       @selected-normal-foreground;
      }
      element selected.urgent {
          background-color: @selected-urgent-background;
          text-color:       @selected-urgent-foreground;
      }
      element selected.active {
          background-color: @selected-active-background;
          text-color:       @selected-active-foreground;
      }
      element alternate.normal {
          background-color: @alternate-normal-background;
          text-color:       @alternate-normal-foreground;
      }
      element alternate.urgent {
          background-color: @alternate-urgent-background;
          text-color:       @alternate-urgent-foreground;
      }
      element alternate.active {
          background-color: @alternate-active-background;
          text-color:       @alternate-active-foreground;
      }
      element-text {
          background-color: transparent;
          cursor:           inherit;
          highlight:        inherit;
          text-color:       inherit;
      }
      element-icon {
          background-color: transparent;
          size:             1.0000em ;
          cursor:           inherit;
          text-color:       inherit;
      }
      window {
          padding:          5;
          background-color: @background;
          border:           1;
      }
      mainbox {
          padding: 0;
          border:  0;
      }
      message {
          padding:      1px ;
          border-color: @separatorcolor;
          border:       2px dash 0px 0px ;
      }
      textbox {
          text-color: @foreground;
      }
      listview {
          padding:      2px 0px 0px ;
          scrollbar:    true;
          border-color: @separatorcolor;
          spacing:      2px ;
          fixed-height: 0;
          border:       2px dash 0px 0px ;
      }
      scrollbar {
          width:        4px ;
          padding:      0;
          handle-width: 8px ;
          border:       0;
          handle-color: @normal-foreground;
      }
      sidebar {
          border-color: @separatorcolor;
          border:       2px dash 0px 0px ;
      }
      button {
          cursor:     pointer;
          spacing:    0;
          text-color: @normal-foreground;
      }
      button selected {
          background-color: @selected-normal-background;
          text-color:       @selected-normal-foreground;
      }
      num-filtered-rows {
          expand:     false;
          text-color: Gray;
      }
      num-rows {
          expand:     false;
          text-color: Gray;
      }
      textbox-num-sep {
          expand:     false;
          str:        "/";
          text-color: Gray;
      }
      inputbar {
          padding:    1px ;
          spacing:    0px ;
          text-color: @normal-foreground;
          children:   [ "prompt","textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator" ];
      }
      case-indicator {
          spacing:    0;
          text-color: @normal-foreground;
      }
      entry {
          text-color:        @normal-foreground;
          cursor:            text;
          spacing:           0;
          placeholder-color: Gray;
          placeholder:       "Type to filter";
      }
      prompt {
          spacing:    0;
          text-color: @normal-foreground;
      }
      textbox-prompt-colon {
          margin:     0px 0.3000em 0.0000em 0.0000em ;
          expand:     false;
          str:        ":";
          text-color: inherit;
      }
    '';
    "rofi/themes/${config.my.theme}-color.rasi".text = ''
      * {
        rosewater: ${Rosewater};
        flamingo: ${Flamingo};
        pink: ${Pink};
        mauve: ${Mauve};
        red: ${Red};
        maroon: ${Maroon};
        peach: ${Peach};
        yellow: ${Yellow};
        green: ${Green};
        teal: ${Teal};
        sky: ${Sky};
        sapphire: ${Sapphire};
        blue: ${Blue};
        lavender: ${Lavender};
        text: ${Text};
        subtext1: ${Subtext1};
        subtext0: ${Subtext0};
        overlay2: ${Overlay2};
        overlay1: ${Overlay1};
        overlay0: ${Overlay0};
        surface2: ${Surface2};
        surface1: ${Surface1};
        surface0: ${Surface0};
        base: ${Base};
        mantle: ${Mantle};
        crust: ${Crust};
      }
    '';
    "xfce4/terminal/colorschemes/${xfce4-terminal-theme}.theme".text = ''
      [Scheme]
      Name=${xfce4-terminal-theme}
      ColorCursor=${Rosewater}
      ColorCursorForeground=${Crust}
      ColorCursorUseDefault=FALSE
      ColorForeground=${Text}
      ColorBackground=${Base}
      ColorSelectionBackground=${Surface2}
      ColorSelection=${Text}
      ColorSelectionUseDefault=FALSE
      TabActivityColor=${Peach}
      ColorPalette=${Surface1};${Red};${Green};${Yellow};${Blue};${Pink};${Teal};${Subtext1};${Surface2};${Red};${Green};${Yellow};${Blue};${Pink};${Teal};${Subtext0}
    '';
  };

  programs.fish.shellInit = ''
    fish_config theme choose "${fish-theme}"
  '';

 #xdg.dataFile = {
 #  icons = {
 #    target = "icons/${gtk-icon}/";
 #    source = "${pkgs.papirus-icon-theme}/share/icons/${gtk-icon}/";
 #    recursive = true;
 #  };
 #};

 #home.activation = {
 #  openbox-theme = lib.hm.dag.entryAfter ["writeBoundary"] ''
 #    mkdir -p "$HOME/./share/fonts/noto-fonts-color-emoji"
 #    cp -rn "${pkgs.noto-fonts-color-emoji}/share/fonts/noto" "$HOME/.local/share/fonts/noto-fonts-color-emoji"
 #  '';
 #};

  catppuccin = {
    enable = true;
   #cache.enable = true;
    flavor = myStuff.myCat.myGlobal-Flav;
    accent = myStuff.myCat.myGlobal-Color;



   #aerc
   #anki
   #atuin
   #bottom
   #brave
   #chromium
   #delta
   #element-desktop
   #eza
   #fcitx5
   #floorp
   #foot
   #fuzzel
   #gitui
   #glamour
   #halloy
   #helix
   #imv
   #k9s
   #lazygit
   #librewolf
   #lsd
   #mako
   #micro
   #newsboat
   #nushell
   #rio
   #skim
   #spotify-player
   #thunderbird
   #tmux
   #tofi
   #vesktop
   #vicinae
   #vivaldi
   #vivid
   #vscode




    alacritty.enable = false;
    bat.enable = false;
    btop.enable = false;
    cava.enable = false;
    cursors.enable = false;
    dunst.enable = false;
    fish.enable = false;
    freetube.enable = false;
    fzf.enable = false;
    gh-dash.enable = false;
    ghostty.enable = false;
    gtk.icon.enable = false;
    kitty.enable = false;
    kvantum.enable = false;
    mangohud.enable = false;
    mpv.enable = false;
    nvim.enable = false;
    polybar.enable = false;
    qutebrowser.enable = false;
    rofi.enable = false;
    sioyek.enable = false;
    starship.enable = false;
    sway.enable = false;
    swaylock.enable = false;
    television.enable = false;
    waybar.enable = false;
    xfce4-terminal.enable = false;
    yazi.enable = false;
    zathura.enable = false;
    zed.enable = false;
    zellij.enable = false;
    zsh-syntax-highlighting.enable = false;


    # Extended Work Needed
    hyprland.enable = true;
    hyprlock.enable = true;
    swaync.enable = true;
    brave.enable = true;
    wlogout.enable = true;


   #wezterm = {        # doesnt work
   #  enable = true;
   #  apply = true;
   #};
   #firefox.profiles = {
   #  default = {
   #    enable = true;
   #    force = false;
   #  };
   #};

    # Only Way (for now)
    obs.enable = true;

  };

};}
