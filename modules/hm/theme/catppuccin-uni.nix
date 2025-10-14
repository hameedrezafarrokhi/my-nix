{ config, pkgs, lib, inputs, ... }:

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
    plasma-package = myKDECatppuccin;
    plasma-look = "Catppuccin-${myStuff.myCat.myGlobal-FlavC}-${myStuff.myCat.myGlobal-ColorC}";
    plasma-theme = "default";
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

    konsole-scheme = ./Konsole-catppuccin-macchiato.colorscheme;
    konsole-theme = "Konsole-catppuccin-${myStuff.myCat.myGlobal-Flav}";
    kate-theme = "Catppuccin ${myStuff.myCat.myGlobal-FlavC}";
    kate-ui = "Catppuccin ${myStuff.myCat.myGlobal-FlavC} ${myStuff.myCat.myGlobal-ColorC}";

    freetube-base = "catppuccinMocha";
    freetube-main = "CatppuccinMochaSapphire";
    freetube-sec = "CatppuccinMochaBlue";

    superfile-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}";

    catppuccinifier-flav = "${myStuff.myCat.myGlobal-Flav}";
    catppuccinifier-flavC = "${myStuff.myCat.myGlobal-FlavC}";
    catppuccinifier-acc = "${myStuff.myCat.myGlobal-Color}";
    catppuccinifier-accC = "${myStuff.myCat.myGlobal-ColorC}";

    onboard-theme = "${pkgs.onboard}/share/onboard/themes/ModelM.theme";
    onboard-color = "${pkgs.onboard}/share/onboard/themes/Granite.colors";
    onboard-layout = "${pkgs.onboard}/share/onboard/layouts/Full Keyboard.onboard";
    onboard-key = "dish";

    MonoSpace = "Comic Mono";
    Mono-X = "Comic Mono,  10";
    MonoAlt = "Monofur Nerd Font Mono";
    MonoRofi = "Comic Mono 10";
    MonoOnboard = "Monofur Nerd Font Mono bold";
    MonoPoly = "Comic Mono:size=10.5:weight=medium;3";
    MonoSt = "Comic Mono:style:Regular:pixelsize=10";
    MonoURxvt = "xft:Comic Mono:size=10";
    Sans = "Comic Sans MS";
    Sans-X = "Comic Sans MS,  10";
    Serif = "Comic Sans MS";
    Emoji = "Blobmoji";

    i3Style = "Bold Semi-Condensed";
    i3BarStyle = "Regular Semi-Condensed";

    MonoSize = 10;
    MonoSizeKitty = 9;
    MonoSizePlasma = 11;
    MonoSizePlasmaSmall = 8;
    MonoSizeI3 = 9.0;
    MonoSizeI3Bar = 10.0;
    SansSize = 10;

    sound = "ocean";

    kitty-back =           "#1D2231";
    kitty-back-tab =       "#1D2231";
    kitty-back-tab-act =   "#3A688D";
    kitty-back-tab-inact = "#3B4453";
    kitty-for-tab-act =    "#FFFFFF";
    kitty-for-tab-inact =  "#FFFFFF";
    kitty-marg-tab =       "#1D2231";

    Rosewater = "#f4dbd6";    rgb-Rosewater = "rgb(244, 219, 214)";
    Flamingo =  "#f0c6c6";    rgb-Flamingo =  "rgb(240, 198, 198)";
    Pink =      "#f5bde6";    rgb-Pink =      "rgb(245, 189, 230)";
    Mauve =     "#c6a0f6";    rgb-Mauve =     "rgb(198, 160, 246)";
    Red =       "#ed8796";    rgb-Red =       "rgb(237, 135, 150)";
    Maroon =    "#ee99a0";    rgb-Maroon =    "rgb(238, 153, 160)";
    Peach =     "#f5a97f";    rgb-Peach =     "rgb(245, 169, 127)";
    Yellow =    "#eed49f";    rgb-Yellow =    "rgb(238, 212, 159)";
    Green =     "#a6da95";    rgb-Green =     "rgb(166, 218, 149)";
    Teal =      "#8bd5ca";    rgb-Teal =      "rgb(139, 213, 202)";
    Sky =       "#91d7e3";    rgb-Sky =       "rgb(145, 215, 227)";
    Sapphire =  "#7dc4e4";    rgb-Sapphire =  "rgb(125, 196, 228)";
    Blue =      "#8aadf4";    rgb-Blue =      "rgb(138, 173, 244)";
    Lavender =  "#b7bdf8";    rgb-Lavender =  "rgb(183, 189, 248)";

    Text =      "#cad3f5";    rgb-Text =      "rgb(202, 211, 245)";
    Subtext1 =  "#b8c0e0";    rgb-Subtext1 =  "rgb(184, 192, 224)";
    Subtext0 =  "#a5adcb";    rgb-Subtext0 =  "rgb(165, 173, 203)";
    Overlay2 =  "#939ab7";    rgb-Overlay2 =  "rgb(147, 154, 183)";
    Overlay1 =  "#8087a2";    rgb-Overlay1 =  "rgb(128, 135, 162)";
    Overlay0 =  "#6e738d";    rgb-Overlay0 =  "rgb(110, 115, 141)";
    Surface2 =  "#5b6078";    rgb-Surface2 =    "rgb(91, 96, 120)";
    Surface1 =  "#494d64";    rgb-Surface1 =    "rgb(73, 77, 100)";
    Surface0 =  "#363a4f";    rgb-Surface0 =     "rgb(54, 58, 79)";
    Base =      "#24273a";    rgb-Base =         "rgb(36, 39, 58)";
    Mantle =    "#1e2030";    rgb-Mantle =       "rgb(30, 32, 48)";
    Crust =     "#181926";    rgb-Crust =        "rgb(24, 25, 38)";

    Transparent = "#FF00000";

    base00 =     "24273a"; # base
    base01 =     "1e2030"; # mantle
    base02 =     "363a4f"; # surface0
    base03 =     "494d64"; # surface1
    base04 =     "5b6078"; # surface2
    base05 =     "cad3f5"; # text
    base06 =     "f4dbd6"; # rosewater
    base07 =     "b7bdf8"; # lavender
    base08 =     "ed8796"; # red
    base09 =     "f5a97f"; # peach
    base0A =     "eed49f"; # yellow
    base0B =     "a6da95"; # green
    base0C =     "8bd5ca"; # teal
    base0D =     "8aadf4"; # blue
    base0E =     "c6a0f6"; # mauve
    base0F =     "f0c6c6"; # flamingo

    myStuff.myCat = {
      myGlobal-Flav   = "macchiato";
      myGlobal-FlavC  = "Macchiato";
      myGlobal-Color  = "sapphire";
      myGlobal-ColorC = "Sapphire";
    };

    myGlobalCatppuccin = pkgs.catppuccin.override {
      variant = myStuff.myCat.myGlobal-Flav;
      accent = myStuff.myCat.myGlobal-Color;
      themeList = [ "alacritty" "bat" "bottom" "btop" "element" "grub" "hyprland" "k9s" "kvantum" "lazygit"
                    "lxqt" "qt5ct" "refind" "rofi" "starship" "thunderbird" "waybar" ];
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

    myKvantumCatppuccin = pkgs.catppuccin-kvantum.override {
      variant = myStuff.myCat.myGlobal-Flav;
      accent = myStuff.myCat.myGlobal-Color;
    };

    myGTKCatppuccin = pkgs.catppuccin-gtk.override {
      variant = myStuff.myCat.myGlobal-Flav;
      accents = [ myStuff.myCat.myGlobal-Color ];
      size = "standard";
     #tweaks = [ "black" ];
    };

  in

{ config = lib.mkIf (config.my.theme == "catppuccin-uni") {

  home.packages = [

    global-package

    gtk-package
    qt-package
   #kvantum-package
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
    platformTheme.name = qt-platform; # WARNING BE CAREFUL, QT BREAKS A LOT
    style = {
      name = qt-name; # WARNING style name for kvantum platform is "Kvantun", and for qtct platform is "kvantum" (lower case!)
      package = qt-package;
    };
  };

 #home.sessionVariables = {
 #  QT_QPA_PLATFORMTHEME = lib.mkForce "";
 #};

  services.xsettingsd = {
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
  xsession.initExtra = ''
    xsetroot -solid ${Base} &
    hsetroot -cover ${wallpaper} &
    xrdb -load ${config.xresources.path} &
    xrdb -merge ${config.xresources.path} &
    xsetroot -cursor_name left_ptr &
    ${config.services.dunst.package}/bin/dunst &
    blueman-applet &
    ${pkgs.feh}/bin/feh --bg-fill ${wallpaper} &
  '';
  xsession.profileExtra = ''
    xsetroot -cursor_name left_ptr &
  '';
  xresources.properties = {
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
 #xsession = {   # DEPRICATED
 #  pointerCursor = {
 #    defaultCursor = x-cursor;
 #    name = x-cursor;
 #   #package = x-cursor-package;
 #    size = cursor-size;
 #  };
 #};

  services.flatpak = {
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
    sway.enable = true;
    hyprcursor = {
      enable = true;
      size = cursor-size;
    };
    x11 = {
      enable = true;
      defaultCursor = x-cursor;
    };
  };

  fonts = {
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

  xsession.windowManager.i3.config = {
    fonts = {
      names = [ MonoSpace Sans ];
      style = i3Style;
      size = MonoSizeI3;
    };
    startup = [ { command = "feh --bg-fill ${wallpaper}"; always = true; } ];
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
  programs.i3status-rust = {
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
  wayland.windowManager.sway.config = {
    fonts = config.xsession.windowManager.i3.config.fonts;
    colors = config.xsession.windowManager.i3.config.colors;
    bars = config.xsession.windowManager.i3.config.bars;
  };
  xsession.windowManager.bspwm = {
    settings = {
      presel_feedback_color = Overlay1;
      active_border_color = Lavender;
      focused_border_color = Lavender;
      normal_border_color = Overlay0;
    };
    startupPrograms = [
      "feh --bg-fill ${wallpaper}"
    ];
  };

  programs.plasma = {
    enable = true;
    kwin = {
      titlebarButtons = { # “more-window-actions”, “application-menu”, “on-all-desktops”, “minimize”, “maximize”, “close”, “help”, “shade”, “keep-below-windows”, “keep-above-windows”
        left = plasma-decoration-left;
        right = plasma-decoration-right;
      };
    };
    workspace = {
      lookAndFeel = plasma-look;      # Global Theme  # plasma-apply-lookandfeel --list
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
  };

  programs.gnome-shell = {
    enable = true;
   #extensions = [ ];
    theme = {
      package = gtk-package;
      name = gtk-theme;
    };
  };

  dconf.settings = {

     # Cinnamon
    "org/cinnamon/desktop/interface" = {
      gtk-theme = gtk-theme;
      icon-theme = gtk-icon;
    };
    "org/cinnamon/theme" = {
      name = cinnamon-theme;
    };
    "org/cinnamon/desktop/background" = {
      picture-uri = wallpaper-alt;
    };

     # Mate
    "org/mate/marco/general" = {
      theme = mate-theme;
    };
    "org/mate/desktop/background" = {
      picture-filename = wallpaper;
      picture-options = "wallpaper";
    };
    "org/mate/desktop/interface" = {
      gtk-theme = gtk-theme;
      icon-theme = gtk-icon;
    };
    "org/mate/desktop/peripherals/mouse" = {
      cursor-theme = gtk-cursor;
    };

     # Onboard
    "org/onboard" = {
      layout = onboard-layout;
      theme = onboard-theme;
    };
    "org/onboard/theme-settings" = {
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

  xfconf.settings = {
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
  };

  programs = {
    konsole = {
      enable=true;
      customColorSchemes = {
        Konsole-catppuccin-macchiato = konsole-scheme;
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
    kate = {
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
    kitty = {
      settings = {
        background = kitty-back;
        tab_bar_background = kitty-back-tab;
        tab_bar_margin_color = kitty-marg-tab;
        active_tab_foreground = kitty-for-tab-act;
        active_tab_background = kitty-back-tab-act;
        inactive_tab_foreground = kitty-for-tab-inact;
        inactive_tab_background = kitty-back-tab-inact;
      };
      font = {
        name = lib.mkForce MonoSpace;
        size = lib.mkForce MonoSizeKitty;
      };
    };
    freetube = {
      settings = {
        baseTheme = freetube-base;
        mainColor = freetube-main;
        secColor = freetube-sec;
      };
    };
    superfile = {
      settings = {
        theme = superfile-theme;
        transparent_background = false;
      };
     #themes = {};
    };
    rofi = {
      font = MonoRofi;
     #theme = { };
    };
   #btop.settings = { color_theme = "catppuccin_macchiato.theme"; };
  };
  services = {
    polybar = {
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
          font-0 = MonoPoly;
         #font-1 = "FontAwesome:size=12;3";
         #font-2 = "Hack Nerd Font:size=12;3";
        };
        "module/xworkspaces" = {
          label = {
            active = {
              background = Sapphire;
              underline= Blue;
            };
            urgent.background = Red;
            empty.foreground = Mantle;
          };
        };
        "module/filesystem" = {
         #label-mounted = %{F#F0C674}%mountpoint%%{F-} %percentage_used%%;
          label-unmounted-foreground = Mantle;
        };
        "module/pulseaudio" = {
          format-volume-prefix-foreground = Text;
          label-muted-foreground = Red;
        };
        "module/lock" = {
          format-foreground = Text;
          format-background = Base;
        };
        "module/memory" = {
          format-prefix-foreground = Text;
        };
        "module/cpu" = {
          format-prefix-foreground = Text;
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
          label-foreground = Flamingo;
        };
        "module/date" = {
          label-foreground = Text;
        };
      };
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
    icon = {
      source = "${gtk-icon-package}/share/icons";
      target = ".icons/";
      recursive = true;
    };
    icon2 = {
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

    openbox-autostart = {
      target = "openbox/autostart";
      text = ''
        ${pkgs.feh}/bin/feh --bg-fill ${wallpaper} &
        ${config.services.polybar.package}/bin/polybar example &
        ${pkgs.plank}/bin/plank &
      '';
    };

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

  };

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
    kvantum = {
      enable = true;
      apply = true;
        flavor = myStuff.myCat.myGlobal-Flav;
        accent = myStuff.myCat.myGlobal-Color;
    };
    hyprland = {
      enable = true;
        flavor = myStuff.myCat.myGlobal-Flav;
        accent = myStuff.myCat.myGlobal-Color;
    };
    brave = {
      enable = true;
        flavor = myStuff.myCat.myGlobal-Flav;
    };
    firefox.profiles = {
      default = {
        enable = true;
        force = false;
          flavor = myStuff.myCat.myGlobal-Flav;
          accent = myStuff.myCat.myGlobal-Color;
      };
    };
    kitty = {
      enable = true;
        flavor = myStuff.myCat.myGlobal-Flav;
    };
    starship = {
      enable = true;
        flavor = myStuff.myCat.myGlobal-Flav;
    };
    btop = {
      enable = true;
        flavor = myStuff.myCat.myGlobal-Flav;
    };
  };

};}
