{ config, pkgs, lib, inputs, nix-path, ... }:

  let

    scheme ="dark";
    global-package = myGlobalCatppuccin;
    wallpaper = "${config.home.homeDirectory}/Pictures/Wallpapers/astronaut-${flavor}.png";
    wallpaper-alt = "file:///home/${config.home.username}/Pictures/Wallpapers/astronaut-${flavor}.png";

    picom-gamma = 0.85;
    picom-brightness = 1.05;

    gowall-name = "${nameC}-${flavorC}";

    gtk-theme = "catppuccin-${flavor}-${accent}-standard";
    gtk-decoration = ":minimize,maximize,close";
    gtk-package = myGTKCatppuccin;
    gtk2-package = myGTKCatppuccin;
    gtk-icon = "Papirus-Dark";
    gtk-icon-package = myIconCatppuccin;

    gtk-cursor = "catppuccin-${flavor}-${accent}-cursors";
    gtk-cursor-package = myCursorCatppuccin;
    x-cursor = "catppuccin-${flavor}-${accent}-cursors";
    x-cursor-package = myCursorCatppuccin;
    plasma-cursor = "catppuccin-${flavor}-${accent}-cursors";
    plasma-cursor-package = myCursorCatppuccin;
    hypr-cursor = "catppuccin-${flavor}-${accent}-cursors";
    hypr-cursor-package = myCursorCatppuccin;
    cursor-size = 24;

    qt-platform = "kvantum"; # "qt6ct"; (breaks plasma) # "kde"; (WORKS, but breaks qt) # "qtct"; (its qt5ct, breaks plasma) # "kvantum";
    qt-name = "Kvantum";
    qt-package = pkgs.kdePackages.qtstyleplugin-kvantum;
    qt-icon = "Papirus-Dark";
    qt-icon-package = myIconCatppuccin;
    kvantum-package = myKvantumCatppuccin;
    kvantum-theme = "catppuccin-${flavor}-${accent}";
    plasma-package = myKDECatppuccin;
    plasma-look = "Catppuccin-${flavorC}-${accentC}";
    plasma-theme = "default";
    plasma-widget = "Catppuccin-${flavorC}-${accentC}";
    plasma-color = "Catppuccin${flavorC}${accentC}";
    plasma-splash = "Catppuccin-${flavorC}-${accentC}";
    plasma-decoration-name = "__aurorae__svg__Catppuccin${flavorC}-Classic";
    plasma-decoration-platform = "org.kde.kwin.aurorae";
    plasma-decoration-right = [ "minimize" "maximize" "close" ];
    plasma-decoration-left = [ "application-menu" "on-all-desktops" "keep-above-windows" ];

    cinnamon-theme = "catppuccin-${flavor}-${accent}-standard";
    cinnamon-package = myGTKCatppuccin;
    mate-theme = "catppuccin-${flavor}-${accent}-standard";
    mate-package = myGTKCatppuccin;
    xfce-theme = "Prune";
    xfce-package = myGTKCatppuccin;

    openbox-package = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "openbox";
      rev = "main";
      sha256 = "sha256-56da/tjKvFhBbDF6uBau/KMznWIKeCK6jynbRJRkpTc=";
    };
    openbox-theme = "catppuccin-${flavor}";

    i3status-theme = "ctp-${flavor}";
    i3status-icon = "material-nf";
    i3BarPos = "top";
    i3BarMode = "dock";

    konsole-theme = "Konsole-catppuccin-${flavor}";
    konsole-theme-name = "Catppuccin ${flavorC}";
    kate-theme = "Catppuccin ${flavorC}";
    kate-ui = "Catppuccin ${flavorC} ${accentC}";
    kwrite-theme = "Catppuccin ${flavorC}";
    kwrite-color = "Catppuccin ${flavorC} ${accentC}";
    marknote-theme = "Catppuccin ${flavorC} ${accentC}";
    okular-theme = "Catppuccin ${flavorC} ${accentC}";
    dolphin-theme = "Catppuccin ${flavorC} ${accentC}";
    kdenlive-theme = "Catppuccin${flavorC}${accentC}.colors";
    easyeffects-theme = "Catppuccin${flavorC}${accentC}";

    alacritty-theme = "catppuccin_${flavor}";
    ghostty-theme = "light:catppuccin-${flavor},dark:catppuccin-${flavor}";
    ghostty-theme-name = "catppuccin-${flavor}";

    freetube-base = "catppuccinMocha";
    freetube-main = "CatppuccinMochaSapphire";
    freetube-sec = "CatppuccinMochaBlue";

    superfile-theme = "catppuccin-${flavor}";
    fish-theme = "Catppuccin ${flavorC}";
    fish-theme-name = "Catppuccin ${flavorC}";
    tv-theme = "catppuccin-${flavor}-${accent}";
    tv-preview = "TwoDark";
    bat-theme = "Catppuccin ${flavorC}";
    bat-source = pkgs.fetchurl {
      url = "https://github.com/catppuccin/bat/blob/main/themes/Catppuccin%20${flavorC}.tmTheme";
      sha256 = "sha256-8BKmij32yf+/3N92pKTLpDSOAz1yWd1I/+pNQ4ewu0c=";
    };
    yazi-bat = "catppuccin-${flavor}-yazi";
    btop-theme = "catppuccin_${flavor}";
    cava-theme = "catppuccin_${flavor}";

    xfiles-icons = "papirus-${flavor}-${accent}";

    dunst-theme = "catppuccin_${flavor}";

    catppuccinifier-flav = "${flavor}";
    catppuccinifier-flavC = "${flavorC}";
    catppuccinifier-acc = "${accent}";
    catppuccinifier-accC = "${accentC}";

    onboard-theme = "${pkgs.onboard}/share/onboard/themes/ModelM.theme";
    onboard-color = "${pkgs.onboard}/share/onboard/themes/Granite.colors";
    onboard-layout = "${pkgs.onboard}/share/onboard/layouts/Full Keyboard.onboard";
    onboard-key = "dish";

    nvim-package-theme = "catppuccin-nvim";
    nvim-name-theme = "catppuccin";
    nvim-package = pkgs.vimPlugins.${nvim-package-theme};
    nvim-lua = ''
      ["flavour"] = "${flavor}"
    '';
    nvim-config = ''
      lua << EOF
        local compile_path = vim.fn.stdpath("cache") .. "/${nvim-package-theme}"
        vim.fn.mkdir(compile_path, "p")
        vim.opt.runtimepath:append(compile_path)
        require("${nvim-name-theme}").setup({
        ["compile_path"] = (compile_path),
        ${nvim-lua}
      })
        vim.api.nvim_command("colorscheme ${nvim-name-theme}")
      EOF
    '';

    xfce4-terminal-theme = "Catppuccin-${flavorC}";

    wlogout-button-style = "wleave";
    wlogout-icon-shutdown = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/${wlogout-button-style}/${flavor}/${accent}/shutdown.svg";
      sha256 = "sha256-UKumaHqLiOZILPQrr4wOY5gQ9/In3QaHxWGU3LfhPGI=";
    };
    wlogout-icon-suspend = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/${wlogout-button-style}/${flavor}/${accent}/suspend.svg";
      sha256 = "sha256-Ck+BIIdGbNjQ9uvQ3Vv0j1Gt4z7Je54K5zWUyhH+mbI=";
    };
    wlogout-icon-lock = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/${wlogout-button-style}/${flavor}/${accent}/lock.svg";
      sha256 = "sha256-lxFVi5IoQ2D9HgEwzZLte2BxbdFzs/ImJ/WG8w/s3Do=";
    };
    wlogout-icon-logout = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/${wlogout-button-style}/${flavor}/${accent}/logout.svg";
      sha256 = "sha256-74KMoyoLjSHJIQcnKtJ/TD/gLKkEu5suHRcJvSI5fUE=";
    };
    wlogout-icon-reboot = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/${wlogout-button-style}/${flavor}/${accent}/reboot.svg";
      sha256 = "sha256-Tus9+yxpBLODVjzvSTmaMvag1lMC5xAIl2xLo2MMS1I=";
    };
    wlogout-icon-hibernate = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/wlogout/refs/heads/main/icons/${wlogout-button-style}/${flavor}/${accent}/hibernate.svg";
      sha256 = "sha256-JEpr5Du5/WUlOFQ9nZtXWmHS3xLXnq47AUwEM9NBzno=";
    };

    cmatrix = "blue";

    heroic-theme = "nord-dark";
    onlyoffice-theme = "theme-${scheme}";
    audacity-theme = "${scheme}";


    MonoSpace = "Comic Mono";
    MonoAlt = "Monofur Nerd Font Mono";
    MonoAlt2 = "Hack Nerd Font";
    Sans = "Comic Sans MS";
    Serif = "Comic Sans MS";
    Emoji = "Blobmoji";
    Symbols = "Symbols Nerd Font";

    Sans-X = "${Sans},  ${toString MonoSize}";
    Mono-X = "${MonoSpace},  ${toString MonoSize}";
    MonoRofi = "${MonoSpace} ${toString MonoSize}";
    MonoSt = "${MonoSpace}:style:Regular:pixelsize=${toString StSize}:antialias=true:autohint=true";
    MonoURxvt = "xft:${MonoSpace}:size=${toString MonoSize}";
    dmenuFont = "${MonoSpace}:style:Bold:pixelsize=${toString DmenuSize}:antialias=true:autohint=true";
    xmenu-font = "${Sans}:pixelsize=${toString XmenuSize}:antialias=true:style=Bold,${MonoAlt2},${Emoji}";
    rofiMenuFont = "${MonoSpace} ${toString RofiSize}";
    dunstFont = "${MonoSpace} ${toString MonoSize}";
    MonoOnboard = "${MonoAlt} bold";
    Poly1 = "${MonoSpace}:size=${toString PolySize}:weight=${PolyWeight};${toString PolyScale}";
    Poly2 = "${MonoAlt2}:size=${toString PolySize}:weight=${PolyWeight};${toString PolyScale}";
    Poly3 = "${MonoSpace}:size=${toString PolySizeSmall}:weight=${PolyWeight};${toString PolyScaleSmall}";
    PolySymbols = "${Symbols}:${toString PolySize}:weight=${PolyWeight};${toString PolyScale}";
    PolyEmoji = "${Emoji}:${toString PolyEmojiSize}";
    awesome-wmFont = "${Sans} Bold ${toString SansSize}";
    i3Style = "Bold Semi-Condensed";
    i3BarStyle = "Regular Semi-Condensed";
    bspTabFont = "monospace:size=${toString BspTabSize}";
    xfilesFont = "${Sans}";
    jgmenuFont = "${MonoSpace}; ${toString JgmenuSize}";

    MonoSize = 10;
    SansSize = 10;
    MonoSizeKitty = 9;
    MonoSizeAlacritty = 9.0;
    MonoSizePlasma = 11;
    MonoSizePlasmaSmall = 8;
    MonoSizeI3 = 9.0;
    MonoSizeI3Bar = 10.0;
    MangohudSize = 24;
    MonoSizeWezterm = 9.0;
    PolySize = 10.5;
    PolySizeSmall = 5.0;
    PolyEmojiSize = 1;
    PolyWeight = "medium";
    PolyScale = 3;
    PolyScaleSmall = 1;
    XmenuSize = 14;
    XfilesSize = 12;
    JgmenuSize = 11;
    RofiSize = 12;
    BspTabSize = 11;
    StSize = 12;
    DmenuSize = 16;

    sound = "ocean";

    hexToRgb = hex:
      let
        hexDigit = c: {
          "0" = 0;  "1" = 1;  "2" = 2;  "3" = 3; "4" = 4;  "5" = 5;  "6" = 6; "7" = 7;
          "8" = 8;  "9" = 9;  "a" = 10;  "b" = 11; "c" = 12; "d" = 13; "e" = 14;
          "f" = 15; "A" = 10; "B" = 11; "C" = 12; "D" = 13; "E" = 14; "F" = 15;
        }.${c};
        hexByte = i:
          let
            hi = hexDigit (builtins.substring i 1 hex);
            lo = hexDigit (builtins.substring (i + 1) 1 hex);
          in hi * 16 + lo;
        r = hexByte 0;
        g = hexByte 2;
        b = hexByte 4;
      in
        "${toString r},${toString g},${toString b}";

    alt-Accent = alt-Sapphire; Accent =    "#${alt-Accent}";    Calt-Accent =    lib.strings.toUpper alt-Accent;    CAccent =    lib.strings.toUpper Accent;
    alt-Rosewater =  "f4dbd6"; Rosewater = "#${alt-Rosewater}"; Calt-Rosewater = lib.strings.toUpper alt-Rosewater; CRosewater = lib.strings.toUpper Rosewater;
    alt-Flamingo =   "f0c6c6"; Flamingo =  "#${alt-Flamingo}";  Calt-Flamingo =  lib.strings.toUpper alt-Flamingo;  CFlamingo =  lib.strings.toUpper Flamingo;
    alt-Orange =     "fab387"; Orange =    "#${alt-Orange}";    Calt-Orange =    lib.strings.toUpper alt-Orange;    COrange =    lib.strings.toUpper Orange;
    alt-Pink =       "f5bde6"; Pink =      "#${alt-Pink}";      Calt-Pink =      lib.strings.toUpper alt-Pink;      CPink =      lib.strings.toUpper Pink;
    alt-Mauve =      "c6a0f6"; Mauve =     "#${alt-Mauve}";     Calt-Mauve =     lib.strings.toUpper alt-Mauve;     CMauve =     lib.strings.toUpper Mauve;
    alt-Red =        "ed8796"; Red =       "#${alt-Red}";       Calt-Red =       lib.strings.toUpper alt-Red;       CRed =       lib.strings.toUpper Red;
    alt-Maroon =     "ee99a0"; Maroon =    "#${alt-Maroon}";    Calt-Maroon =    lib.strings.toUpper alt-Maroon;    CMaroon =    lib.strings.toUpper Maroon;
    alt-Peach =      "f5a97f"; Peach =     "#${alt-Peach}";     Calt-Peach =     lib.strings.toUpper alt-Peach;     CPeach =     lib.strings.toUpper Peach;
    alt-Yellow =     "eed49f"; Yellow =    "#${alt-Yellow}";    Calt-Yellow =    lib.strings.toUpper alt-Yellow;    CYellow =    lib.strings.toUpper Yellow;
    alt-Green =      "a6da95"; Green =     "#${alt-Green}";     Calt-Green =     lib.strings.toUpper alt-Green;     CGreen =     lib.strings.toUpper Green;
    alt-Teal =       "8bd5ca"; Teal =      "#${alt-Teal}";      Calt-Teal =      lib.strings.toUpper alt-Teal;      CTeal =      lib.strings.toUpper Teal;
    alt-Sky =        "91d7e3"; Sky =       "#${alt-Sky}";       Calt-Sky =       lib.strings.toUpper alt-Sky;       CSky =       lib.strings.toUpper Sky;
    alt-Sapphire =   "7dc4e4"; Sapphire =  "#${alt-Sapphire}";  Calt-Sapphire =  lib.strings.toUpper alt-Sapphire;  CSapphire =  lib.strings.toUpper Sapphire;
    alt-Blue =       "8aadf4"; Blue =      "#${alt-Blue}";      Calt-Blue =      lib.strings.toUpper alt-Blue;      CBlue =      lib.strings.toUpper Blue;
    alt-Lavender =   "b7bdf8"; Lavender =  "#${alt-Lavender}";  Calt-Lavender =  lib.strings.toUpper alt-Lavender;  CLavender =  lib.strings.toUpper Lavender;
    alt-Brown =      "504945"; Brown =     "#${alt-Brown}";     Calt-Brown =     lib.strings.toUpper alt-Brown;     CBrown =     lib.strings.toUpper Brown;
    alt-Text =       "cad3f5"; Text =      "#${alt-Text}";      Calt-Text =      lib.strings.toUpper alt-Text;      CText =      lib.strings.toUpper Text;
    alt-Subtext1 =   "b8c0e0"; Subtext1 =  "#${alt-Subtext1}";  Calt-Subtext1 =  lib.strings.toUpper alt-Subtext1;  CSubtext1 =  lib.strings.toUpper Subtext1;
    alt-Subtext0 =   "a5adcb"; Subtext0 =  "#${alt-Subtext0}";  Calt-Subtext0 =  lib.strings.toUpper alt-Subtext0;  CSubtext0 =  lib.strings.toUpper Subtext0;
    alt-Overlay2 =   "939ab7"; Overlay2 =  "#${alt-Overlay2}";  Calt-Overlay2 =  lib.strings.toUpper alt-Overlay2;  COverlay2 =  lib.strings.toUpper Overlay2;
    alt-Overlay1 =   "8087a2"; Overlay1 =  "#${alt-Overlay1}";  Calt-Overlay1 =  lib.strings.toUpper alt-Overlay1;  COverlay1 =  lib.strings.toUpper Overlay1;
    alt-Overlay0 =   "6e738d"; Overlay0 =  "#${alt-Overlay0}";  Calt-Overlay0 =  lib.strings.toUpper alt-Overlay0;  COverlay0 =  lib.strings.toUpper Overlay0;
    alt-Surface2 =   "5b6078"; Surface2 =  "#${alt-Surface2}";  Calt-Surface2 =  lib.strings.toUpper alt-Surface2;  CSurface2 =  lib.strings.toUpper Surface2;
    alt-Surface1 =   "494d64"; Surface1 =  "#${alt-Surface1}";  Calt-Surface1 =  lib.strings.toUpper alt-Surface1;  CSurface1 =  lib.strings.toUpper Surface1;
    alt-Surface0 =   "363a4f"; Surface0 =  "#${alt-Surface0}";  Calt-Surface0 =  lib.strings.toUpper alt-Surface0;  CSurface0 =  lib.strings.toUpper Surface0;
    alt-Base =       "24273a"; Base =      "#${alt-Base}";      Calt-Base =      lib.strings.toUpper alt-Base;      CBase =      lib.strings.toUpper Base;
    alt-Mantle =     "1e2030"; Mantle =    "#${alt-Mantle}";    Calt-Mantle =    lib.strings.toUpper alt-Mantle;    CMantle =    lib.strings.toUpper Mantle;
    alt-Crust =      "181926"; Crust =     "#${alt-Crust}";     Calt-Crust =     lib.strings.toUpper alt-Crust;     CCrust =     lib.strings.toUpper Crust;
    alt-Black =      "11111b"; Black =     "#${alt-Black}";     Calt-Black =     lib.strings.toUpper alt-Black;     CBlack =     lib.strings.toUpper Black;


    rgb-alt-Accent =    hexToRgb alt-Accent;    rgb-Accent =    "rgb(${rgb-alt-Accent})";
    rgb-alt-Rosewater = hexToRgb alt-Rosewater; rgb-Rosewater = "rgb(${rgb-alt-Rosewater})"; base00 = alt-Base;     alt-base00 = "#${alt-Base}";
    rgb-alt-Flamingo =  hexToRgb alt-Flamingo;  rgb-Flamingo =  "rgb(${rgb-alt-Flamingo})";  base01 = alt-Red;      alt-base01 = "#${alt-Red}";
    rgb-alt-Orange =    hexToRgb alt-Orange;    rgb-Orange =    "rgb(${rgb-alt-Orange})";    base02 = alt-Green;    alt-base02 = "#${alt-Green}";
    rgb-alt-Pink =      hexToRgb alt-Pink;      rgb-Pink =      "rgb(${rgb-alt-Pink})";      base03 = alt-Yellow;   alt-base03 = "#${alt-Yellow}";
    rgb-alt-Mauve =     hexToRgb alt-Mauve;     rgb-Mauve =     "rgb(${rgb-alt-Mauve})";     base04 = alt-Blue;     alt-base04 = "#${alt-Blue}";
    rgb-alt-Red =       hexToRgb alt-Red;       rgb-Red =       "rgb(${rgb-alt-Red})";       base05 = alt-Pink;     alt-base05 = "#${alt-Pink}";
    rgb-alt-Maroon =    hexToRgb alt-Maroon;    rgb-Maroon =    "rgb(${rgb-alt-Maroon})";    base06 = alt-Teal;     alt-base06 = "#${alt-Teal}";
    rgb-alt-Peach =     hexToRgb alt-Peach;     rgb-Peach =     "rgb(${rgb-alt-Peach})";     base07 = alt-Subtext1; alt-base07 = "#${alt-Subtext1}";
    rgb-alt-Yellow =    hexToRgb alt-Yellow;    rgb-Yellow =    "rgb(${rgb-alt-Yellow})";    base08 = alt-Surface2; alt-base08 = "#${alt-Surface2}";
    rgb-alt-Green =     hexToRgb alt-Green;     rgb-Green =     "rgb(${rgb-alt-Green})";     base09 = alt-Red;      alt-base09 = "#${alt-Red}";
    rgb-alt-Teal =      hexToRgb alt-Teal;      rgb-Teal =      "rgb(${rgb-alt-Teal})";      base0A = alt-Green;    alt-base0A = "#${alt-Green}";
    rgb-alt-Sky =       hexToRgb alt-Sky;       rgb-Sky =       "rgb(${rgb-alt-Sky})";       base0B = alt-Yellow;   alt-base0B = "#${alt-Yellow}";
    rgb-alt-Sapphire =  hexToRgb alt-Sapphire;  rgb-Sapphire =  "rgb(${rgb-alt-Sapphire})";  base0C = alt-Blue;     alt-base0C = "#${alt-Blue}";
    rgb-alt-Blue =      hexToRgb alt-Blue;      rgb-Blue =      "rgb(${rgb-alt-Blue})";      base0D = alt-Pink;     alt-base0D = "#${alt-Pink}";
    rgb-alt-Lavender =  hexToRgb alt-Lavender;  rgb-Lavender =  "rgb(${rgb-alt-Lavender})";  base0E = alt-Teal;     alt-base0E = "#${alt-Teal}";
    rgb-alt-Brown =     hexToRgb alt-Brown;     rgb-Brown =     "rgb(${rgb-alt-Brown})";     base0F = alt-Subtext0; alt-base0F = "#${alt-Subtext0}";
    rgb-alt-Text =      hexToRgb alt-Text;      rgb-Text =      "rgb(${rgb-alt-Text})";
    rgb-alt-Subtext1 =  hexToRgb alt-Subtext1;  rgb-Subtext1 =  "rgb(${rgb-alt-Subtext1})";
    rgb-alt-Subtext0 =  hexToRgb alt-Subtext0;  rgb-Subtext0 =  "rgb(${rgb-alt-Subtext0})";
    rgb-alt-Overlay2 =  hexToRgb alt-Overlay2;  rgb-Overlay2 =  "rgb(${rgb-alt-Overlay2})";
    rgb-alt-Overlay1 =  hexToRgb alt-Overlay1;  rgb-Overlay1 =  "rgb(${rgb-alt-Overlay1})";
    rgb-alt-Overlay0 =  hexToRgb alt-Overlay0;  rgb-Overlay0 =  "rgb(${rgb-alt-Overlay0})";
    rgb-alt-Surface2 =  hexToRgb alt-Surface2;  rgb-Surface2 =  "rgb(${rgb-alt-Surface2})";
    rgb-alt-Surface1 =  hexToRgb alt-Surface1;  rgb-Surface1 =  "rgb(${rgb-alt-Surface1})";
    rgb-alt-Surface0 =  hexToRgb alt-Surface0;  rgb-Surface0 =  "rgb(${rgb-alt-Surface0})";
    rgb-alt-Base =      hexToRgb alt-Base;      rgb-Base =      "rgb(${rgb-alt-Base})";
    rgb-alt-Mantle =    hexToRgb alt-Mantle;    rgb-Mantle =    "rgb(${rgb-alt-Mantle})";
    rgb-alt-Crust =     hexToRgb alt-Crust;     rgb-Crust =     "rgb(${rgb-alt-Crust})";
    rgb-alt-Black =     hexToRgb alt-Black;     rgb-Black =     "rgb(${rgb-alt-Black})";


    starship1 =  "#3B4252";  obs-selection = "#3a3d53";   Transparent = "#FF00000";
    starship2 =  "#434C5E";  obs-vol-num =   "#78c75d";   Black-Transparent = "#00000000";
    starship3 =  "#4C566A";  obs-vol-warn =  "#ef7939";   alt-Transparent = "#FF00000";
    starship4 =  "#86BBD8";  obs-vol-error = "#e3455d";   alt-Black-Transparent = "00000000";
    starship5 =  "#06969A";                               wlogout-base = "rgba(36, 39, 58, 0.90)";
    starship6 =  "#33658A";                               wlogout-button = "rgb(53, 57, 75)"; # 20% Overlay2, 80% mantle

    name = "catppuccin";
    nameC = "Catppuccin";
    flavor = "macchiato";
    flavorC = "Macchiato";
    accent = "sapphire";
    accentC = "Sapphire";

    myGlobalCatppuccin = pkgs.catppuccin.override {
      variant = flavor;
      accent = accent;
      themeList = [ "alacritty" "bat" /*"bottom"*/ "btop" /*"element"*/ "grub" /*"hyprland"*/ /*"k9s"*/ /*"kvantum"*/ /*"lazygit"*/
                    /*"lxqt"*/ "qt5ct" "refind" "rofi" "starship" /*"thunderbird"*/ "waybar" ];
    };

    myKDECatppuccin = pkgs.catppuccin-kde.override {
      flavour = [ flavor ];
      accents = [ accent ];
      winDecStyles = [ "classic" ];
    };

    myCursorCatppuccin = pkgs.catppuccin-cursors."${flavor}${accentC}";

    myIconCatppuccin = pkgs.catppuccin-papirus-folders.override {
      flavor = flavor;
      accent = accent;
    };

    myKvantumCatppuccin = (pkgs.catppuccin-kvantum.override {
      variant = flavor;
      accent = accent;
    }).overrideAttrs (old: {
      installPhase = old.installPhase + ''
        sed -i 's/^\(shadowless_popup=\)false/\1true/' \
          $out/share/Kvantum/catppuccin-${flavor}-${accent}/*.kvconfig
      '';});

    myGTKCatppuccin = pkgs.catppuccin-gtk.override {
      variant = flavor;
      accents = [ accent ];
      size = "standard";
     #tweaks = [ "black" ];
    };

    cat-gif = pkgs.writeShellScriptBin "cat-gif" ''
      ${builtins.readFile ./cat_gif}
    '';
    cat-gif-theme = pkgs.writeShellScriptBin "cat-gif-theme" ''
      ${cat-gif}/bin/cat-gif $1 ${flavor}
    '';
    cat-pic = pkgs.writeShellScriptBin "cat-pic" ''
      ${builtins.readFile ./cat_pic}
    '';
    cat-pic-theme = pkgs.writeShellScriptBin "cat-pic-theme" ''
      ${cat-gif}/bin/cat-pic $1 ${flavor}
    '';
    cat-pic-batch = pkgs.writeShellScriptBin "cat-pic-batch" ''
      ${builtins.readFile ./cat_pic}
    '';
    cat-pic-batch-theme = pkgs.writeShellScriptBin "cat-pic-batch-theme" ''
      ${cat-gif}/bin/cat-pic $1 ${flavor}
    '';

    go-gif = pkgs.writeShellScriptBin "go-gif" ''
      ${builtins.readFile ./go_gif}
    '';
    go-gif-invert = pkgs.writeShellScriptBin "go-gif-invert" ''
      ${builtins.readFile ./go_gif_invert}
    '';
    go-pic = pkgs.writeShellScriptBin "go-pic" ''
      DIR=$HOME/Pictures/my-wallpapers/gowall/"${gowall-name}"
      mkdir -p "$DIR"
      gowall convert "$1" "$DIR" -f "png" -t "hm-theme"
    '';
    go-pic-batch = pkgs.writeShellScriptBin "go-pic-batch" ''
      DIR=$HOME/Pictures/my-wallpapers/gowall/"${gowall-name}"
      mkdir -p "$DIR"
      gowall convert --dir "$1" --output "$DIR" -f "png" -t "hm-theme"
    '';

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

      #pkill paperview-rs
      if [[ -f "$FEHBG" && -f "$LIVEBG" ]]; then
          if [[ "$FEHBG" -nt "$LIVEBG" ]]; then
              pkill paperview-rs & sh -c "$FEHBG"
              exit 0
          else
              pkill paperview-rs & sh -c "$FEHBG" && sleep 3 && cd $HOME/.cache && sh -c "$LIVEBG"
              cd
              exit 0
          fi
      elif [[ -f "$LIVEBG" ]]; then
          pkill paperview-rs & cd $HOME/.cache && sh -c "$LIVEBG"
          cd
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

    bsp-app-border = pkgs.writeShellScriptBin "bsp-app-border" ''
      {
        while read -r line; do
          read -r event monitor desktop node node_id action <<< "$line"
            wid=$(bspc query -T -n $node_id)
            classname=$(printf '%s\n' "$wid" | jq -r '.client.className')
            sticky=$(printf '%s\n' "$wid" | jq -r '.sticky')
            state=$(printf '%s\n' "$wid" | jq -r '.client.state')
            popup=$(xprop -id "$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}')" | grep _NET_WM_WINDOW_TYPE | sed 's/.*= //' | jq -Rr 'split(", ")[0] | sub("^_NET_WM_WINDOW_TYPE_"; "")')

            case "$classname" in
              firefox) color="${Orange}" ;;
              Brave-browser) color="${Orange}" ;;
              spotify) color="${Green}" ;;
              vlc) color="${Orange}" ;;
              heroic) color="${Blue}" ;;
              steam) color="${Blue}" ;;
              obs) color="${Red}" ;;
              freetube) color="${Red}" ;;
              uget-gtk) color="${Green}" ;;
              *)
                if [ -f "$HOME/.bsp_conf_color" ]; then
                  color="$(cat "$HOME/.bsp_conf_color" | grep focused_border_color | awk -F'"' '{print $2}')"
                else
                  color="${config.xsession.windowManager.bspwm.settings.focused_border_color}"
                fi
              ;;
            esac

            case "$state" in
              floating) color="${Yellow}" ;;
            esac

            case "$classname" in
              cbonsai) color="${Green}" ;;
              ".blueman-manager-wrapped") color="${Blue}" ;;
              bluetuith) color="${Blue}" ;;
              scratchpad) color="${Green}" ;;
              ".protonvpn-app-wrapped") color="${Mauve}" ;;
              eyedropper) color="${Mauve}" ;;
              pavucontrol) color="${Yellow}" ;;
              tetris) color="${Peach}" ;;
              kitty-picker) color="${Red}" ;;
              XFilesFloat) color="${Green}" ;;
              XFilesRoot) color="${Red}" ;;
              Xmessage) color="${Red}" ;;
              Gxmessage) color="${Red}" ;;
              baobab) color="${Green}" ;;
            esac

            case "$popup" in
              DIALOG) color="${Red}" ;;
            esac

            case "$sticky" in
              true) color="${Maroon}" ;;
            esac

            bspc config focused_border_color "$color"

        done < <(bspc subscribe node_focus node_state)
      }
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

    #
    bsp-default-icon = pkgs.writeShellScriptBin "bsp-default-icon" ''
      bspc query -D | while read name; do
        bspc desktop "$name" -n ""
      done
    '';

    dunst-sound = pkgs.writeShellScriptBin "dunst-sound" ''
      NORMAL="$HOME/.local/share/desktop-sounds/notif"
      CRIT="$HOME/.local/share/desktop-sounds/notif-critical"
      VOL="$HOME/.local/share/desktop-sounds/focus"

      [ -f $HOME/.cache/dunst-mute ] && exit 0

      if [[ "$DUNST_URGENCY" = "CRITICAL" ]]; then
        pw-play "$CRIT"
      elif [[ "$DUNST_BODY" =~ "Volume" ]]; then
        pw-play "$VOL"
      elif  [[ "$DUNST_BODY" != "^Volume" ]] && [[ "$DUNST_BODY" != "^Brightness" ]]; then
        pw-play "$NORMAL"
      fi
    '';

    xmenu-app = pkgs.writeShellScriptBin "xmenu-app" ''
xmenu <<EOF | sh &
  Run			rofi -show run -modi drun -line-padding 4 -hide-scrollbar -show-icons -theme ".config/rofi/themes/main.rasi"
󰀻  All Apps		xdg-xmenu
󰮫  JGMenu  		jgmenu_run
󱓟  Ulauncher		ulauncher
  Rofi		rofi -show drun -modi drun -line-padding 4 -hide-scrollbar -show-icons -theme ".config/rofi/themes/main.rasi"

󰖲  Pager		skippy-xd --paging
  Xpose		skippy-xd --toggle
󱞞  Hidden		bsp-hidden-menu

󱑆  Time
	  󰥔  Clock			gnome-clocks
	    Calendar		gnome-calendar
	  󱎫  Timer			timeswitch
	  󰀠  Alarm			kalarm
	  󰔜  Auto			kshutdown
  Resourses
	    Disk Usage		baobab
	    Monitor			resources
	    Btop			kitty --name btop --class btop sh -c btop
  Text
	    Notes			iotas
	  󰘎  Gui Editor		kate
󰍹  Screen
	  󰍹  Multi Monitor		rofi-monitor
	  󰸉  Wallpaper
		      Static			feh-rofi
		    󱜆  Live			paperview-rofi
		    󰑓  Reload Static			pkill paperview-rs; sh -c '$HOME/.fehbg'; touch $HOME/.fehbg
		    󰑓  Reload Live			live-bg
		    󰋆  Manual Live			live-bg-manual
		    󰋆  Manual Static			feh-rofi-manual
  Terminal
	    Kitty			kitty
	    Alacritty		alacritty
	    Ghostty			ghostty
	    Wezterm			wezterm
	    Konsole			konsole
	    Tilda			tilda
	    Xterm			xterm
	    Urxvt			urxvt
	    Foot			foot
	    St			st
	    Gnome			gnome-terminal
	    Xfce			xfce4-terminal
  File Manager
	    Dolphin			dolphin
	    Nemo			nemo
	    Thunar			thunar
	    Nautilus		nautilus
	    Yazi			yazi
  Browser
	    Firefox			firefox
	    Brave			brave
	    Qute			qutebrowser
  Tools
	    Ruler			kruler
	    Calc			rofi -show calc -modi drun -line-padding 4 -hide-scrollbar -show-icons
	    Color Picker		poly-color-picker
	  󰍉  Magnifier		sxcs --mag-filters "circle"
	  󰹑  XMagnify		magnify -wexpr 1920 / 4 -hexpr 1080 / 4 -m4 -r30
	  󰹑  XZoom			xzoom -mag 2
󰊗  Games
	    Menu			rofi -show games -modi drun -line-padding 4 -hide-scrollbar -show-icons -theme ".config/rofi/themes/main.rasi"
	    Pinball			SpaceCadetPinball
	    Tetris			ttetris
	  󱔎  Snake			gnome-nibbles
	  󰷚  Mines			gnome-mines
EOF
    '';

    xmenu-pp = pkgs.writeShellScriptBin "xmenu-pp" ''
pbcolor=$(systemctl --user is-active bspborder.service)
if [ "$pbcolor" = "active" ]; then
  pbcolor_status="On"
else
  pbcolor_status="Off"
fi

desound=$(systemctl --user is-active bspsounds.service)
if [ "$desound" = "active" ]; then
  desound_status="On"
else
  desound_status="Off"
fi

abp=$(systemctl --user is-active bsplive.service)
if [ "$abp" = "active" ]; then
  abp_status="On"
else
  abp_status="Off"
fi

baricon=$(systemctl --user is-active bspicon.service)
if [ "$baricon" = "active" ]; then
  baricon_status="On"
else
  baricon_status="Off"
fi

polylay=$(systemctl --user is-active bsplayout.service)
if [ "$polylay" = "active" ]; then
  polylay_status="On"
else
  polylay_status="Off"
fi

picomm=$(systemctl --user is-active picom.service)
if [ "$picomm" = "active" ]; then
  picom_status="On"
else
  picom_status="Off"
fi

xmenu <<EOF | sh &
  Power Profile
	  󰑣  Performance			powerprofilesctl set performance; polybar-msg action "#pp.hook.1"
	    Balanced			powerprofilesctl set balanced; polybar-msg action "#pp.hook.1"
	    Eco				powerprofilesctl set power-saver; polybar-msg action "#pp.hook.1"
  $(powerprofilesctl get)
$(echo "       󰇘󰇘󰇘󰇘 ")
  Bspwm Profile
	    Performance			bsp-power-man performance
	  󰮤  Fnacy				bsp-power-man fancy
	  󰂐  Battery-Save			bsp-power-man battery-save
	  󰜐  Manual				bsp-power-man manual
  $(cat $HOME/.config/bspwm/bsp-power-state)
$(echo "       󰇘󰇘󰇘󰇘 ")
󰵀  Subscribtions
	  Total: $(pgrep -a bspc | grep subscribe | wc -l)
	  Layouts: $(pgrep -a bspc | grep "subscribe node_add node_remove node_transfer node_flag node_state" | wc -l)
	  $(echo "    󰇘󰇘󰇘󰇘 ")
	  Border Color
		Status: $pbcolor_status
		  On			systemctl --user start bspborder.service; touch $HOME/.config/bspwm/bsp-auto-color
		󰅙  Off			systemctl --user stop bspborder.service; rm -f $HOME/.config/bspwm/bsp-auto-color
		󰑓  Reload		systemctl --user restart bspborder.service; touch $HOME/.config/bspwm/bsp-auto-color
	  Sounds
		Status: $desound_status
		  On			systemctl --user start bspsounds.service; touch $HOME/.config/bspwm/bsp-sounds-toggle
		󰅙  Off			systemctl --user stop bspsounds.service; rm -f $HOME/.config/bspwm/bsp-sounds-toggle
		󰑓  Reload		systemctl --user restart bspsounds.service; touch $HOME/.config/bspwm/bsp-sounds-toggle
	  Auto Live
		Status: $abp_status
		  On			systemctl --user start bsplive.service; touch $HOME/.config/bspwm/bsp-live-auto-pause
		󰅙  Off			systemctl --user stop bsplive.service; rm -f $HOME/.config/bspwm/bsp-live-auto-pause
		󰑓  Reload		systemctl --user restart bsplive.service; touch $HOME/.config/bspwm/bsp-live-auto-pause
	  Bspi
		Status: $baricon_status
		  On			systemctl --user start bspicon.service; touch $HOME/.config/bspwm/bsp-bspi-icons
		󰅙  Off			systemctl --user stop bspicon.service; rm -f $HOME/.config/bspwm/bsp-bspi-icons
		󰑓  Reload		systemctl --user restart bspicon.service; touch $HOME/.config/bspwm/bsp-bspi-icons
	  Layout
		Status: $polylay_status
		  On			systemctl --user start bsplayout.service; touch $HOME/.config/bspwm/bsp-layout-status
		󰅙  Off			systemctl --user stop bsplayout.service; rm -f $HOME/.config/bspwm/bsp-layout-status
		󰑓  Reload		systemctl --user restart bsplayout.service; touch $HOME/.config/bspwm/bsp-layout-status
$(echo "       󰇘󰇘󰇘󰇘 ")
󰗘  Picom is $picom_status		xremap-picom-toggle
EOF
    '';

    xmenu-audio = pkgs.writeShellScriptBin "xmenu-audio" ''
playing() {
    echo ""
    playerctl metadata -f '{{status}} {{title}}' 2>/dev/null | while read event; do
    out=$(playerctl metadata -f '{{status}} {{title}}' 2>/dev/null)
      if [[ -z $out ]]; then
        echo ""
      else
        echo $out | sed 's/Paused//; s/Playing//; s/Stopped//;'
      fi
    done
}

xmenu <<EOF | sh &
󱡫  Audio Control			pavucontrol
  Bluetooth			bluetuith-gui
$(echo "        󰇘󰇘󰇘󰇘 ")
  Mute				pamixer --mute
  Unmute				pamixer --unmute
󰝝  Up
	  +5				pamixer --increase 5
	  +10				pamixer --increase 10
	  +20				pamixer --increase 20
	  +30				pamixer --increase 30
	  +40				pamixer --increase 40
	  +50				pamixer --increase 50
󰝞  Down
	  -5				pamixer --decrease 5
	  -10				pamixer --decrease 10
	  -20				pamixer --decrease 20
	  -30				pamixer --decrease 30
	  -40				pamixer --decrease 40
	  -50				pamixer --decrease 50
  Volume
	  5%				pamixer --set-volume 5
	  10%				pamixer --set-volume 10
	  20%				pamixer --set-volume 20
	  30%				pamixer --set-volume 30
	  40% 			pamixer --set-volume 40
	  50% 			pamixer --set-volume 50
	  60% 			pamixer --set-volume 60
	  70% 			pamixer --set-volume 70
	  80% 			pamixer --set-volume 80
	  90% 			pamixer --set-volume 90
	  100%			pamixer --set-volume 100
	  110%			pamixer --set-volume 110
	  120%			pamixer --set-volume 120
$(echo "        󰇘󰇘󰇘󰇘 ")
Now Playing
󰝚 $(playing)
	  󰐎  Play/Pause		playerctl play-pause
	  󰒭  Next			playerctl next
	  󰒮  Prev			playerctl previous
	    Loop			playerctl loop
	    Stop			playerctl stop
	    Seek
		      +5			playerctl position 5+
		      -5			playerctl position 5-
		      +10			playerctl position 10+
		      -10			playerctl position 10-
		      +20			playerctl position 20+
		      -20			playerctl position 20-
		      +30			playerctl position 30+
		      -30			playerctl position 30-
EOF
    '';

    xmenu-key = pkgs.writeShellScriptBin "xmenu-key" ''
LAYOUT=$(xkb-switch -p)
case "$LAYOUT" in
  us) flag="🇺🇸" ;;
  ir) flag="🇮🇷" ;;
esac

xmenu <<EOF | sh &
  Clipboard				copyq toggle
  ClipMenu				copyq menu
$(echo "           󰇘󰇘󰇘󰇘 ")
  Layout: $flag $LAYOUT		poly-xkb-change
󰪛  CapsLock				xdotool key Caps_Lock
$(echo "           󰇘󰇘󰇘󰇘 ")
󰌏  Onscreen Keyboard		onboard
󰌏  Vboard          		vboard
  Fonts				font-manager
$(echo "           󰇘󰇘󰇘󰇘 ")
󰞅  Emojis				rofi -show emoji -modi drun -line-padding 4 -hide-scrollbar -show-icons -theme ".config/rofi/themes/main.rasi"
  Symbols				rofi -show nerdy -modi drun -line-padding 4 -hide-scrollbar -show-icons -theme ".config/rofi/themes/main.rasi"
EOF
    '';

    xmenu-idle = pkgs.writeShellScriptBin "xmenu-idle" ''
xss=$(systemctl --user is-active xss-lock.service)
if [ "$xss" = "active" ]; then
  xss_status="Active"
else
  xss_status="Inactive"
fi

xmenu <<EOF | sh &
  Uptime
       $(uptime | awk '{print $1}')

󱄥  ScreenSaver
     $(xset q | grep -E "timeout")

󰚥  Power Managerment
     $(xset q | grep -E "DPMS is")

󰤆  Power Time
     $(xset q | grep -E "Standby")

  Auto Lock
       $(echo "$xss_status")

󰍹  Display
     $(xset q | grep -E "Monitor is")
EOF
    '';

    xmenu-power = pkgs.writeShellScriptBin "xmenu-power" ''
xmenu <<EOF | sh &
󰪫  $(uname -n | sed 's/^\(.\)/\U\1/') - $(whoami | tr '[:lower:]' '[:upper:]')
  $(date '+%a %d %b %y')		gnome-calendar
$(echo "        󰇘󰇘󰇘󰇘 ")
  Lock				i3lock-fancy-rapid 10 10 -n -c 24273a -p default
󰍃  Logout				bspc quit; pkill dwm; pkill dwm; openbox --exit; i3-msg exit
󰒲  Sleep				systemctl suspend
  Reboot				systemctl reboot
⏼  Shutdown				systemctl poweroff
$(echo "        󰇘󰇘󰇘󰇘 ")
  Menu				poly-power
󱟛  Modules				poly-modules-rofi
  Bspwm
	  󰑓  Reload Bspwm		bspc wm -r
	  󰆓  Save Session		yes | xsession-manager -s bspwm
	  󰆔  Restore Session	yes | xsession-manager -pr bspwm
  NixOS
	  $(bullshit)
󰛨  Inspire				notify-send '$(fortune -so | tr '\n' ' ')'
EOF
    '';

    xmenu-bsp = pkgs.writeShellScriptBin "xmenu-bsp" ''
xmenu <<EOF | sh &
  Current: $(bsp-layout get)
$(echo "        󰇘󰇘󰇘󰇘 ")
󰨇  Layouts
	  Tiled		bsp-set-layout tiled
	  Monocle		bsp-set-layout monocle
	  Floating		bsp-set-layout floating
	  $(echo "    󰇘󰇘󰇘󰇘 ")
	  V Master
		    Right
			  1
				Set			bsp-set-layout tall
				Once			bsp-once-layout tall
			  2
				Set			bsp-set-layout tall2
				Once			bsp-once-layout tall2
			  3
				Set			bsp-set-layout tall3
				Once			bsp-once-layout tall3
			  4
				Set			bsp-set-layout tall4
				Once			bsp-once-layout tall4
		    Left
			  1
				Set			bsp-set-layout rtall
				Once			bsp-once-layout rtall
			  2
				Set			bsp-set-layout rtall2
				Once			bsp-once-layout rtall2
			  3
				Set			bsp-set-layout rtall3
				Once			bsp-once-layout rtall3
			  4
				Set			bsp-set-layout rtall4
				Once			bsp-once-layout rtall4
	  H Master
		    Up
			  1
				Set			bsp-set-layout wide
				Once			bsp-once-layout wide
			  2
				Set			bsp-set-layout wide2
				Once			bsp-once-layout wide2
			  3
				Set			bsp-set-layout wide3
				Once			bsp-once-layout wide3
			  4
				Set			bsp-set-layout wide4
				Once			bsp-once-layout wide4
		    Down
			  1
				Set			bsp-set-layout rwide
				Once			bsp-once-layout rwide
			  2
				Set			bsp-set-layout rwide2
				Once			bsp-once-layout rwide2
			  3
				Set			bsp-set-layout rwide3
				Once			bsp-once-layout rwide3
			  4
				Set			bsp-set-layout rwide4
				Once			bsp-once-layout rwide4
	  D Master
		    V Center
			  1
				Set			bsp-set-layout cmaster
				Once			bsp-once-layout cmaster
			  2
				Set			bsp-set-layout cmaster2
				Once			bsp-once-layout cmaster2
			  3
				Set			bsp-set-layout cmaster3
				Once			bsp-once-layout cmaster3
		    H Center
			  1
				Set			bsp-set-layout rcmaster
				Once			bsp-once-layout rcmaster
			  2
				Set			bsp-set-layout rcmaster2
				Once			bsp-once-layout rcmaster2
			  3
				Set			bsp-set-layout rcmaster3
				Once			bsp-once-layout rcmaster3
		    Right
			  1
				Set			bsp-set-layout rdmaster
				Once			bsp-once-layout rdmaster
			  2
				Set			bsp-set-layout rdmaster2
				Once			bsp-once-layout rdmaster2
			  3
				Set			bsp-set-layout rdmaster3
				Once			bsp-once-layout rdmaster3
		    Left
			  1
				Set			bsp-set-layout dmaster
				Once			bsp-once-layout dmaster
			  2
				Set			bsp-set-layout dmaster2
				Once			bsp-once-layout dmaster2
			  3
				Set			bsp-set-layout dmaster3
				Once			bsp-once-layout dmaster3
		    Up
			  1
				Set			bsp-set-layout hdmaster
				Once			bsp-once-layout hdmaster
			  2
				Set			bsp-set-layout hdmaster2
				Once			bsp-once-layout hdmaster2
			  3
				Set			bsp-set-layout hdmaster3
				Once			bsp-once-layout hdmaster3
		    Down
			  1
				Set			bsp-set-layout rhdmaster
				Once			bsp-once-layout rhdmaster
			  2
				Set			bsp-set-layout rhdmaster2
				Once			bsp-once-layout rhdmaster2
			  3
				Set			bsp-set-layout rhdmaster3
				Once			bsp-once-layout rhdmaster3
	  Grid
		    V
			  Set			bsp-set-layout grid
			  Once		bsp-once-layout grid
		    H
			  Set			bsp-set-layout rgrid
			  Once		bsp-once-layout rgrid
	  Deck
		    Set		bsp-set-layout deck
		    Once		bsp-once-layout deck
	  Fair
		    V
			  Set			bsp-set-layout fair
			  Once		bsp-once-layout fair
		    H
			  Set			bsp-set-layout rfair
			  Once		bsp-once-layout rfair
	  Row
		    1
			  Set			bsp-set-layout row
			  Once		bsp-once-layout row
		    2
			  Set			bsp-set-layout row2
			  Once		bsp-once-layout row2
		    3
			  Set			bsp-set-layout row3
			  Once		bsp-once-layout row3
		    4
			  Set			bsp-set-layout row4
			  Once		bsp-once-layout row4
		    5
			  Set			bsp-set-layout row5
			  Once		bsp-once-layout row5
		    6
			  Set			bsp-set-layout row6
			  Once		bsp-once-layout row6
	  Col
		    1
			  Set			bsp-set-layout col
			  Once		bsp-once-layout col
		    2
			  Set			bsp-set-layout col2
			  Once		bsp-once-layout col2
		    3
			  Set			bsp-set-layout col3
			  Once		bsp-once-layout col3
		    4
			  Set			bsp-set-layout col4
			  Once		bsp-once-layout col4
		    5
			  Set			bsp-set-layout col5
			  Once		bsp-once-layout col5
		    6
			  Set			bsp-set-layout col6
			  Once		bsp-once-layout col6
	  TV
		    NW
			  Set			bsp-set-layout tv-nw
			  Once		bsp-once-layout tv-nw
		    SW
			  Set			bsp-set-layout tv-sw
			  Once		bsp-once-layout tv-sw
		    NE
			  Set			bsp-set-layout tv-ne
			  Once		bsp-once-layout tv-ne
	  Dwindle
		    Set		bsp-set-layout dwindle
		    Once		bsp-once-layout dwindle
	  Spiral
		    Set		bsp-set-layout spiral
		    Once		bsp-once-layout spiral
	  Equal
		    Set		bsp-set-layout even
		    Once		bsp-once-layout even
  Layout Actions
	  󰑓  Reload Layout				bsp-layout reload; polybar-msg action "#bspwm.hook.1"
	    Remove Layout				bsp-remove-layout; polybar-msg action "#bspwm.hook.1"
	  󰙰  Remove & Restore			bsp-remove-layout; bsp-restore-cached-layout; polybar-msg action "#bspwm.hook.1"
	    Cache Layout				bsp-cache-layout
	  $(echo "        󰇘󰇘󰇘󰇘 ")
	    Zoom On					bsp-stack-zoom
	    Zoom Off				bsp-stack-zoom-remove
	  󱡴  Zoom Once				bsp-stack-zoom-oneshot
	  $(echo "        󰇘󰇘󰇘󰇘 ")
	    Equalize All				bspc query -N -d | xargs -I % bspc node % -B
	  󰾞  Equalize Stack
		      Parent			bspc node @parent -B
	  $(echo "        󰇘󰇘󰇘󰇘 ")
	    Add Master Node			bsp-master-node-increase
	  -  Sub Master Node			bsp-master-node-decrease
	    Move Master				bsp-move-master; polybar-msg action "#bspwm.hook.1"
	  $(echo "        󰇘󰇘󰇘󰇘 ")
	  󰑌  Deck Cycle				bsp-layout deck-cycle
󱂬  Node Actions
	    Close Focused				bspc node -c
	    Point & Close				xdotool selectwindow windowkill
EOF
    '';

    xmenu-fetch = pkgs.writeShellScriptBin "xmenu-fetch" ''
xmenu <<EOF | sh &
$(fastfetch --logo none)
EOF
    '';

    xfiles = pkgs.callPackage ../../nixos/myPackages/xfiles.nix { };
    xfiles-theme =  xfiles.overrideAttrs (old: {
      prePatch = (old.prePatch or "") + ''
        rm -rf icons
        cp -r ${inputs.assets}/icons/xfiles-colors/xfiles-papirus-macchiato-sapphire icons
        chmod -R +w icons
      '';
    });
    xfiles-float-package = xfiles-theme.overrideAttrs (old: {
      pname = "xfiles-float";
      postPatch = (old.postPatch or "") + ''
        substituteInPlace xfiles.c \
      --replace-fail 'APPCLASS        "XFiles"' 'APPCLASS        "XFilesFloat"'
      '';
      installPhase = ''
        runHook preInstall
        install -Dm755 xfiles $out/bin/xfiles-float
        runHook postInstall
      '';
      meta = old.meta // {
        mainProgram = "xfiles-float";
      };
    });
    xfiles-float-script = pkgs.writeShellScriptBin "xfiles-float-script" ''
      ${xfiles-float-package}/bin/xfiles-float
    '';
     xfiles-root-package =  xfiles-theme.overrideAttrs (old: {
       pname = "xfiles-root";
       postPatch = (old.postPatch or "") + ''
         substituteInPlace xfiles.c \
       --replace-fail 'APPCLASS        "XFiles"' 'APPCLASS        "XFilesRoot"'
       '';
       installPhase = ''
         runHook preInstall
         install -Dm755 xfiles $out/bin/xfiles-root
         runHook postInstall
       '';
       meta = old.meta // {
         mainProgram = "xfiles-root";
       };
    });
    xfiles-root-script = pkgs.writeShellScriptBin "xfiles-root-script" ''
      ${xfiles-root-package}/bin/xfiles-root
    '';

  in

{ config = lib.mkIf (config.my.theme == "catppuccin-uni") {

  home.packages = [

    pkgs.catppuccinifier-cli
    pkgs.catppuccin-qt5ct
   #pkgs.iconpack-jade

    cat-gif
    cat-gif-theme
    cat-pic
    cat-pic-theme
    cat-pic-batch
    cat-pic-batch-theme
    go-pic
    go-pic-batch
    go-gif
    go-gif-invert

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

    bsp-border-color
    bsp-app-border
    bsp-tabbed
    bsp-default-icon
    bsptab

    xmenu-app
    xmenu-pp
    xmenu-audio
    xmenu-key
    xmenu-idle
    xmenu-power
    xmenu-bsp
    xmenu-fetch

    (pkgs.writeShellScriptBin "tcmatrix" ''${config.my.default.terminal} --name cmatrix --class cmatrix sh -c 'cmatrix -C ${cmatrix}' '')

    xfiles-float-script
    xfiles-root-script
    xfiles-theme

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

  home.sessionVariables = {
   #QT_QPA_PLATFORMTHEME = lib.mkForce "";
    THEME_COLOR_A  = "${Accent}";
    THEME_COLOR_1  = "${Rosewater}";
    THEME_COLOR_2  = "${Flamingo}";
    THEME_COLOR_3  = "${Orange}";
    THEME_COLOR_4  = "${Pink}";
    THEME_COLOR_5  = "${Mauve}";
    THEME_COLOR_6  = "${Red}";
    THEME_COLOR_7  = "${Maroon}";
    THEME_COLOR_8  = "${Peach}";
    THEME_COLOR_9  = "${Yellow}";
    THEME_COLOR_10 = "${Green}";
    THEME_COLOR_11 = "${Teal}";
    THEME_COLOR_12 = "${Sky}";
    THEME_COLOR_13 = "${Sapphire}";
    THEME_COLOR_14 = "${Blue}";
    THEME_COLOR_15 = "${Lavender}";
    THEME_COLOR_16 = "${Brown}";
    THEME_COLOR_17 = "${Text}";
    THEME_COLOR_18 = "${Subtext1}";
    THEME_COLOR_19 = "${Subtext0}";
    THEME_COLOR_20 = "${Overlay2}";
    THEME_COLOR_21 = "${Overlay1}";
    THEME_COLOR_22 = "${Overlay0}";
    THEME_COLOR_23 = "${Surface2}";
    THEME_COLOR_24 = "${Surface1}";
    THEME_COLOR_25 = "${Surface0}";
    THEME_COLOR_26 = "${Base}";
    THEME_COLOR_27 = "${Mantle}";
    THEME_COLOR_28 = "${Crust}";
    THEME_COLOR_29 = "${Black}";

    GLAMOUR_STYLE = "${config.xdg.configHome}/glamour/theme.json";
  };

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
    #xclickroot -r xmenu-app &
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
    # TODO add 16-21 colors

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

    "Sxiv.foreground" = Text;
    "Sxiv.background" = Base;
    "Sxiv.font" = Mono-X;
   #"*background" = "[background_opacity]#fafafa";

    "dmenu.font" = dmenuFont;
    "dmenu.background" = Base;
    "dmenu.foreground" = Text;
    "dmenu.selbackground" = Rosewater;
    "dmenu.selforeground" = Base;

    "st.font" = MonoSt;
    "st.alpha" = 0.80; # For Transparent 0.60
    "st.borderpx" = 10; # inner border

   #dwm.normbgcolor: #FAFAFA
   #dwm.normbordercolor: #FAFAFA
   #dwm.normfgcolor: #2E3440
   #dwm.selfgcolor: #FAFAFA
   #dwm.selbordercolor: #B48EAD
   #dwm.selbgcolor: #81A1C1

    "xmenu.font" = xmenu-font;
    "xmenu.background" = CBase;
    "xmenu.foreground" = Text;
    "xmenu.selbackground" = CAccent;
    "xmenu.selforeground" = CBase;
    "xmenu.separator" = CSubtext1;
    "xmenu.border" = CAccent;
    "xmenu.borderWidth" = 3;
    "xmenu.separatorWidth" = 3;
   #"xmenu.maxItems" = ;
    "xmenu.alignment" = "left";
    "xmenu.gap" = 6;
   #"xmenu.width" = ; # min width
   #"xmenu.height" = ; # height
  };
  xresources.extraConfig = lib.mkIf config.xsession.enable ''
    ! Font
    XFiles.faceName:                ${xfilesFont}
    XFiles.faceSize:                ${toString XfilesSize}

    ! Plan 9 Acme colors
    XFiles.background:              ${CBase}
    XFiles.foreground:              ${CText}
    XFiles.activeBackground:        ${CAccent}
    XFiles.activeForeground:        ${CCrust}

    ! Background transparency (requires X11 compositor)
    XFiles.opacity:                 0.9

    ! Icons for XDG user directories
    XFiles.fileIcons:                       \n\
        *.c=code                        \n\
        *.h=code                        \n\
        ~/Documents/=documents_dir      \n\
        ~/Download/=downloads_dir       \n\
        ~/Memes/=meme_dir               \n\
        ~/Music/=music_dir              \n\
        ~/Pictures/=images_dir          \n\
        ~/Videos/=videos_dir



    ! Font
    XFilesFloat.faceName:           ${xfilesFont}
    XFilesFloat.faceSize:           ${toString XfilesSize}

    ! Plan 9 Acme colors
    XFilesFloat.background:         ${CBase}
    XFilesFloat.foreground:         ${CText}
    XFilesFloat.activeBackground:   ${CAccent}
    XFilesFloat.activeForeground:   ${CCrust}

    ! Background transparency (requires X11 compositor)
    XFilesFloat.opacity:                 0.9

    ! Icons for XDG user directories
    XFilesFloat.fileIcons:                  \n\
        *.c=code                        \n\
        *.h=code                        \n\
        ~/Documents/=documents_dir      \n\
        ~/Download/=downloads_dir       \n\
        ~/Memes/=meme_dir               \n\
        ~/Music/=music_dir              \n\
        ~/Pictures/=images_dir          \n\
        ~/Videos/=videos_dir


    ! Font
    XFilesRoot.faceName:           ${xfilesFont}
    XFilesRoot.faceSize:           ${toString XfilesSize}

    ! Plan 9 Acme colors
    XFilesRoot.background:         ${CMaroon}
    XFilesRoot.foreground:         ${CCrust}
    XFilesRoot.activeBackground:   ${CRed}
    XFilesRoot.activeForeground:   ${CCrust}

    ! Background transparency (requires X11 compositor)
    XFilesRoot.opacity:                 0.9

    ! Icons for XDG user directories
    XFilesRoot.fileIcons:                  \n\
        *.c=code                        \n\
        *.h=code                        \n\
        ~/Documents/=documents_dir      \n\
        ~/Download/=downloads_dir       \n\
        ~/Memes/=meme_dir               \n\
        ~/Music/=music_dir              \n\
        ~/Pictures/=images_dir          \n\
        ~/Videos/=videos_dir
  '';

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
   #startup = [ { command = "fehw"; always = true; } ];
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
          separator = Accent;
          focusedBackground = Base;
          focusedWorkspace = {
            background = Accent;
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
       #    theme = "catppuccin-${flavor}";
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
      #fehw &
  '';
    settings = {
      border_width = 4;
      window_gap = 6;
      left_padding = 0;
      right_padding = 0;
      top_padding = 0;
      bottom_padding = 0;
      presel_feedback_color = Overlay1;
      active_border_color = Lavender;
      focused_border_color = Accent;
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
      "/.config/kdenliverc" = {
        "UiSettings" = {
          "ColorSchemePath" = kdenlive-theme;
        };
      };
     #"/.config/kdedefaults/kdegloblas" = {
     #  "Icons" = {
     #    "Theme" = qt-icon; # "*"
     #  };
     #};
      "/.config/easyeffectsrc" = {
        "UiSettings" = {
          "ColorScheme" = easyeffects-theme;
        };
      };
      "/.config/easyeffects/db/graphrc" = {
        "Graph" = {
          "colorTheme" = "userDefined";
          "backgroundColor" = rgb-alt-Mantle;
          "borderColors" = rgb-alt-Accent;
          "labelBackgroundColor" = rgb-alt-Crust;
          "labelTextColor" = rgb-alt-Text;
          "plotAreaBackgroundColor" = rgb-alt-Mantle;
          "seriesColors" = rgb-alt-Crust;
        };
      };
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
            Description=${konsole-theme-name}
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
        mark3_background = Accent;
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
            family = lib.mkForce MonoAlt2;
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
        colors = {
          primary = {
            foreground = Text;
            background = Base;
            bright_foreground = Text;
            dim_foreground = Text;
          };
          selection = {
            text = Base;
            background = Rosewater;
          };
          cursor = {
            text = Base;
            cursor = Rosewater;
          };
          vi_mode_cursor = {
            text = Base;
            cursor = Lavender;
          };
          search = {
            matches = {
              foreground = Base;
              background = Subtext0;
            };
            focused_match = {
              foreground = Base;
              background = Green;
            };
          };
          footer_bar = {
            foreground = Base;
            background = Subtext0;
          };
          hints = {
            start = {
              foreground = Base;
              background = Yellow;
            };
            end = {
              foreground = Base;
              background = Subtext0;
            };
          };
          normal = {
            black = Surface1;
            white = Subtext0;
            red = Red;
            green = Green;
            yellow = Yellow;
            blue = Blue;
            magenta = Pink;
            cyan = Teal;
          };
          bright = {
            black = Surface2;
            white = Subtext0;
            red = Red;
            green = Green;
            yellow = Yellow;
            blue = Blue;
            magenta = Pink;
            cyan = Teal;
          };
          dim = {
            black = Surface1;
            red = Red;
            green = Green;
            yellow = Yellow;
            blue = Blue;
            magenta = Pink;
            cyan = Teal;
            white = Subtext1;
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
             "0=${Surface1}"
             "1=${Red}"
             "2=${Green}"
             "3=${Yellow}"
             "4=${Blue}"
             "5=${Pink}"
             "6=${Teal}"
             "7=${Subtext0}"
             "8=${Surface2}"
             "9=${Red}"
            "10=${Green}"
            "11=${Yellow}"
            "12=${Blue}"
            "13=${Pink}"
            "14=${Teal}"
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
        @define-color accent    ${Accent};
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
            background-color: @accent;
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
            background-color: @accent;
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
        color: @accent;
        }

      '';
    };
    ashell.settings = lib.mkIf config.programs.ashell.enable {
      appearance = {
        style = "Gradient";  # "Islands"
        background_color = Base;
        primary_color = Base;
        secondary_color = Accent;
        success_color = Green;
        danger_color = Red;
        text_color = Text;
        opacity = 1.0;
        menu.opacity = 1.0;
        font_name = Sans;
        workspace_colors = [ Overlay2 Text ];
        special_workspace_colors = [ Accent Rosewater ];
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
              secondary = Accent;
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
              primary = Accent;
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
      };
      scriptOpts = {
        uosc.color = "background=${alt-Base},background_text=${alt-Text},foreground=${alt-Accent},foreground_text=${alt-Base},success=${alt-Green},error=${alt-Red},curtain=${alt-Mantle}";
        modernz = {
          seekbarfg_color = Peach;
          seekbarbg_color = Accent;
          seekbar_cache_color = Accent;
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
        stats = {
          border_color = alt-Mauve;
          font_color = alt-Pink;
          plot_bg_border_color = alt-Yellow;
          plot_bg_color = alt-Mauve;
          plot_color = alt-Yellow;
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
          indicator = { error = Red; start = Accent; stop = Text; };
          odd = { bg = Surface1; fg = Overlay2; };
          pinned = { even = { bg = Accent; fg = Base; }; odd = { bg = Sky; fg = Crust; };
            selected = { even = { bg = Crust; fg = Overlay0; }; odd = { bg = Mantle; fg = Text; }; }; };
          selected = { even = { bg = Base; fg = Text; }; odd = { bg = Base; fg = Text; }; };
        };
        tooltip = { bg = Crust; fg = Rosewater; };
      };
    };
    yazi.theme = {
      mgr = {
        cwd = { fg = Teal; };
        hovered = { fg = Base; bg = Accent; };
        preview_hovered = { fg = Base; bg = Text; };
        find_keyword = { fg = Yellow; italic = true; };
        find_position = { fg = Pink; bg = "reset"; italic = true; };
        marker_copied = { fg = Green; bg = Green; };
        marker_cut = { fg = Red; bg = Red; };
        marker_marked = { fg = Teal; bg = Teal; };
        marker_selected = { fg = Accent; bg = Accent; };
        count_copied = { fg = Base; bg = Green; };
        count_cut = { fg = Base; bg = Red; };
        count_selected = { fg = Base; bg = Accent; };
        border_symbol = "│";
        border_style = { fg = Overlay1; };
        syntect_theme = "${nix-path}/modules/hm/theme/bat-themes/${yazi-bat}.tmTheme";
      };
      tabs = { active = { fg = Base; bg = Text; bold = true; }; inactive = { fg = Text; bg = Surface1; }; };
      mode = {
        normal_main = { fg = Base; bg = Accent; bold = true; };
        normal_alt = { fg = Accent; bg = Surface0; };
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
      input = { border = { fg = Accent; }; title = {}; value = {}; selected = { reversed = true; }; };
      pick = { border = { fg = Accent; }; active = { fg = Pink; }; inactive = {}; };
      confirm = {
        border = { fg = Accent; };
        title = { fg = Accent; };
        content = {};
        list = {};
        btn_yes = { reversed = true; };
        btn_no = {};
      };
      cmp = { border = { fg = Accent; }; };
      tasks = { border = { fg = Accent; }; title = {}; hovered = { underline = true; }; };
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
          { name = "*/"; fg = Accent; }
        ];
      };
      spot = {
        border = { fg = Accent; };
        title = { fg = Accent; };
        tbl_cell = { fg = Accent; reversed = true; };
        tbl_col = { bold = true; };
      };
      icon = {
        files = let m = name: text: fg: { inherit name text fg; }; in [
          (m "kritadisplayrc" "" Mauve) (m ".gtkrc-2.0" "" Rosewater) (m "bspwmrc" "" Mantle) (m "webpack" "󰜫" Accent) (m "tsconfig.json" "" Accent)
          (m ".vimrc" "" Green) (m "gemfile$" "" Crust) (m "xmobarrc" "" Red) (m "avif" "" Overlay1)
          (m "fp-info-cache" "" Rosewater) (m ".zshrc" "" Green) (m "robots.txt" "󰚩" Overlay0) (m "dockerfile" "󰡨" Blue)
          (m ".git-blame-ignore-revs" "" Peach) (m ".nvmrc" "" Green) (m "hyprpaper.conf" "" Teal) (m ".prettierignore" "" Blue)
          (m "rakefile" "" Crust) (m "code_of_conduct" "" Red) (m "cmakelists.txt" "" Text) (m ".env" "" Yellow)
          (m "copying.lesser" "" Yellow) (m "readme" "󰂺" Rosewater) (m "settings.gradle" "" Surface2) (m "gruntfile.coffee" "" Peach)
          (m ".eslintignore" "" Surface1) (m "kalgebrarc" "" Blue) (m "kdenliverc" "" Blue) (m ".prettierrc.cjs" "" Blue)
          (m "cantorrc" "" Blue) (m "rmd" "" Accent) (m "vagrantfile$" "" Overlay0) (m ".Xauthority" "" Peach)
          (m "prettier.config.ts" "" Blue) (m "node_modules" "" Red) (m ".prettierrc.toml" "" Blue) (m "build.zig.zon" "" Peach)
          (m ".ds_store" "" Surface1) (m "PKGBUILD" "" Blue) (m ".prettierrc" "" Blue) (m ".bash_profile" "" Green)
          (m ".npmignore" "" Red) (m ".mailmap" "󰊢" Peach) (m ".codespellrc" "󰓆" Green) (m "svelte.config.js" "" Peach)
          (m "eslint.config.ts" "" Surface1) (m "config" "" Overlay1) (m ".gitlab-ci.yml" "" Red) (m ".gitconfig" "" Peach)
          (m "_gvimrc" "" Green) (m ".xinitrc" "" Peach) (m "checkhealth" "󰓙" Blue) (m "sxhkdrc" "" Mantle)
          (m ".bashrc" "" Green) (m "tailwind.config.mjs" "󱏿" Accent) (m "ext_typoscript_setup.txt" "" Peach) (m "commitlint.config.ts" "󰜘" Teal)
          (m "py.typed" "" Yellow) (m ".nanorc" "" Base) (m "commit_editmsg" "" Peach) (m ".luaurc" "" Blue)
          (m "fp-lib-table" "" Rosewater) (m ".editorconfig" "" Rosewater) (m "justfile" "" Overlay1) (m "kdeglobals" "" Blue)
          (m "license.md" "" Yellow) (m ".clang-format" "" Overlay1) (m "docker-compose.yaml" "󰡨" Blue) (m "copying" "" Yellow)
          (m "go.mod" "" Accent) (m "lxqt.conf" "" Blue) (m "brewfile" "" Crust) (m "gulpfile.coffee" "" Red)
          (m ".dockerignore" "󰡨" Blue) (m ".settings.json" "" Surface2) (m "tailwind.config.js" "󱏿" Accent) (m ".clang-tidy" "" Overlay1)
          (m ".gvimrc" "" Green) (m "nuxt.config.cjs" "󱄆" Teal) (m "xsettingsd.conf" "" Peach) (m "nuxt.config.js" "󱄆" Teal)
          (m "eslint.config.cjs" "" Surface1) (m "sym-lib-table" "" Rosewater) (m ".condarc" "" Green) (m "xmonad.hs" "" Red)
          (m "tmux.conf" "" Green) (m "xmobarrc.hs" "" Red) (m ".prettierrc.yaml" "" Blue) (m ".pre-commit-config.yaml" "󰛢" Yellow)
          (m "i3blocks.conf" "" Text) (m "xorg.conf" "" Peach) (m ".zshenv" "" Green) (m "vlcrc" "󰕼" Peach)
          (m "license" "" Yellow) (m "unlicense" "" Yellow) (m "tmux.conf.local" "" Green) (m ".SRCINFO" "󰣇" Blue)
          (m "tailwind.config.ts" "󱏿" Accent) (m "security.md" "󰒃" Subtext1) (m "security" "󰒃" Subtext1) (m ".eslintrc" "" Surface1)
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
          (m "otf" "" Rosewater) (m "import" "" Rosewater) (m "krz" "" Mauve) (m "adb" "" Teal) (m "ttf" "" Rosewater) (m "webpack" "󰜫" Accent) (m "dart" "" Surface2) (m "vsh" "" Overlay1) (m "doc" "󰈬" Surface2) (m "zsh" "" Green) (m "ex" "" Overlay1) (m "hx" "" Peach) (m "fodt" "" Accent) (m "mojo" "" Peach) (m "templ" "" Yellow) (m "nix" "" Accent) (m "cshtml" "󱦗" Surface1) (m "fish" "" Surface2) (m "ply" "󰆧" Overlay1) (m "sldprt" "󰻫" Green) (m "gemspec" "" Crust) (m "mjs" "" Yellow) (m "csh" "" Surface2) (m "cmake" "" Text) (m "fodp" "" Peach) (m "vi" "" Yellow) (m "msf" "" Blue) (m "blp" "󰺾" Blue) (m "less" "" Surface1) (m "sh" "" Surface2) (m "odg" "" Yellow) (m "mint" "󰌪" Green) (m "dll" "" Crust) (m "odf" "" Red) (m "sqlite3" "" Rosewater) (m "Dockerfile" "󰡨" Blue) (m "ksh" "" Surface2) (m "rmd" "" Accent) (m "wv" "" Accent) (m "xml" "󰗀" Peach) (m "markdown" "" Text) (m "qml" "" Green) (m "3gp" "" Peach) (m "pxi" "" Blue) (m "flac" "" Overlay0) (m "gpr" "" Mauve) (m "huff" "󰡘" Surface1) (m "json" "" Yellow) (m "gv" "󱁉" Surface2) (m "bmp" "" Overlay1) (m "lock" "" Subtext1) (m "sha384" "󰕥" Overlay1) (m "cobol" "⚙" Surface2) (m "cob" "⚙" Surface2) (m "java" "" Red) (m "cjs" "" Yellow) (m "qm" "" Sapphire) (m "ebuild" "" Surface1) (m "mustache" "" Peach) (m "terminal" "" Green) (m "ejs" "" Yellow) (m "brep" "󰻫" Green) (m "rar" "" Yellow) (m "gradle" "" Surface2) (m "gnumakefile" "" Overlay1) (m "applescript" "" Overlay1) (m "elm" "" Accent) (m "ebook" "" Peach) (m "kra" "" Mauve) (m "tf" "" Surface2) (m "xls" "󰈛" Surface2) (m "fnl" "" Yellow) (m "kdbx" "" Green) (m "kicad_pcb" "" Rosewater) (m "cfg" "" Overlay1) (m "ape" "" Accent) (m "org" "" Teal) (m "yml" "" Overlay1) (m "swift" "" Peach) (m "eln" "" Overlay0) (m "sol" "" Sapphire) (m "awk" "" Surface2) (m "7z" "" Yellow) (m "apl" "⍝" Peach) (m "epp" "" Peach) (m "app" "" Surface1) (m "dot" "󱁉" Surface2) (m "kpp" "" Mauve) (m "eot" "" Rosewater) (m "hpp" "" Overlay1) (m "spec.tsx" "" Surface2) (m "hurl" "" Red) (m "cxxm" "" Accent) (m "c" "" Blue) (m "fcmacro" "" Red) (m "sass" "" Red) (m "yaml" "" Overlay1) (m "xz" "" Yellow) (m "material" "󰔉" Overlay0) (m "json5" "" Yellow) (m "signature" "λ" Peach) (m "3mf" "󰆧" Overlay1) (m "jpg" "" Overlay1) (m "xpi" "" Peach) (m "fcmat" "" Red) (m "pot" "" Accent) (m "bin" "" Surface1) (m "xlsx" "󰈛" Surface2) (m "aac" "" Accent) (m "kicad_sym" "" Rosewater) (m "xcstrings" "" Accent) (m "lff" "" Rosewater) (m "xcf" "" Surface2) (m "azcli" "" Overlay0) (m "license" "" Yellow) (m "jsonc" "" Yellow) (m "xaml" "󰙳" Surface1) (m "md5" "󰕥" Overlay1) (m "xm" "" Accent) (m "sln" "" Surface2) (m "jl" "" Overlay1) (m "ml" "" Peach) (m "http" "" Blue) (m "x" "" Blue) (m "wvc" "" Accent) (m "wrz" "󰆧" Overlay1) (m "csproj" "󰪮" Surface1)
          (m "wrl" "󰆧" Overlay1) (m "wma" "" Accent) (m "woff2" "" Rosewater) (m "woff" "" Rosewater) (m "tscn" "" Overlay1) (m "webmanifest" "" Yellow) (m "webm" "" Peach) (m "fcbak" "" Red) (m "log" "󰌱" Text) (m "wav" "" Accent) (m "wasm" "" Surface2) (m "styl" "" Green) (m "gif" "" Overlay1) (m "resi" "" Red) (m "aiff" "" Accent) (m "sha256" "󰕥" Overlay1) (m "igs" "󰻫" Green) (m "vsix" "" Surface2) (m "vim" "" Green) (m "diff" "" Surface1) (m "drl" "" Maroon) (m "erl" "" Overlay0) (m "vhdl" "󰍛" Green) (m "🔥" "" Peach) (m "hrl" "" Overlay0) (m "fsi" "" Sapphire) (m "mm" "" Accent) (m "bz" "" Yellow) (m "vh" "󰍛" Green) (m "kdb" "" Green) (m "gz" "" Yellow) (m "cpp" "" Accent) (m "ui" "" Surface2) (m "txt" "󰈙" Green) (m "spec.ts" "" Accent) (m "ccm" "" Red) (m "typoscript" "" Peach) (m "typ" "" Teal) (m "txz" "" Yellow) (m "test.ts" "" Accent) (m "tsx" "" Surface2) (m "mk" "" Overlay1) (m "webp" "" Overlay1) (m "opus" "" Overlay0) (m "bicep" "" Sapphire) (m "ts" "" Accent) (m "tres" "" Overlay1) (m "torrent" "" Teal) (m "cxx" "" Accent) (m "iso" "" Flamingo) (m "ixx" "" Accent) (m "hxx" "" Overlay1) (m "gql" "" Red) (m "tmux" "" Green) (m "ini" "" Overlay1) (m "m3u8" "󰲹" Red) (m "image" "" Flamingo) (m "tfvars" "" Surface2) (m "tex" "" Surface1) (m "cbl" "⚙" Surface2) (m "flc" "" Rosewater) (m "elc" "" Overlay0) (m "test.tsx" "" Surface2) (m "twig" "" Green) (m "sql" "" Rosewater) (m "test.jsx" "" Accent) (m "htm" "" Peach) (m "gcode" "󰐫" Overlay0) (m "test.js" "" Yellow) (m "ino" "" Sapphire) (m "tcl" "󰛓" Surface2) (m "cljs" "" Accent) (m "tsconfig" "" Peach) (m "img" "" Flamingo) (m "t" "" Accent) (m "fcstd1" "" Red) (m "out" "" Surface1) (m "jsx" "" Accent) (m "bash" "" Green) (m "edn" "" Sapphire) (m "rss" "" Peach) (m "flf" "" Rosewater) (m "cache" "" Rosewater) (m "sbt" "" Red) (m "cppm" "" Accent) (m "svelte" "" Peach) (m "mo" "∞" Overlay1) (m "sv" "󰍛" Green) (m "ko" "" Rosewater) (m "suo" "" Surface2) (m "sldasm" "󰻫" Green) (m "icalendar" "" Surface0) (m "go" "" Sapphire) (m "sublime" "" Peach) (m "stl" "󰆧" Overlay1) (m "mobi" "" Peach) (m "graphql" "" Red) (m "m3u" "󰲹" Red) (m "cpy" "⚙" Surface2) (m "kdenlive" "" Blue) (m "pyo" "" Yellow) (m "po" "" Sapphire) (m "scala" "" Red) (m "exs" "" Overlay1) (m "odp" "" Peach) (m "dump" "" Rosewater) (m "stp" "󰻫" Green) (m "step" "󰻫" Green) (m "ste" "󰻫" Green) (m "aif" "" Accent) (m "strings" "" Accent) (m "cp" "" Accent) (m "fsscript" "" Accent) (m "mli" "" Peach) (m "bak" "󰁯" Overlay1) (m "ssa" "󰨖" Yellow) (m "toml" "" Red) (m "makefile" "" Overlay1) (m "php" "" Overlay1) (m "zst" "" Yellow) (m "spec.jsx" "" Accent) (m "kbx" "󰯄" Overlay0) (m "fbx" "󰆧" Overlay1) (m "blend" "󰂫" Peach) (m "ifc" "󰻫" Green) (m "spec.js" "" Yellow) (m "so" "" Rosewater)
          (m "desktop" "" Surface1) (m "sml" "λ" Peach) (m "slvs" "󰻫" Green) (m "pp" "" Peach) (m "ps1" "󰨊" Overlay0) (m "dropbox" "" Overlay0) (m "kicad_mod" "" Rosewater) (m "bat" "" Green) (m "slim" "" Peach) (m "skp" "󰻫" Green) (m "css" "" Blue) (m "xul" "" Peach) (m "ige" "󰻫" Green) (m "glb" "" Peach) (m "ppt" "󰈧" Red) (m "sha512" "󰕥" Overlay1) (m "ics" "" Surface0) (m "mdx" "" Accent) (m "sha1" "󰕥" Overlay1) (m "f3d" "󰻫" Green) (m "ass" "󰨖" Yellow) (m "godot" "" Overlay1) (m "ifb" "" Surface0) (m "cson" "" Yellow) (m "lib" "" Crust) (m "luac" "" Accent) (m "heex" "" Overlay1) (m "scm" "󰘧" Rosewater) (m "psd1" "󰨊" Overlay0) (m "sc" "" Red) (m "scad" "" Yellow) (m "kts" "" Overlay0) (m "svh" "󰍛" Green) (m "mts" "" Accent) (m "nfo" "" Yellow) (m "pck" "" Overlay1) (m "rproj" "󰗆" Green) (m "rlib" "" Peach) (m "cljd" "" Accent) (m "ods" "" Green) (m "res" "" Red) (m "apk" "" Green) (m "haml" "" Rosewater) (m "d.ts" "" Peach) (m "razor" "󱦘" Surface1) (m "rake" "" Crust) (m "patch" "" Surface1) (m "cuh" "" Overlay1) (m "d" "" Red) (m "query" "" Green) (m "psb" "" Accent) (m "nu" ">" Green) (m "mov" "" Peach) (m "lrc" "󰨖" Yellow) (m "pyx" "" Blue) (m "pyw" "" Blue) (m "cu" "" Green) (m "bazel" "" Green) (m "obj" "󰆧" Overlay1) (m "pyi" "" Yellow) (m "pyd" "" Yellow) (m "exe" "" Surface1) (m "pyc" "" Yellow) (m "fctb" "" Red) (m "part" "" Teal) (m "blade.php" "" Red) (m "git" "" Peach) (m "psd" "" Accent) (m "qss" "" Green) (m "csv" "" Green) (m "psm1" "󰨊" Overlay0) (m "dconf" "" Rosewater) (m "config.ru" "" Crust) (m "prisma" "" Overlay0) (m "conf" "" Overlay1) (m "clj" "" Green) (m "o" "" Surface1) (m "mp4" "" Peach) (m "cc" "" Red) (m "kicad_prl" "" Rosewater) (m "bz3" "" Yellow) (m "asc" "󰦝" Surface2) (m "png" "" Overlay1) (m "android" "" Green) (m "pm" "" Accent) (m "h" "" Overlay1) (m "pls" "󰲹" Red) (m "ipynb" "" Peach) (m "pl" "" Accent) (m "ads" "" Rosewater) (m "sqlite" "" Rosewater) (m "pdf" "" Red) (m "pcm" "" Overlay0) (m "ico" "" Yellow) (m "a" "" Rosewater) (m "R" "󰟔" Surface2) (m "ogg" "" Overlay0) (m "pxd" "" Blue) (m "kdenlivetitle" "" Blue) (m "jxl" "" Overlay1) (m "nswag" "" Green) (m "nim" "" Yellow) (m "bqn" "⎉" Surface2) (m "cts" "" Accent) (m "fcparam" "" Red) (m "rs" "" Peach) (m "mpp" "" Accent) (m "fdmdownload" "" Teal) (m "pptx" "󰈧" Red) (m "jpeg" "" Overlay1) (m "bib" "󱉟" Yellow) (m "vhd" "󰍛" Green) (m "m" "" Blue) (m "js" "" Yellow) (m "eex" "" Overlay1) (m "tbc" "󰛓" Surface2) (m "astro" "" Red) (m "sha224" "󰕥" Overlay1) (m "xcplayground" "" Peach) (m "el" "" Overlay0) (m "m4v" "" Peach) (m "m4a" "" Accent) (m "cs" "󰌛" Green) (m "hs" "" Overlay1) (m "tgz" "" Yellow) (m "fs" "" Accent) (m "luau" "" Blue)
          (m "dxf" "󰻫" Green) (m "download" "" Teal) (m "cast" "" Peach) (m "qrc" "" Green) (m "lua" "" Accent) (m "lhs" "" Overlay1) (m "md" "" Text) (m "leex" "" Overlay1) (m "ai" "" Yellow) (m "lck" "" Subtext1) (m "kt" "" Overlay0) (m "bicepparam" "" Overlay1) (m "hex" "" Overlay0) (m "zig" "" Peach) (m "bzl" "" Green) (m "cljc" "" Green) (m "kicad_dru" "" Rosewater) (m "fctl" "" Red) (m "f#" "" Accent) (m "odt" "" Accent) (m "conda" "" Green) (m "vala" "" Surface2) (m "erb" "" Crust) (m "mp3" "" Accent) (m "bz2" "" Yellow) (m "coffee" "" Yellow) (m "cr" "" Rosewater) (m "f90" "󱈚" Surface2) (m "jwmrc" "" Overlay0) (m "c++" "" Red) (m "fcscript" "" Red) (m "fods" "" Green) (m "cue" "󰲹" Red) (m "srt" "󰨖" Yellow) (m "info" "" Yellow) (m "hh" "" Overlay1) (m "sig" "λ" Peach) (m "html" "" Peach) (m "iges" "󰻫" Green) (m "kicad_wks" "" Rosewater) (m "hbs" "" Peach) (m "fcstd" "" Red) (m "gresource" "" Rosewater) (m "sub" "󰨖" Yellow) (m "ical" "" Surface0) (m "crdownload" "" Teal) (m "pub" "󰷖" Yellow) (m "vue" "" Green) (m "gd" "" Overlay1) (m "fsx" "" Accent) (m "mkv" "" Peach) (m "py" "" Yellow) (m "kicad_sch" "" Rosewater) (m "epub" "" Peach) (m "env" "" Yellow) (m "magnet" "" Surface1) (m "elf" "" Surface1) (m "fodg" "" Yellow) (m "svg" "󰜡" Peach) (m "dwg" "󰻫" Green) (m "docx" "󰈬" Surface2) (m "pro" "" Yellow) (m "db" "" Rosewater) (m "rb" "" Crust) (m "r" "󰟔" Surface2) (m "scss" "" Red) (m "cow" "󰆚" Peach) (m "gleam" "" Pink) (m "v" "󰍛" Green) (m "kicad_pro" "" Rosewater) (m "liquid" "" Green) (m "zip" "" Yellow)
        ];
      };
    };
    wlogout.style = ''
      * {
      	background-image: none;
      	box-shadow: none;
      }

      window {
      	background-color: ${wlogout-base};
      }

      button {
      	border-radius: 0;
      	border-color: ${Accent};
      	text-decoration-color: ${Text};
      	color: ${Text};
      	background-color: ${Mantle};
      	border-style: solid;
      	border-width: 1px;
      	background-repeat: no-repeat;
      	background-position: center;
      	background-size: 25%;
      }

      button:focus, button:active, button:hover {
      	background-color: ${wlogout-button};
      	outline-style: none;
      }

      #shutdown {
            background-image: url("${wlogout-icon-shutdown}");
      }
      #suspend {
            background-image: url("${wlogout-icon-suspend}");
      }
      #lock {
            background-image: url("${wlogout-icon-lock}");
      }
      #hibernate {
            background-image: url("${wlogout-icon-hibernate}");
      }
      #logout {
            background-image: url("${wlogout-icon-logout}");
      }
      #reboot {
            background-image: url("${wlogout-icon-reboot}");
      }
    '';

    wezterm = {
      extraConfig = ''
        return {
          font = wezterm.font("${MonoSpace}"),
          font_size = ${toString MonoSizeWezterm},
          color_scheme = "nix",
          tab_bar_at_bottom = true,
          hide_tab_bar_if_only_one_tab = true,
          window_frame = {
              active_titlebar_bg = "${Base}",
              active_titlebar_fg = "${Text}",
              font_size = ${toString MonoSizeWezterm},
              active_titlebar_border_bottom = "${Accent}",
              border_left_color = "${Accent}",
              border_right_color = "${Accent}",
              border_bottom_color = "${Accent}",
              border_top_color = "${Accent}",
              button_bg = "${Overlay0}",
              button_fg = "${Text}",
              button_hover_bg = "${Rosewater}",
              button_hover_fg = "${Crust}",
              inactive_titlebar_bg = "${Base}",
              inactive_titlebar_fg = "${Text}",
              inactive_titlebar_border_bottom = "${Surface0}",
          },
          colors = {
            tab_bar = {
              background = "${Base}",
              inactive_tab_edge = "${Surface0}",
              active_tab = {
                bg_color = "${starship6}",
                fg_color = "${Text}",
              },
              inactive_tab = {
                bg_color = "${starship1}",
                fg_color = "${Text}",
              },
              inactive_tab_hover = {
                bg_color = "${Base}",
                fg_color = "${Text}",
              },
              new_tab = {
                bg_color = "${Surface0}",
                fg_color = "${Text}",
              },
              new_tab_hover = {
                bg_color = "${Surface0}",
                fg_color = "${Text}",
              },
            },
          },
          command_palette_bg_color = "${Base}",
          command_palette_fg_color = "${Text}",
        }
      '';

      colorSchemes = {
        nix =  {
          ansi = [
            Surface1
            Red
            Green
            Yellow
            Blue
            Pink
            Teal
            Subtext1
          ];
          brights = [
            Surface1
            Red
            Green
            Yellow
            Blue
            Pink
            Teal
            Subtext1
          ];
          background = Base;
          cursor_bg = Rosewater;
          cursor_fg = Accent;
          compose_cursor = Flamingo;
          foreground = Text;
          scrollbar_thumb = Accent;
          selection_bg = Rosewater;
          selection_fg = Crust;
          split = Overlay1;
          visual_bell = Surface0;
          tab_bar = {
            background = Crust;
            inactive_tab_edge = Surface0;
            active_tab = {
              bg_color = Accent;
              fg_color = Crust;
            };
            inactive_tab = {
              bg_color = Mantle;
              fg_color = Text;
            };
            inactive_tab_hover = {
              bg_color = Base;
              fg_color = Text;
            };
            new_tab = {
              bg_color = Surface0;
              fg_color = Text;
            };
            new_tab_hover = {
              bg_color = Surface0;
              fg_color = Text;
            };
          };
        };
      };
    };

    hyprlock = {
      settings = {
        general = {
          hide_cursor = true;
        };
        background = [
          {
            monitor = "";
            path = "$HOME/.config/background";
            blur_passes = 0;
            color = rgb-Base;
          }
        ];
        label = [
          {
            monitor = "";
            text = "Layout: $LAYOUT";
            color = rgb-Text;
            font_size = 25;
            font_family = Sans;
            position = "30, -30";
            halign = "left";
            valign = "top";
          }
          {
            monitor = "";
            text = "$TIME";
            color = rgb-Text;
            font_size = 90;
            font_family = Sans;
            position = "-30, 0";
            halign = "right";
            valign = "top";
          }
          {
            monitor = "";
            text = ''cmd[update:43200000] date +"%A, %d %B %Y"'';
            color = rgb-Text;
            font_size = 25;
            font_family = Sans;
            position = "-30, -150";
            halign = "right";
            valign = "top";
          }
          {
            monitor = "";
            text = "$FPRINTPROMPT";
            color = "$text";
            font_size = 14;
            font_family = Sans;
            position = "0, -107";
            halign = "center";
            valign = "center";
          }
        ];
        image = [
          {
            monitor = "";
            path = "$HOME/.face";
            size = 100;
            border_color = rgb-Accent;
            position = "0, 75";
            halign = "center";
            valign = "center";
          }
        ];
        input-field = [
          {
            monitor = "";
            size = "300, 60";
            outline_thickness = 4;
            dots_size = 0.2;
            dots_spacing = 0.2;
            dots_center = true;
            outer_color = rgb-Accent;
            inner_color = rgb-Surface0;
            font_color = rgb-Text;
            fade_on_empty = false;
            placeholder_text = ''<span foreground="##${alt-Text}"><i>󰌾 Logged in as </i><span foreground="##${alt-Accent}">$USER</span></span>'';
            hide_input = false;
            check_color = rgb-Accent;
            fail_color = rgb-Red;
            fail_text = ''<i>$FAIL <b>($ATTEMPTS)</b></i>'';
            capslock_color = rgb-Yellow;
            position = "0, -47";
            halign = "center";
            valign = "center";
          }
        ];
      };
     #extraConfig = '' '';
    };
    cavalier.settings.general = {
      ColorProfiles = lib.singleton {
        Name = "nix";
        FgColors = [ Accent ];
        BgColors = [ Base ];
      };
      ActiveProfile = 0;
    };

    tint2.extraConfig = ''
      # Hardcoded for 1366px
      # Backgrounds
      # Background 1: Panel
      rounded = 0
      border_width = 0
      border_sides =
      border_content_tint_weight = 0
      background_content_tint_weight = 0
      background_color = #000000 0
      border_color = #000000 0
      background_color_hover = #000000 0
      border_color_hover = #000000 0
      background_color_pressed = #000000 0
      border_color_pressed = #000000 0
      # Background 2: Default task, Iconified task
      rounded = 2
      border_width = 0
      border_sides = TBLR
      border_content_tint_weight = 0
      background_content_tint_weight = 0
      background_color = ${Subtext1} 100
      border_color = #000000 0
      background_color_hover = ${Rosewater} 22
      border_color_hover = #000000 0
      background_color_pressed = ${Accent} 100
      border_color_pressed = #000000 0
      # Background 3: Active task
      rounded = 2
      border_width = 0
      border_sides = TBLR
      border_content_tint_weight = 0
      background_content_tint_weight = 0
      background_color = ${Accent} 100
      border_color = #000000 0
      background_color_hover = ${Accent} 70
      border_color_hover = #000000 0
      background_color_pressed = ${Accent} 100
      border_color_pressed = #000000 0
      # Background 4: Urgent task
      rounded = 2
      border_width = 0
      border_sides = TBLR
      border_content_tint_weight = 0
      background_content_tint_weight = 0
      background_color = ${Red} 100
      border_color = #000000 0
      background_color_hover = ${Red} 70
      border_color_hover = #000000 0
      background_color_pressed = ${Red} 100
      border_color_pressed = #000000 0
      # Panel
      panel_items = T
      panel_size = 50% 2%
      panel_margin = 0 0
      panel_padding = 2 1 2
      panel_background_id = 1
      wm_menu = 1
      panel_dock = 0
      panel_position = bottom center horizontal
      panel_layer = top
      panel_monitor = all
      panel_shrink = 0
      autohide = 0
      autohide_show_timeout = 0
      autohide_hide_timeout = 0.5
      autohide_height = 2
      strut_policy = follow_size
      panel_window_name = tint2
      disable_transparency = 0
      mouse_effects = 1
      font_shadow = 0
      mouse_hover_icon_asb = 100 0 10
      mouse_pressed_icon_asb = 100 0 0
      # Taskbar
      taskbar_mode = multi_desktop
      taskbar_hide_if_empty = 0
      taskbar_padding = 6 4 4
      taskbar_background_id = 0
      taskbar_active_background_id = 0
      taskbar_name = 0
      taskbar_hide_inactive_tasks = 0
      taskbar_hide_different_monitor = 0
      taskbar_hide_different_desktop = 0
      taskbar_always_show_all_desktop_tasks = 1
      taskbar_name_padding = 2 2
      taskbar_name_background_id = 0
      taskbar_name_active_background_id = 0
      taskbar_name_font_color = #e3e3e3 0
      taskbar_name_active_font_color = #ffffff 0
      taskbar_distribute_size = 0
      taskbar_sort_order = none
      task_align = center
      # Task
      task_text = 1
      task_icon = 1
      task_centered = 1
      urgent_nb_of_blink = 100000
      task_maximum_size = 150 35
      task_padding = 2 2 4
      task_tooltip = 0
      task_thumbnail = 0
      task_thumbnail_size = 210
      task_font_color = #ffffff 0
      task_background_id = 2
      task_active_background_id = 3
      task_urgent_background_id = 4
      task_iconified_background_id = 2
      mouse_left = toggle_iconify
      mouse_middle = close
      mouse_right = maximize_restore
      mouse_scroll_up = next_task
      mouse_scroll_down = prev_task
    '';

    hyprpanel.settings = {
      theme = {
        matugen_settings = {
          mode = scheme;
          scheme_type = "tonal-spot";
        };
        bar = {
          menus = {
            menu = {
              notifications = {
                scrollbar = { color = Lavender; };
                pager = { label = Overlay2; button = Lavender; background = Crust; };
                switch = { puck = Surface1; disabled = Surface0; enabled = Lavender; };
                clear = Red; switch_divider = Surface1; border = Surface0; card = Mantle; background = Crust; no_notifications_label = Surface0; label = Lavender; scaling = 75;
              };
              power = {
                buttons = {
                  sleep = { icon = Crust; text = Sky; icon_background = Sky; background = Mantle; };
                  logout = { icon = Crust; text = Yellow; icon_background = Yellow; background = Mantle; };
                  restart = { icon = Crust; text = Peach; icon_background = Peach; background = Mantle; };
                  shutdown = { icon = Crust; text = Red; icon_background = Red; background = Mantle; };
                };
                card.color = Base; border.color = Surface0; background.color = Crust; scaling = 75;
              };
              dashboard = {
                monitors = {
                  disk = { label = Pink; bar = Pink; icon = Pink; };
                  gpu = { label = Yellow; bar = Yellow; icon = Yellow; };
                  ram = { label = Yellow; bar = Yellow; icon = Yellow; };
                  cpu = { label = Maroon; bar = Maroon; icon = Maroon; };
                  bar_background = Surface1;
                };
                directories = {
                  right = { bottom.color = Lavender; middle.color = Pink; top.color = Teal; };
                  left = { bottom.color = Maroon; middle.color = Yellow; top.color = Pink; };
                };
                controls = {
                  input = { text = Crust; background = Pink; };
                  volume = { text = Crust; background = Maroon; };
                  notifications = { text = Crust; background = Yellow; };
                  bluetooth = { text = Crust; background = Sky; };
                  wifi = { text = Crust; background = Pink; };
                  disabled = Surface2;
                };
                shortcuts = { recording = Yellow; text = Crust; background = Lavender; };
                powermenu = {
                  confirmation = {
                    button_text = Crust; deny = Red;
                    confirm = Yellow; body = Text; label = Lavender;
                    border = Surface0; background = Crust; card = Mantle;
                  };
                  sleep = Sky; logout = Yellow; restart = Peach; shutdown = Red;
                };
                profile.name = Pink; border.color = Surface0; background.color = Crust; card.color = Mantle; scaling = 70; confirmation_scaling = 75;
              };
              clock = {
                weather = {
                  hourly = { temperature = Pink; icon = Pink; time = Pink; };
                  thermometer = { extremelycold = Sky; cold = Blue; moderate = Lavender; hot = Peach; extremelyhot = Red; };
                  stats = Pink; status = Teal; temperature = Text; icon = Pink; scaling = 75;
                };
                calendar = { contextdays = Surface2; days = Text; currentday = Pink; paginator = Pink; weekdays = Pink; yearmonth = Teal; };
                time = { timeperiod = Teal; time = Pink; };
                text = Text; border.color = Surface0; background.color = Crust; card.color = Mantle; scaling = 75;
              };
              battery = {
                slider = { puck = Overlay0; backgroundhover = Surface1; background = Surface2; primary = Yellow; };
                icons = { active = Yellow; passive = Overlay2; };
                listitems = { active = Yellow; passive = Text; };
                text = Text; label.color = Yellow; border.color = Surface0; background.color = Crust; card.color = Mantle; scaling = 75;
              };
              systray = { dropdownmenu = { divider = Mantle; text = Text; background = Crust; }; };
              bluetooth = {
                iconbutton = { active = Sky; passive = Text; };
                icons = { active = Sky; passive = Overlay2; };
                listitems = { active = Sky; passive = Text; };
                switch = { puck = Surface1; disabled = Surface0; enabled = Sky; };
                switch_divider = Surface1; status = Overlay0; text = Text;
                label.color = Sky; scroller.color = Sky; border.color = Surface0;
                background.color = Crust; card.color = Mantle; scaling = 75;
              };
              network = {
                switch = { enabled = Pink; disabled = Surface0; puck = Surface1; };
                iconbuttons = { active = Pink; passive = Text; };
                icons = { active = Pink; passive = Overlay2; };
                listitems = { active = Pink; passive = Text; };
                status.color = Overlay0; text = Text; label.color = Pink; card.color = Mantle;
                scroller.color = Pink; border.color = Surface0; background.color = Crust; scaling = 75;
              };
              volume = {
                input_slider = { puck = Surface2; backgroundhover = Surface1; background = Surface2; primary = Maroon; };
                audio_slider = { puck = Surface2; backgroundhover = Surface1; background = Surface2; primary = Maroon; };
                icons = { active = Maroon; passive = Overlay2; }; iconbutton = { active = Maroon; passive = Text; };
                listitems = { active = Maroon; passive = Text; };
                text = Text; label.color = Maroon; border.color = Surface0; background.color = Crust; card.color = Mantle; scaling = 75;
              };
              media = {
                slider = { puck = Overlay0; backgroundhover = Surface1; background = Surface2; primary = Pink; };
                buttons = { text = Crust; background = Lavender; enabled = Teal; inactive = Surface2; };
                border.color = Surface0; card.color = Mantle; background.color = Crust;
                album = Pink; timestamp = Text; artist = Teal; song = Lavender; scaling = 75;
              };
            };
            tooltip = { text = Text; background = Crust; };
            dropdownmenu = { divider = Mantle; text = Text; background = Crust; };
            slider = { puck = Overlay0; backgroundhover = Surface1; background = Surface2; primary = Lavender; };
            progressbar = { background = Surface1; foreground = Lavender; };
            iconbuttons = { active = Lavender; passive = Text; };
            buttons = { text = Crust; disabled = Surface2; active = Pink; default = Lavender; };
            check_radio_button = { active = Subtext1; background = Crust; };
            switch = { puck = Surface1; disabled = Surface0; enabled = Lavender; };
            icons = { active = Lavender; passive = Surface2; };
            listitems = { active = Lavender; passive = Text; };
            popover = { border = Crust; background = Crust; text = Lavender; scaling = 75; };
            label = Lavender; feinttext = Surface0; dimtext = Surface2; text = Text;
            border.color = Surface0; cards = Mantle; background = Crust;
          };
          buttons = {
            style = "split"; background = Base; borderColor = Lavender;
            modules = {
              power = { icon_background = Red; icon = Crust; background = Base; border = Red; };
              weather = { icon_background = Lavender; icon = Base; text = Lavender; background = Base; border = Lavender; };
              updates = { icon_background = Pink; icon = Crust; text = Pink; background = Base; border = Pink; };
              kbLayout = { icon_background = Sky; icon = Crust; text = Sky; background = Base; border = Sky; };
              netstat = { icon_background = Yellow; icon = Crust; text = Yellow; background = Base; border = Yellow; };
              storage = { icon_background = Red; icon = Crust; text = Red; background = Base; border = Red; };
              cpu = { icon_background = Red; icon = Crust; text = Red; background = Base; border = Red; };
              ram = { icon_background = Yellow; icon = Crust; text = Yellow; background = Base; border = Yellow; };
              submap = { icon = Crust; background = Base; icon_background = Teal; text = Teal; border = Teal; };
              hyprsunset = { icon = Crust; background = Base; icon_background = Yellow; text = Yellow; border = Yellow; };
              hypridle = { icon = Crust; background = Base; icon_background = Red; text = Red; border = Red; };
              cava = { text = Teal; background = Base; icon_background = Teal; icon = Crust; border = Teal; };
              worldclock = { text = Pink; background = Base; icon_background = Pink; icon = Base; border = Pink; };
              microphone = { border = Yellow; background = Base; text = Yellow; icon = Base; icon_background = Yellow; };
              cpuTemp = { icon_background = Orange; icon = Orange; text = Orange; border = Orange; hover = Surface1; };
            };
            notifications = { total = Lavender; icon_background = Subtext1; icon = Base; background = Base; border = Lavender; hover = Brown; };
            clock = { icon_background = Pink; icon = Base; text = Pink; background = Base; border = Pink; hover = Brown; };
            battery = { icon_background = Yellow; icon = Base; text = Yellow; background = Base; border = Yellow; hover = Brown; };
            systray = { background = Base; border = Surface1; customIcon = Text; hover = Brown; };
            bluetooth = { icon_background = Sky; icon = Base; text = Sky; background = Base; border = Sky; hover = Brown; };
            network = { icon_background = Mauve; icon = Base; text = Pink; background = Base; border = Pink; hover = Brown; };
            volume = { icon_background = Pink; icon = Base; text = Maroon; background = Base; border = Maroon; hover = Brown; };
            media = { icon_background = Subtext1; icon = Base; text = Lavender; background = Base; border = Lavender; hover = Brown; };
            windowtitle = { icon_background = Pink; icon = Base; text = Pink; border = Pink; background = Base; hover = Brown; };
            workspaces = { numbered_active_underline_color = Pink; numbered_active_highlighted_text_color = Crust; numbered_active_text_color = Base;
              hover = Pink; active = Pink; occupied = Rosewater; available = Teal; border = Pink; background = Base;
            };
            dashboard = { icon = Base; border = Accent; background = Accent; hover = Brown; };
            icon = Base; text = Lavender; hover = Surface1; icon_background = Lavender;
            volume = { output_icon = Black; output_text = Pink; input_icon = Black; input_text = Pink; separator = Surface1; };
          };
          osd = { background = Crust; label = Lavender; icon = Crust; bar_overflow_color = Red; scaling = 75;
            bar_empty_color = Surface0; bar_color = Lavender; icon_container = Lavender; bar_container = Crust; border.color = Green;
          };
          nofication = {
            close_button = { label = Crust; background = Red; };
            labelicon = Lavender; background = Crust; text = Text;
            time = Overlay1; border = Surface0; label = Lavender;
            actions = { text = Crust; background = Lavender; };
          };
          border.color = Lavender; scaling = 75; notification.scaling = 75;
        };
        font = { name = Sans; label = "${Sans} Bold"; };
        tooltip = { scaling = 75; };
      };
    };

   #btop.settings = { color_theme = "catppuccin_${flavor}.theme"; };
  };

 #my.poly-height = "18";
  my.poly-height = "22";
  my.poly-name = "example";

  services = {
    picom = lib.mkIf config.services.picom.enable {
      settings = {
        shadow-color = "#000000";
        corner-radius = 10;
        shadow-radius = 20;
      };
      extraConfig = '' '';
    };
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
        "bar/${config.my.poly-name}" = {
          background = Base;
          foreground = Text;
         #height = "${config.my.poly-height}pt";
          height = "3.8%";
          offset-y = "1%";
          offset-x = "0.5%";
          line-size = "2pt";
          line-color = Accent;
          width = "99%";
         #radius = 6;
          radius = 0;
         #border-size = "4pt";
          border-size = "0pt";
          border-color = Mantle;
          padding-left = 2;
          padding-right = 2;
          module-margin = 1;
          separator = "|";
          separator-foreground = Base;
          font-0 = Poly1;
          font-1 = PolySymbols;
          font-2 = Poly2;
          font-3 = Poly3;
          font-4 = PolyEmoji;
         #font-1 = "FontAwesome:size=12;3";
         #font-2 = "Hack Nerd Font:size=12;3";
        };
        "module/xwindow" = {
          format-prefix-foreground = Accent;
        };
        "module/xworkspaces" = {
          label = {
            active = {
             #foreground = Base;
              foreground = Accent;
             #background = Accent;
              background = Base;
              underline= Accent;
             #underline= Base;
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
          label-foreground = Accent;
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
        "module/light" = {
          ramp-0 = "󰽤"; # "🌑";
          ramp-1 = "󰽥"; # "🌒";
          ramp-2 = "󰽣"; # "🌓";
          ramp-3 = "󰽦"; # "🌔";
          ramp-4 = "󰽢"; # "🌕";
        };
        "module/temp" = {
          ramp-0 = "󱟯";
          ramp-1 = "󱟮";
          ramp-2 = "󰞴";
          ramp-3 = "󰞳";
          ramp-4 = "󰞲";
          ramp-5 = "󱟫";
          label-warn-foreground = "${Yellow}";
          ramp-0-foreground = "${Blue}";
          ramp-1-foreground = "${Green}";
          ramp-2-foreground = "${Yellow}";
          ramp-3-foreground = "${Maroon}";
          ramp-4-foreground = "${Red}";
          ramp-5-foreground = "${Red}";
        };
        "module/battery" = {
          ramp-capacity-0 = "";
          ramp-capacity-1 = "";
          ramp-capacity-2 = "";
          ramp-capacity-3 = "";
          ramp-capacity-4 = "";
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
         #frame_color = Accent;
        };
        urgency_critical = {
         #background = Red;
         #foreground = Crust;
         #frame_color = Yellow;
        };
        play_sound = {
          summary = "*";
          script = "${dunst-sound}/bin/dunst-sound";
        };
      };
     #iconTheme = {
     #  package = ;
     #  name = ;
     #  size = ;
     #};
    };

    swaync = {
     #settings = { };
      style = ''
        * {
          all: unset;
          font-size: 14px;
          font-family: "${Sans}";
          transition: 200ms;
        }
        trough highlight { background: ${Text}; }
        scale trough {
          margin: 0rem 1rem;
          background-color: ${Surface0};
          min-height: 8px;
          min-width: 70px;
        }
        slider { background-color: ${Blue}; }
        .floating-notifications.background .notification-row .notification-background {
          box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px ${Surface0};
          border-radius: 12.6px;
          margin: 18px;
          background-color: ${Base};
          color: ${Text};
          padding: 0;
        }
        .floating-notifications.background .notification-row .notification-background .notification { padding: 7px; border-radius: 12.6px; }
        .floating-notifications.background .notification-row .notification-background .notification.critical { box-shadow: inset 0 0 7px 0 ${Red}; }
        .floating-notifications.background .notification-row .notification-background .notification .notification-content { margin: 7px; }
        .floating-notifications.background .notification-row .notification-background .notification .notification-content .summary { color: ${Text}; }
        .floating-notifications.background .notification-row .notification-background .notification .notification-content .time { color: ${Subtext0}; }
        .floating-notifications.background .notification-row .notification-background .notification .notification-content .body { color: ${Text}; }
        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * { min-height: 3.4em; }
        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
          border-radius: 7px;
          color: ${Text};
          background-color: ${Surface0};
          box-shadow: inset 0 0 0 1px ${Subtext1};
          margin: 7px;
        }
        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
          box-shadow: inset 0 0 0 1px ${Subtext1};
          background-color: ${Surface0};
          color: ${Text};
        }
        .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
          box-shadow: inset 0 0 0 1px ${Subtext1};
          background-color: ${Accent};
          color: ${Text};
        }
        .floating-notifications.background .notification-row .notification-background .close-button {
          margin: 7px;
          padding: 2px;
          border-radius: 6.3px;
          color: ${Base};
          background-color: ${Red};
        }
        .floating-notifications.background .notification-row .notification-background .close-button:hover {
          background-color: ${Maroon};
          color: ${Base};
        }
        .floating-notifications.background .notification-row .notification-background .close-button:active {
          background-color: ${Red};
          color: ${Base};
        }
        .control-center {
          box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px ${Surface0};
          border-radius: 12.6px;
          margin: 18px;
          background-color: ${Base};
          color: ${Text};
          padding: 14px;
        }
        .control-center .widget-title > label { color: ${Text}; font-size: 1.3em; }
        .control-center .widget-title button {
          border-radius: 7px;
          color: ${Text};
          background-color: ${Surface0};
          box-shadow: inset 0 0 0 1px ${Subtext1};
          padding: 8px;
        }
        .control-center .widget-title button:hover {
          box-shadow: inset 0 0 0 1px ${Subtext1};
          background-color: ${Surface2};
          color: ${Text};
        }
        .control-center .widget-title button:active {
          box-shadow: inset 0 0 0 1px ${Subtext1};
          background-color: ${Accent};
          color: ${Base};
        }
        .control-center .notification-row .notification-background {
          border-radius: 7px;
          color: ${Text};
          background-color: ${Surface0};
          box-shadow: inset 0 0 0 1px ${Subtext1};
          margin-top: 14px;
        }
        .control-center .notification-row .notification-background .notification { padding: 7px; border-radius: 7px; }
        .control-center .notification-row .notification-background .notification.critical { box-shadow: inset 0 0 7px 0 ${Red}; }
        .control-center .notification-row .notification-background .notification .notification-content { margin: 7px; }
        .control-center .notification-row .notification-background .notification .notification-content .summary { color: ${Text}; }
        .control-center .notification-row .notification-background .notification .notification-content .time { color: ${Subtext0}; }
        .control-center .notification-row .notification-background .notification .notification-content .body { color: ${Text}; }
        .control-center .notification-row .notification-background .notification > *:last-child > * { min-height: 3.4em; }
        .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
          border-radius: 7px;
          color: ${Text};
          background-color: ${Crust};
          box-shadow: inset 0 0 0 1px ${Subtext1};
          margin: 7px;
        }
        .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
          box-shadow: inset 0 0 0 1px ${Subtext1};
          background-color: ${Surface0};
          color: ${Text};
        }
        .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
          box-shadow: inset 0 0 0 1px ${Subtext1};
          background-color: ${Accent};
          color: ${Text};
        }
        .control-center .notification-row .notification-background .close-button {
          margin: 7px;
          padding: 2px;
          border-radius: 6.3px;
          color: ${Base};
          background-color: ${Maroon};
        }
        .close-button { border-radius: 6.3px; }
        .control-center .notification-row .notification-background .close-button:hover {
          background-color: ${Red};
          color: ${Base};
        }
        .control-center .notification-row .notification-background .close-button:active {
          background-color: ${Red};
          color: ${Base};
        }
        .control-center .notification-row .notification-background:hover {
          box-shadow: inset 0 0 0 1px ${Subtext1};
          background-color: ${Overlay1};
          color: ${Text};
        }
        .control-center .notification-row .notification-background:active {
          box-shadow: inset 0 0 0 1px ${Subtext1};
          background-color: ${Accent};
          color: ${Text};
        }
        .notification.critical progress { background-color: ${Red}; }
        .notification.low progress,
        .notification.normal progress {
          background-color: ${Blue};
        }
        .control-center-dnd {
          margin-top: 5px;
          border-radius: 8px;
          background: ${Surface0};
          border: 1px solid ${Subtext1};
          box-shadow: none;
        }
        .control-center-dnd:checked { background: ${Surface0}; }
        .control-center-dnd slider { background: ${Subtext1}; border-radius: 8px; }
        .widget-dnd { margin: 0px; font-size: 1.1rem; }
        .widget-dnd > switch {
          font-size: initial;
          border-radius: 8px;
          background: ${Surface0};
          border: 1px solid ${Subtext1};
          box-shadow: none;
        }
        .widget-dnd > switch:checked { background: ${Surface0}; }
        .widget-dnd > switch slider {
          background: ${Subtext1};
          border-radius: 8px;
          border: 1px solid ${Overlay0};
        }
        .widget-mpris .widget-mpris-player { background: ${Surface0}; padding: 7px; }
        .widget-mpris .widget-mpris-title { font-size: 1.2rem; }
        .widget-mpris .widget-mpris-subtitle { font-size: 0.8rem; }
        .widget-menubar > box > .menu-button-bar > button > label { font-size: 3rem; padding: 0.5rem 2rem; }
        .widget-menubar > box > .menu-button-bar > :last-child { color: ${Red}; }
        .power-buttons button:hover,
        .powermode-buttons button:hover,
        .screenshot-buttons button:hover { background: ${Surface0}; }
        .control-center .widget-label > label { color: ${Text}; font-size: 2rem; }
        .widget-buttons-grid { padding-top: 1rem; }
        .widget-buttons-grid > flowbox > flowboxchild > button label { font-size: 2.5rem; }
        .widget-volume { padding-top: 1rem; }
        .widget-volume label { font-size: 1.5rem; color: ${Accent}; }
        .widget-volume trough highlight { background: ${Accent}; }
        .widget-backlight trough highlight { background: ${Yellow}; }
        .widget-backlight label { font-size: 1.5rem; color: ${Yellow}; }
        .widget-backlight .KB { padding-bottom: 1rem; }
        .image { padding-right: 0.5rem; }
      '';
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
      source = "${openbox-package}/themes/${openbox-theme}/openbox-3/";
      target = ".themes/${openbox-theme}/openbox-3/";
      recursive = true;
    };

  };

  xdg.configFile = {

    "picom/picom.conf".text = ''
backend = "egl";
corner-radius = 10;
detect-client-opacity = true;
detect-rounded-corners = true;
detect-transient = true;
fade-delta = 10;
fade-duration = 400;
fade-in-step = 0.050000;
fade-out-step = 0.050000;
fade-time = 300;
fading = true;
frame-opacity = 1.000000;
glx-use-copysubbuffer-mesa = true;
no-fading-destroyed-argb = true;
no-fading-openclose = true;
shadow = true;
shadow-color = "${Black}";
shadow-offset-x = -15;
shadow-offset-y = -15;
shadow-opacity = 0.850000;
shadow-radius = 20;
vsync = true;
xrender-sync = true;
xrender-sync-fence = true;
root-pixmap-shader = "${config.xdg.configHome}/picom/gamma_brightness.glsl";

blur: {
  method = "dual_kawase";
  size = 13;
  strength = 7;
  deviation = 6.0;
  background-frame = false;
  kern = "3x3box";
}

rules: (
	{
	      #match = "class_g != 'Polybar'";
		shader = {
		 path = "${config.xdg.configHome}/picom/gamma_brightness.glsl";
		 #COLOR = "vec4(100.0, 100.0, 100.0, 100.0)";
		};
	}, {
	      match = "class_g != 'dunst' || class_g != 'Dunst'"
		opacity = 0.85;
		opacity-override = false;
	}, {
	      match = "focused || group_focused || class_g = 'dunst' || class_g = 'Dunst' || class_g = 'firefox' || class_g = 'chromium' || class_g = 'brave-browser' || class_g = 'Polybar' || class_g *= 'Brave-browser' || class_g = 'brave' || class_g = 'Brave' || class_name *= 'Dunst' || class_name *= 'dunst' || class_g = 'mpv' || class_g = 'mpv' && !focused || class_g = 'mpvk' || name = 'mpv' || name = 'mpvk' || window_id = '0x5600002' || class_g = 'Xwinwrap' || class_g = 'xwinwrap' || name = 'Xwinwrap' || name = 'xwinwrap' || (class_g *= 'xwin' || name *= 'xwin')"
		opacity = 1.0;
		opacity-override = false;
	}, {
		match = "window_type = 'normal'";
		fade = true;
		shadow = true;
	}, {
		match = "window_type = 'desktop' || window_type = 'dock' || class_g = 'Conky' || class_g = 'conky' || class_g = 'dockx' || class_g = 'Dockx' || window_type = 'dock' || window_type = 'menu' || window_type = 'dropdown_menu' || class_g = 'ulauncher' || class_g = 'Ulauncher' || class_g = 'dunst' || class_g = 'Dunst'";
		blur-background = false;
		clip-shadow-above = false;
		shadow = false;
	}, {
		match = "window_type = 'dock' || window_type = 'desktop' || name = 'Notification' || class_g = 'i3-frame' || class_g = 'dunst' || class_g = 'Dunst' || class_g = 'dockx' || class_g = 'Dockx'";
            corner-radius = 0;
	}, {
		match = "_GTK_FRAME_EXTENTS@:c && (window_type = 'menu' || window_type = 'dropdown_menu') || class_g = 'ulauncher' || class_g = 'Ulauncher' || class_g = 'dockx' || class_g = 'Dockx' || class_g = 'iotas' && (window_type = 'menu' || window_type = 'dropdown_menu') || class_g = '.warehouse-wrapped' && (window_type = 'menu' || window_type = 'dropdown_menu') || class_g = 'org.gnome.Mines' && (window_type = 'menu' || window_type = 'dropdown_menu') || class_g = 'resources' && (window_type = 'menu' || window_type = 'dropdown_menu') || class_g = 'baobab' && (window_type = 'menu' || window_type = 'dropdown_menu')";
		shadow = false;
		opacity = 1.0;
		opacity-override = false;
	}, {
		match = "fullscreen";
            corner-radius = 0;
            opacity = 1.0;
            opacity-override = false;
            transparent-clipping = false;
	}, {
		match = "class_g = 'Conky' || class_g = 'conky'";
		transparent-clipping = false;
		unredir = true;
            opacity-override = false;
	},
      #{
      #    # Fix shadow related bugs on small UI elements
      #    match = "window_type = 'menu' || role = 'popup' || role = 'bubble'";
      #    shadow = false;
      #},
      {
	      match = "class_g = 'Polybar'";
		shadow = true;
		#corner-radius = ${toString config.services.polybar.settings."bar/${config.my.poly-name}".radius};
		#blur-background = false;
		corner-radius = 6;
		shadow-radius = 12;
		shadow-opacity = 0.700000;
		shadow-color = "${Black}";
	},
	{
        match = "window_type = 'normal'";
        animations = (
          {
              triggers = ["close"];
              opacity = {
                  curve = "linear";
                  duration = 0.2;  # Slightly longer duration for smoother opacity fade
                  start = "window-raw-opacity-before";
                  end = 0;
              };
              shadow-opacity = "opacity";
              scale-x = {
                  curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
                  duration = 0.4;  # Smoother zoom-out
                  start = 1;  # Start at full size
                  end = 0;  # Zoom out to 0
              };
              scale-y = "scale-x";
              shadow-scale-x = "scale-x";
              shadow-scale-y = "scale-y";

              # Adjust offsets to zoom from the center
              offset-x = "(1 - scale-x) / 2 * window-width";
              offset-y = "(1 - scale-y) / 2 * window-height";
              shadow-offset-x = "offset-x";
              shadow-offset-y = "offset-y";

              # Add blur effect during close
              blur = {
                  curve = "linear";
                  duration = 0.4;  # Smooth blur fade
                  start = 0;
                  end = 10;  # Max blur (you can adjust this value for stronger/weaker blur)
              };
          }, {
              triggers = ["hide"];
              preset = "disappear";
              scale = 0.3;
              duration = 0.15;
          }, {
              triggers = ["open"];
              opacity = {
                  curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
                  duration = 0.15;  # Smoother fade-in with longer duration
                  start = 0;
                  end = "window-raw-opacity";
              };
              offset-x = "(1 - scale-x) / 2 * window-width";  # Start from center
              offset-y = "(1 - scale-y) / 2 * window-height";  # Start from center
              scale-x = {
                  curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
                  duration = 0.15;  # Slower zoom-in for smooth effect
                  start = 0;  # Start very small
                  end = 1;  # Zoom in to full size
              };
              scale-y = "scale-x";
              shadow-scale-x = "scale-x";
              shadow-scale-y = "scale-y";
              shadow-offset-x = "offset-x";
              shadow-offset-y = "offset-y";
          }, {
              triggers = ["show"];
              preset = "appear";
              scale = 0.7;
              duration = 0.15;
          }, {
              triggers = ["geometry"];
              scale-x = {
                  curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
                  duration = 0.15;  # Smoother scaling
                  start = "window-width-before / window-width";
                  end = 1;
              };
              scale-y = {
                  curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
                  duration = 0.15;  # Smoother scaling
                  start = "window-height-before / window-height";
                  end = 1;
              };
              offset-x = {
                  curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
                  duration = 0.15;  # Smoother positioning
                  start = "window-x-before - window-x";
                  end = 0;
              };
              offset-y = {
                  curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
                  duration = 0.15;  # Smoother positioning
                  start = "window-y-before - window-y";
                  end = 0;
              };
              shadow-scale-x = "scale-x";
              shadow-scale-y = "scale-y";
              shadow-offset-x = "offset-x";
              shadow-offset-y = "offset-y";
          },
        )
    }, {
        match = "class_g = 'Dunst'";
	  animations = (
	    {
		 triggers = ["close", "hide"];
		 preset = "fly-out";	#-dunst-close-preset
		 direction = "right";	#-dunst-close-direction
		 duration = 0.2;
	    }, {
		 triggers = ["open", "show"];
		 preset = "fly-in";	#-dunst-open-preset
		 direction = "right";	#-dunst-open-direction
		 duration = 0.2;
	    }
	  )
    }, {
        match = "class_g = 'Rofi'";
	  animations = (
	    {
		 triggers = ["close", "hide"];
		 preset = "fly-out";	#-dunst-close-preset
		 direction = "up";	#-dunst-close-direction
		 duration = 0.2;
	    }, {
		 triggers = ["open", "show"];
		 preset = "fly-in";	#-dunst-open-preset
		 direction = "down";	#-dunst-open-direction
		 duration = 0.2;
	    }
	  )
    }, {
      	match = "class_g = 'jgmenu'";
      	animations = (
      	{
      		triggers = ["close", "hide"];
      		preset = "disappear";
      		duration = 0.08;
      		scale = 0.5;
      	}, {
      		triggers = ["open", "show"];
      		preset = "appear";
      		duration = 0.15;
      		scale = 0.5;
      	}
      	)
      }, {
		match = "class_g = 'scratchpad' || class_g = 'Tilda' || class_g = 'Ulauncher' || class_g = 'XFilesFloat' || class_g = 'tetris'";
		animations = (
		{
			triggers = ["close", "hide"];
			preset = "fly-out";
			direction = "up";
			duration = 0.2;
		}, {
			triggers = ["open", "show"];
			preset = "fly-in";
			direction = "up";
			duration = 0.2;
		}
		)
	}, {
		match = "class_g = 'Polybar'";
		animations = (
		{
			triggers = ["close", "hide"];
			preset = "fly-out";
			direction = "up";
			duration = 0.2;
		}, {
			triggers = ["open", "show"];
			preset = "fly-in";
			direction = "up";
			duration = 0.2;
		}
		)
	}, {
		match = "class_g = 'Tint2' || fullscreen";
		animations = (
		{
			triggers = ["close", "hide"];
			preset = "fly-out";
			direction = "down";
			duration = 0.2;
		},
		{
			triggers = ["open", "show"];
			preset = "fly-in";
			direction = "down";
			duration = 0.2;
		}
		)
	}, {
		match = "class_g = 'kitty-picker' || class_g = 'Xmessage' || class_g = 'Gxmessage'";
		animations = (
		{
			triggers = ["close", "hide"];
			preset = "fly-out";
			direction = "left";
			duration = 0.2;
		}, {
			triggers = ["open", "show"];
			preset = "fly-in";
			direction = "left";
			duration = 0.2;
		}
		)
	}, {
		match = "class_g = 'bluetuith' || class_g = 'pavucontrol' || class_g = 'Vboard.py' || class_g = 'baobab'";
		animations = (
		{
			triggers = ["close", "hide"];
			preset = "fly-out";
			direction = "right";
			duration = 0.2;
		}, {
			triggers = ["open", "show"];
			preset = "fly-in";
			direction = "right";
			duration = 0.2;
		}
		)
	}, {
		match = "class_g = 'XMenu' || class_g = 'Xmenu' || class_g = 'xmenu' || class_g = 'Onboard'";
		animations = (
		{
			triggers = ["close", "hide"];
			preset = "disappear";
			direction = "up";
			duration = 0.1;
		}, {
			triggers = ["open", "show"];
			preset = "appear";
			direction = "up";
			duration = 0.1;
		}
		)
	},
)
    '';

    "picom/gamma_brightness.glsl".text = ''
      #version 330

      // Changes gamma of windows
      float gamma = ${toString picom-gamma}; // Use values higher than 0. Change to your liking
      float brightness_level = ${toString picom-brightness};

      float inv_gamma = 1/gamma;

      in vec2 texcoord;             // texture coordinate of the fragment

      uniform sampler2D tex;        // texture of the window

      // Default window post-processing:
      // 1) invert color
      // 2) opacity / transparency
      // 3) max-brightness clamping
      // 4) rounded corners
      vec4 default_post_processing(vec4 c);

      vec4 window_shader() {
          vec4 c = texelFetch(tex, ivec2(texcoord), 0);

          c = default_post_processing(c);

          // Apply power law transform

          c.x = pow(c.x, inv_gamma);
          c.y = pow(c.y, inv_gamma);
          c.z = pow(c.z, inv_gamma);

          c.x *= brightness_level;
          c.y *= brightness_level;
          c.z *= brightness_level;

          return c;
      }
    '';

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

    gowall = {
      target = "gowall/config.yml";
      text = ''
        themes:
          - name: "hm-theme"
            colors:
              - "${CRosewater}"
              - "${CFlamingo}"
              - "${COrange}"
              - "${CPink}"
              - "${CMauve}"
              - "${CRed}"
              - "${CMaroon}"
              - "${CPeach}"
              - "${CYellow}"
              - "${CGreen}"
              - "${CTeal}"
              - "${CSky}"
              - "${CSapphire}"
              - "${CBlue}"
              - "${CLavender}"
              - "${CBrown}"
              - "${CText}"
              - "${CSubtext1}"
              - "${CSubtext0}"
              - "${COverlay2}"
              - "${COverlay1}"
              - "${COverlay0}"
              - "${CSurface2}"
              - "${CSurface1}"
              - "${CSurface0}"
              - "${CBase}"
              - "${CMantle}"
              - "${CCrust}"
      '';
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
      input_text_fg = '${Accent}'
      result_count_fg = '${Accent}'
      # results
      result_name_fg = '${Blue}'
      result_line_number_fg = '${Yellow}'
      result_value_fg = '${Lavender}'
      selection_fg = '${Green}'
      selection_bg = '${Surface0}'
      match_fg = '${Green}'
      # preview
      preview_title_fg = '${Accent}'
      # modes
      channel_mode_fg = '${Base}'
      channel_mode_bg = '${Accent}'
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
      # name: '${fish-theme-name}'
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
        frame_color = "${Green}"

        [urgency_normal]
        background = "${Base}"
        foreground = "${Text}"

        [urgency_critical]
        background = "${Base}"
        foreground = "${Text}"
        frame_color = "${Peach}"
      '';
    };

    awesome-theme = {
      target = "awesome/themes/default/theme.lua";
      text = ''
        local beautiful    = require("beautiful")
        local theme_assets = require("beautiful.theme_assets")
        local xresources   = require("beautiful.xresources")
        local dpi          = require("beautiful.xresources").apply_dpi
        local gears        = require("gears")
        local gfs          = require("gears.filesystem")
        local themes_path  = gfs.get_themes_dir()
        local theme = {}
        theme.font         = "${awesome-wmFont}"
        theme.gh_fg        = "${Text}"   -- Foreground text
        theme.gh_bg        = "${Base}"   -- Background
        theme.gh_comment   = "${Overlay2}"   -- Comments/muted text
        theme.gh_red       = "${Red}"   -- Error, deletion
        theme.gh_green     = "${Green}"   -- Success, addition
        theme.gh_yellow    = "${Yellow}"   -- Warning, modified
        theme.gh_blue      = "${Blue}"   -- Info, links
        theme.gh_magenta   = "${Mauve}"   -- Variables, prop names
        theme.gh_cyan      = "${Teal}"   -- Tags, tokens
        theme.gh_selection = "${Surface1}"   -- Selection background
        theme.gh_highlight = "${Rosewater}"   -- Highlighted text
        theme.gh_caret     = "#${Accent}"   -- Cursor/caret color
        theme.gh_invisibles= "${Crust}"  -- Invisible characters
        theme.gh_mantle    = "${Mantle}"  -- Invisible characters
        theme.bg_normal     = theme.gh_bg        -- Normal background
        theme.bg_focus      = theme.gh_blue      -- Focused elements
        theme.bg_urgent     = theme.gh_red       -- Urgent (alert) background
        theme.bg_minimize   = theme.gh_invisibles -- Minimized window background
        theme.bg_systray    = theme.gh_bg        -- System tray background
        theme.fg_normal     = theme.gh_fg        -- Normal text color
        theme.fg_focus      = theme.gh_bg        -- Focused text color
        theme.fg_urgent     = theme.gh_fg        -- Urgent text color
        theme.fg_minimize   = theme.gh_comment   -- Minimized text color
        theme.titlebar_bg_normal   = theme.gh_mantle   -- inactive
        theme.titlebar_bg_focus    = theme.gh_mantle   -- active window
        theme.titlebar_bg_urgent   = theme.gh_red   -- urgent
        theme.titlebar_fg_normal   = theme.gh_caret   -- inactive
        theme.titlebar_fg_focus    = theme.gh_caret   -- active window
        local function rc(img) return gears.color.recolor_image(img, theme.titlebar_fg_focus) end
        theme.titlebar_close_button_normal = rc(theme.titlebar_close_button_normal)
        theme.titlebar_close_button_focus  = rc(theme.titlebar_close_button_focus)
        theme.useless_gap   = dpi(8)             -- Gap between windows
        theme.border_width  = dpi(4)             -- Border width for windows
        theme.border_normal = theme.gh_invisibles -- Border color for inactive windows
        theme.border_focus  = theme.gh_blue      -- Border color for focused windows
        theme.border_marked = theme.gh_magenta   -- Border color for marked windows
        theme.taglist_squares_sel = nil
        theme.taglist_squares_unsel = nil
        theme.taglist_fg_focus = theme.gh_caret      -- Active tag text color (using highlight color for more contrast)
        theme.taglist_bg_focus = "transparent"            -- Active tag background (transparent)
        theme.taglist_fg_occupied = theme.gh_fg           -- Occupied tag text color
        theme.taglist_bg_occupied = "transparent"         -- Occupied tag background (transparent)
        theme.taglist_fg_empty = theme.gh_comment .. "80" -- Empty tag text color with 50% opacity for even lower visibility
        theme.taglist_bg_empty = "transparent"            -- Empty tag background (transparent)
        theme.taglist_fg_urgent = theme.gh_red     -- Urgent tag text color
        theme.taglist_bg_urgent = "transparent"    -- Urgent tag background (transparent)
        theme.taglist_spacing = dpi(6)             -- Space between tags
        theme.menu_submenu_icon = themes_path.."default/submenu.png"
        theme.menu_height = dpi(18)
        theme.menu_width  = dpi(100)
        theme.titlebar_close_button_normal       = themes_path.."default/titlebar/close_normal.png"
        theme.titlebar_close_button_focus        = themes_path.."default/titlebar/close_focus.png"
        theme.titlebar_minimize_button_normal    = themes_path.."default/titlebar/minimize_normal.png"
        theme.titlebar_minimize_button_focus     = themes_path.."default/titlebar/minimize_focus.png"
        theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
        theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
        theme.titlebar_ontop_button_normal_active    = themes_path.."default/titlebar/ontop_normal_active.png"
        theme.titlebar_ontop_button_focus_active     = themes_path.."default/titlebar/ontop_focus_active.png"
        theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
        theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
        theme.titlebar_sticky_button_normal_active     = themes_path.."default/titlebar/sticky_normal_active.png"
        theme.titlebar_sticky_button_focus_active      = themes_path.."default/titlebar/sticky_focus_active.png"
        theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
        theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
        theme.titlebar_floating_button_normal_active     = themes_path.."default/titlebar/floating_normal_active.png"
        theme.titlebar_floating_button_focus_active      = themes_path.."default/titlebar/floating_focus_active.png"
        theme.titlebar_maximized_button_normal_inactive = themes_path.."default/titlebar/maximized_normal_inactive.png"
        theme.titlebar_maximized_button_focus_inactive  = themes_path.."default/titlebar/maximized_focus_inactive.png"
        theme.titlebar_maximized_button_normal_active     = themes_path.."default/titlebar/maximized_normal_active.png"
        theme.titlebar_maximized_button_focus_active      = themes_path.."default/titlebar/maximized_focus_active.png"
        theme.layout_fairh         = themes_path.."default/layouts/fairhw.png"
        theme.layout_fairv         = themes_path.."default/layouts/fairvw.png"
        theme.layout_floating      = themes_path.."default/layouts/floatingw.png"
        theme.layout_magnifier     = themes_path.."default/layouts/magnifierw.png"
        theme.layout_max           = themes_path.."default/layouts/maxw.png"
        theme.layout_fullscreen    = themes_path.."default/layouts/fullscreenw.png"
        theme.layout_tilebottom    = themes_path.."default/layouts/tilebottomw.png"
        theme.layout_tileleft      = themes_path.."default/layouts/tileleftw.png"
        theme.layout_tile          = themes_path.."default/layouts/tilew.png"
        theme.layout_tiletop       = themes_path.."default/layouts/tiletopw.png"
        theme.layout_spiral        = themes_path.."default/layouts/spiralw.png"
        theme.layout_dwindle       = themes_path.."default/layouts/dwindlew.png"
        theme.layout_cornernw      = themes_path.."default/layouts/cornernww.png"
        theme.layout_cornerne      = themes_path.."default/layouts/cornernew.png"
        theme.layout_cornersw      = themes_path.."default/layouts/cornersww.png"
        theme.layout_cornerse      = themes_path.."default/layouts/cornersew.png"
        theme.systray_icon_spacing = 5
        theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.gh_blue, theme.gh_bg)
        theme.icon_theme = nil
        return theme
      '';
    };

    obs-ovt-nix-theme = {
      target = "obs-studio/themes/Nix.ovt";
      text = lib.mkBefore ''
        @OBSThemeMeta {
            name: 'Nix';
            id: 'com.obsproject.Nix.Nix';
            extends: 'com.obsproject.Nix';
            author: 'Xurdejl';
            dark: 'true';
        }

        @OBSThemeVars {
            --ctp_rosewater: ${Rosewater};
            --ctp_flamingo: ${Flamingo};
            --ctp_pink: ${Pink};
            --ctp_mauve: ${Mauve};
            --ctp_red: ${Red};
            --ctp_maroon: ${Maroon};
            --ctp_peach: ${Peach};
            --ctp_yellow: ${Yellow};
            --ctp_green: ${Green};
            --ctp_teal: ${Teal};
            --ctp_sky: ${Sky};
            --ctp_sapphire: ${Sapphire};
            --ctp_blue: ${Blue};
            --ctp_lavender: ${Lavender};
            --ctp_text: ${Text};
            --ctp_subtext1: ${Subtext1};
            --ctp_subtext0: ${Subtext0};
            --ctp_overlay2: ${Overlay2};
            --ctp_overlay1: ${Overlay1};
            --ctp_overlay0: ${Overlay0};
            --ctp_surface2: ${Surface2};
            --ctp_surface1: ${Surface1};
            --ctp_surface0: ${Surface0};
            --ctp_base: ${Base};
            --ctp_mantle: ${Mantle};
            --ctp_crust: ${Crust};
            --ctp_selection_background: ${obs-selection};
        }

        VolumeMeter {
            qproperty-foregroundNominalColor: ${obs-vol-num};
            qproperty-foregroundWarningColor: ${obs-vol-warn};
            qproperty-foregroundErrorColor: ${obs-vol-error};
        }
      '';
    };

    geany-theme = {
      target = "geany/colorschemes/hm-theme.conf";
      text = ''
        [theme_info]
        name=Home Manager Theme
        description=Home Manager Controled Theme
        version=0.0.0.0
        author=meeee
        compat=1.22;1.23;1.23.1;1.24

        [named_colors]
        rosewater=${Rosewater}
        flamingo=${Flamingo}
        pink=${Pink}
        mauve=${Mauve}
        red=${Red}
        maroon=${Maroon}
        peach=${Peach}
        yellow=${Yellow}
        green=${Green}
        teal=${Teal}
        sky=${Sky}
        sapphire=${Sapphire}
        blue=${Blue}
        lavender=${Lavender}
        text=${Text}
        subtext1=${Subtext1}
        subtext0=${Subtext0}
        overlay2=${Overlay2}
        overlay1=${Overlay1}
        overlay0=${Overlay0}
        surface2=${Surface2}
        surface1=${Surface1}
        surface0=${Surface0}
        base=${Base}
        mantle=${Mantle}
        crust=${Crust}
        accent=${Accent}

        [named_styles]
        operator=blue
        default=subtext1;base;false;false
        error=red;yellow;false;true
        op=blue;base;true;false
        # Editor UI
        #  selection: words; background
        selection=base;rosewater;true;true
        current_line=;surface0;true
        brace_good=green;overlay1;true;true
        brace_bad=red;overlay1;true;true
        margin_line_number=text;base
        margin_folding=accent;base
        fold_symbol_highlight=surface1
        indent_guide=overlay1
        caret=text;;false
        marker_line=yellow;yellow
        marker_search=mantle;blue
        marker_mark=green;surface0
        call_tips=overlay1;text;false;false
        white_space=overlay1;;true

        # Basic langs
        comment=overlay0
        comment_doc=comment
        comment_line=overlay0
        comment_line_doc=comment_doc
        comment_doc_keyword=comment,bold
        comment_doc_keyword_error=comment,italic

        number=teal
        number_1=number
        number_2=number_1

        # class <color()>
        type=pink;;flase;true;

        class=blue
        # def <color():>
        function=teal;;false;true;
        parameter=peach

        keyword=default
        # def, for, in
        keyword_1=red;;false;true
        keyword_2=default
        keyword_3=peach
        keyword_4=keyword_2

        identifier=sky;;false;false
        # main
        identifier_1=subtext0;;false;false
        identifier_2=default
        identifier_3=identifier_2
        identifier_4=identifier_2

        string=green;;false;false
        string_1=green;;false;false
        string_2=green;;false;false
        string_3=default
        string_4=default
        string_eol=string_1
        character=string_1
        backticks=string_2
        here_doc=string_2

        scalar=string_2
        label=red
        preprocessor=green
        regex=pink
        operator=lavender;;true;false
        decorator=string_1
        other=default
        extra=keyword;

        # Markup
        tag=keyword
        tag_unknown=tag,bold
        tag_end=tag,bold
        attribute=type
        attribute_unknown=attribute,bold
        value=number
        entity=number

        # Diff
        line_added=green
        line_removed=red
        line_changed=preprocessor
      '';
    };

    geany-conf = {
      target = "geany/geany.conf";
      text = lib.mkAfter ''
        long_line_color=${Accent}

        [VTE]
        load_vte=true
        send_cmd_prefix=
        send_selection_unsafe=false
        font=Monospace 10
        scroll_on_key=true
        scroll_on_out=true
        enable_bash_keys=true
        ignore_menu_bar_accel=false
        follow_path=false
        run_in_vte=false
        skip_run_script=false
        cursor_blinks=false
        scrollback_lines=500
        shell=/run/current-system/sw/bin/${config.my.defaultShell}
        colour_fore=${Text}
        colour_back=${Base}
      '';
    };

    glamour-theme = {
      target = "glamour/theme.json";
      text = ''
        {
          "document": {
            "block_prefix": "\n",
            "block_suffix": "\n",
            "color": "${Text}",
            "margin": 2
          },
          "block_quote": {
            "indent": 1,
            "indent_token": "│ "
          },
          "paragraph": {},
          "list": {
            "level_indent": 2
          },
          "heading": {
            "block_suffix": "\n",
            "color": "${Text}",
            "bold": true
          },
          "h1": {
            "prefix": "▓▓▓ ",
            "suffix": " ",
            "color": "${Red}",
            "bold": true
          },
          "h2": {
            "prefix": "▓▓▓▓ ",
            "color": "${Peach}"
          },
          "h3": {
            "prefix": "▓▓▓▓▓ ",
            "color": "${Yellow}"
          },
          "h4": {
            "prefix": "▓▓▓▓▓▓ ",
            "color": "${Green}"
          },
          "h5": {
            "prefix": "▓▓▓▓▓▓▓ ",
            "color": "${Sapphire}"
          },
          "h6": {
            "prefix": "▓▓▓▓▓▓▓▓ ",
            "color": "${Lavender}"
          },
          "text": {},
          "strikethrough": {
            "crossed_out": true
          },
          "emph": {
            "italic": true
          },
          "strong": {
            "bold": true
          },
          "hr": {
            "color": "${Overlay0}",
            "format": "\n--------\n"
          },
          "item": {
            "block_prefix": "• "
          },
          "enumeration": {
            "block_prefix": ". "
          },
          "task": {
            "ticked": "[✓] ",
            "unticked": "[ ] "
          },
          "link": {
            "color": "${Blue}",
            "underline": true
          },
          "link_text": {
            "color": "${Lavender}",
            "bold": true
          },
          "image": {
            "color": "${Blue}",
            "underline": true
          },
          "image_text": {
            "color": "${Lavender}",
            "format": "Image: {{.text}} →"
          },
          "code": {
            "prefix": " ",
            "suffix": " ",
            "color": "${Maroon}",
            "background_color": "${Mantle}"
          },
          "code_block": {
            "color": "${Mantle}",
            "margin": 2,
            "chroma": {
              "text": {
                "color": "${Text}"
              },
              "error": {
                "color": "${Text}",
                "background_color": "${Red}"
              },
              "comment": {
                "color": "${Overlay0}"
              },
              "comment_preproc": {
                "color": "${Blue}"
              },
              "keyword": {
                "color": "${Mauve}"
              },
              "keyword_reserved": {
                "color": "${Mauve}"
              },
              "keyword_namespace": {
                "color": "${Yellow}"
              },
              "keyword_type": {
                "color": "${Yellow}"
              },
              "operator": {
                "color": "${Sky}"
              },
              "punctuation": {
                "color": "${Overlay2}"
              },
              "name": {
                "color": "${Lavender}"
              },
              "name_builtin": {
                "color": "${Peach}"
              },
              "name_tag": {
                "color": "${Mauve}"
              },
              "name_attribute": {
                "color": "${Yellow}"
              },
              "name_class": {
                "color": "${Yellow}"
              },
              "name_constant": {
                "color": "${Yellow}"
              },
              "name_decorator": {
                "color": "${Pink}"
              },
              "name_exception": {},
              "name_function": {
                "color": "${Blue}"
              },
              "name_other": {},
              "literal": {},
              "literal_number": {
                "color": "${Peach}"
              },
              "literal_date": {},
              "literal_string": {
                "color": "${Green}"
              },
              "literal_string_escape": {
                "color": "${Pink}"
              },
              "generic_deleted": {
                "color": "${Red}"
              },
              "generic_emph": {
                "color": "${Text}",
                "italic": true
              },
              "generic_inserted": {
                "color": "${Green}"
              },
              "generic_strong": {
                "color": "${Text}",
                "bold": true
              },
              "generic_subheading": {
                "color": "${Sky}"
              },
              "background": {
                "background_color": "${Mantle}"
              }
            }
          },
          "table": {
            "center_separator": "┼",
            "column_separator": "│",
            "row_separator": "─"
          },
          "definition_list": {},
          "definition_term": {},
          "definition_description": {
            "block_prefix": "\n🠶 "
          },
          "html_block": {},
          "html_span": {}
        }
      '';
    };

    jgmenu-theme = {
      target = "jgmenu/jgmenurc";
      text = ''
        # verbosity = 0
        # stay_alive = 1
        # persistent = 0
        # hide_on_startup = 0
        # csv_cmd = apps
        # tint2_look = 1
        position_mode = pointer
        # edge_snap_x = 30
        # terminal_exec = x-terminal-emulator
        # terminal_args = -e
        # monitor = 0
        # hover_delay = 100
        # hide_back_items = 1
        # columns = 1
        # tabs = 120
        # menu_margin_x = 0
        # menu_margin_y = 0
        # menu_width = 200
        # menu_height_min = 0
        # menu_height_max = 0
        # menu_height_mode = static
        # menu_padding_top = 5
        # menu_padding_right = 5
        # menu_padding_bottom = 5
        # menu_padding_left = 5
        # menu_radius = 1
        menu_border = 6
        # menu_halign = left
        # menu_valign = bottom
        # menu_gradient_pos = none
        sub_spacing = 0
        # sub_padding_top = auto
        # sub_padding_right = auto
        # sub_padding_bottom = auto
        # sub_padding_left = auto
        # sub_hover_action = 1
        # item_margin_x = 3
        # item_margin_y = 3
        # item_height = 25
        # item_padding_x = 4
        # item_radius = 1
        # item_border = 0
        # item_halign = left
        # sep_height = 5
        sep_halign = center
        sep_markup =
        font = ${jgmenuFont}
        # font_fallback = xtg
        # icon_size = 22
        # icon_text_spacing = 10
        # icon_norm_alpha = 100
        # icon_sel_alpha = 100
        icon_theme = ${gtk-icon}
        icon_theme_fallback = gxt
        arrow_string = 
        # arrow_width = 15
        # search_empty_string = &lt;empty&gt;
        color_menu_bg = ${Base} 100
        # color_menu_bg_to = #000000 100
        color_menu_border = ${Base} 100
        # color_norm_bg = #000000 00
        color_norm_fg = ${Text} 100
        color_sel_bg = ${Accent} 100
        color_sel_fg = ${Base} 100
        color_sel_border = ${Surface1} 100
        color_sep_fg = ${Base} 100
        # color_scroll_ind = #eeeeee 40
        color_title_fg = ${Subtext0} 100
        color_title_bg = ${Crust} 100
        color_title_border = ${Crust} 100
        # csv_name_format = %n (%g)
        # csv_single_window = 0
        # csv_no_dirs = 0
        # csv_i18n =
        # csv_no_duplicates = 0
      '';
    };

    copyq-theme = {
      target = "copyq/themes/hm-theme.ini";
      text = ''
        [General]
        bg=${CBase}
        fg=${CText}
        alt_bg=${CMantle}
        sel_bg=${CRosewater}
        sel_fg=${CCrust}
        find_bg=${CYellow}
        find_fg=${CCrust}
        edit_bg=${CSurface0}
        edit_fg=${CText}
        notes_bg=${CMantle}
        notes_fg=${CText}
        num_fg=${COverlay0}
        num_sel_fg=${CText}
        notification_bg=${CSurface0}
        notification_fg=${CText}

        hover_item_css="
            ;background: ${starship6}"
        sel_item_css="
            ;background: ${CRosewater}"
        menu_bar_css="
            ;background: ${CBase}"
        menu_bar_disabled_css="
            ;color: ${CMantle}"

        tab_bar_css="
            ;background: ${CMantle}"
        tab_bar_item_counter="
            ;color: ${CAccent}"
        tab_bar_scroll_buttons_css="
            ;background: ${CMantle}"
        tab_bar_tab_unselected_css="
            ;background: ${CMantle}"
        tab_tree_item_counter="
            ;color: ${CAccent}"
        tab_bar_sel_item_counter="
            ;color: ${CAccent}"
        tab_tree_sel_item_counter="
            ;color: ${CAccent}"

        tool_button_selected_css="
            ;background: ${CBase}"

        style_main_window=true
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
            text-color: ${Accent};
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
            selection: ${Accent};
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
            text-color: ${Accent};
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
    rofi-thumbs = {
      target = "rofi/themes/thumb.rasi";
      text = ''
        configuration {
            modi: "drun";
            show-icons: true;
            drun-display-format: "";
        }
        * {
            background-color: transparent;
        }
        window {
            transparency: "real";
            location: center;
            anchor: center;
            width: 600px;
            height: 400px;
            margin: 0px;
            padding: 0px;
            border: 1px solid;
            border-radius: 10px;
        }
        mainbox {
            padding: 20px;
            spacing: 10px;
            children: [ listview ];
        }
        listview {
            columns: 5;
            lines: 2;
            fixed-columns: true;
            fixed-height: true;
            spacing: 16px;
            padding: 0px;
            layout: vertical;
            scrollbar: false;
            cycle: true;
            background-color: transparent;
        }
        element {
            expand: true;
            padding: 0px;
            border-radius: 10px;
            cursor: pointer;
            children: [ element-icon ];
        }
        element selected.normal {
            border: 2px solid;
            border-radius: 10px;
            border-color: ${Accent};
        }
        element-icon {
            expand: true;
            size: 96px;
            border-radius: 8px;
            vertical-align: 0.5;
            horizontal-align: 0.5;
        }
        element-text {
            enabled: false;
        }
      '';
    };

    test = {
      target = "test.txt";
      text = ''
        ${hexToRgb alt-Base}
        rgb(${hexToRgb alt-Accent})
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

    "desktop-sounds/open".source = "${inputs.assets}/sounds/pen-2";
    "desktop-sounds/close".source = "${inputs.assets}/sounds/pen-1";
    "desktop-sounds/focus".source = "${inputs.assets}/sounds/bell";
    "desktop-sounds/dektop".source = "${inputs.assets}/sounds/screen-capture";
    "desktop-sounds/startup".source = "${inputs.assets}/sounds/desktop-logout";
    "desktop-sounds/notif".source = "${inputs.assets}/sounds/message-new-instant";
    "desktop-sounds/notif-critical".source = "${inputs.assets}/sounds/message-highlight";

  };

  programs.fish.shellInit = ''
    fish_config theme choose "${fish-theme}"
  '';

  home.shellAliases = {
    tcmatrix = "${config.my.default.terminal} --name cmatrix --class cmatrix sh -c 'cmatrix -C ${cmatrix}'";
  };

 #xdg.dataFile = {
 #  icons = {
 #    target = "icons/${gtk-icon}/";
 #    source = "${pkgs.papirus-icon-theme}/share/icons/${gtk-icon}/";
 #    recursive = true;
 #  };
 #};

  home.activation = {
   #openbox-theme = lib.hm.dag.entryAfter ["writeBoundary"] ''
   #  mkdir -p "$HOME/./share/fonts/noto-fonts-color-emoji"
   #  cp -rn "${pkgs.noto-fonts-color-emoji}/share/fonts/noto" "$HOME/.local/share/fonts/noto-fonts-color-emoji"
   #'';
    heroic-theme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -f "$HOME/.config/heroic/store/config.json" ]; then
        jq '.theme = "${heroic-theme}" | .contentFontFamily = "${Sans}" | .actionsFontFamily = "${Sans}"' $HOME/.config/heroic/store/config.json > heroic-tmp.json && mv -f heroic-tmp.json $HOME/.config/heroic/store/config.json
      fi
    '';
    onlyoffice-theme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -f "$HOME/.config/onlyoffice/DesktopEditors.conf" ]; then
        sed -i 's/^UITheme=.*/UITheme=${onlyoffice-theme}/' $HOME/.config/onlyoffice/DesktopEditors.conf
      fi
    '';
    audacity-theme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -f "$HOME/.config/audacity/audacity.cfg" ]; then
        sed -i 's/^Theme=.*/Theme=${audacity-theme}/' $HOME/.config/audacity/audacity.cfg
      fi
      if [ -f "$HOME/.audacity-data/audacity.cfg" ]; then
        sed -i 's/^Theme=.*/Theme=${audacity-theme}/' $HOME/.audacity-data/audacity.cfg
      fi
    '';
  };

  systemd.user.services.bspborder = {
    Unit = {
     Description = "bspwm per app border color";
     ConditionEnvironment = "XDG_CURRENT_DESKTOP=none+bspwm";
    };
    Service = {
      Type = "simple";
      ExecStart = "${bsp-app-border}/bin/bsp-app-border";
      Restart = "on-failure";
    };
   #Install = {
   #  WantedBy = [ "graphical-session.target" ];
   #};
  };

 #catppuccin = {
 #  enable = false;
 # #cache.enable = true;
 #  flavor = flavor;
 #  accent = accent;
 #
 #  alacritty.enable = false;
 #  bat.enable = false;
 #  btop.enable = false;
 #  brave.enable = false;
 #  cava.enable = false;
 #  cursors.enable = false;
 #  dunst.enable = false;
 # #firefox.profiles={default={enable=false;force=false;};};
 #  fish.enable = false;
 #  freetube.enable = false;
 #  fzf.enable = false;
 #  gh-dash.enable = false;
 #  ghostty.enable = false;
 #  gtk.icon.enable = false;
 #  hyprland.enable = false;
 #  hyprlock.enable = false;
 #  kitty.enable = false;
 #  kvantum.enable = false;
 #  mangohud.enable = false;
 #  mpv.enable = false;
 #  nvim.enable = false;
 #  obs.enable = false;
 #  polybar.enable = false;
 #  qutebrowser.enable = false;
 #  rofi.enable = false;
 #  sioyek.enable = false;
 #  starship.enable = false;
 #  sway.enable = false;
 #  swaylock.enable = false;
 #  swaync.enable = false;
 #  television.enable = false;
 #  waybar.enable = false;
 #  wezterm.enable = false;
 #  wlogout.enable = false;
 #  xfce4-terminal.enable = false;
 #  yazi.enable = false;
 #
 #};

 #stylix.targets = {
 #  alacritty.enable = false;
 #  ashell.enable = false;
 #  bat.enable = false;
 #  bspwm.enable = false;
 #  btop.enable = false;
 #  cava.enable = false;
 #  cavalier.enable = false;
 #  dunst.enable = false;
 #  feh.enable = false;
 #  fzf.enable = false;
 #  ghostty = false;
 #  gtk.enable = false;  # use if no gtk theme found for style
 #  hyprland.enable = false;
 #  hyprlock.enable = false;
 #  hyprpanel.enable = false;
 #  i3.enable = false;
 #  kde.enable = false;  # use if no kde theme found for style
 #  kitty.enable = false;
 #  mangohud.enable = false;
 #  mpv.enable = false;
 #  qt.enable = false;  # use if no qt theme found for style
 #  qutebrowser.enable = false;
 #  rofi.enable = false;
 #  starship.enable = false;
 #  sway.enable = false;
 #  swaylock.enable = false;
 #  swaync.enable = false;
 #  sxiv.enable = false;
 #  waybar.enable = false;
 #  wezterm.enable = false;
 #  xfce.enable = false; # use if no xfce theme found for style
 #  xresources.enable = false;
 #  yazi.enable = false;
 #};

   #aerc                 C
   #anki                 C  S
   #avizo                   S
   #atuin                C
   #bemenu                  S
   #blender                 S
   #bottom               C
   #brave                C
   #chromium             C  S
   #delta                C
   #discord                 S
   #element-desktop      C
   #emacs                   S
   #eye of gnome            S
   #eza                  C
   #fcitx5               C  S
   #firefox and dervs    C  S
   #floorp               C  S
   #fnott                   S
   #foliate                 S
   #foot                 C  S
   #fuzzel               C  S
   #gedit                   S
   #gitui                C  S
   #glamour              C
   #glance                  S
   #gnome text editor       S
   #gnome                   S
   #go disk usage           S
   #gtksourceview           S
   #halloy               C  S
   #helix                C  S
   #hyprpaper               S
   #i3bar-river             S
   #imv                  C
   #k9s                  C  S
   #kmscon                  S
   #kubecolor               S
   #lazygit              C  S
   #librewolf            C
   #lsd                  C
   #mako                 C  S
   #micro                C  S
   #ncspot                  S
   #newsboat             C
   #noctalia                S
   #nvim distros            S
   #nushell              C  S
   #obsidian                S
   #opencode                S
   #rio                  C  S
   #river                   S
   #skim                 C
   #spicetify               S
   #spotify-player       C  S
   #thunderbird          C
   #tmux                 C  S
   #tofi                 C  S
   #vesktop              C
   #vicinae              C  S
   #vivaldi              C
   #vivid                C  S
   #vscode               C  S
   #wayfire                 S
   #wayprompt               S
   #wob                     S
   #wofi                    S
   #wpaperd                 S
   #zathura              C  S
   #zed                  C  S
   #zellij               C  S
   #zen                     S
   #zsh                  C

};}
