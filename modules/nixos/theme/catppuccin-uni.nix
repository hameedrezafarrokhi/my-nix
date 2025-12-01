{ config, pkgs, lib, ... }:

  let

    plymouth-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}";
    plymouth-package = myPlymouthCatppuccin;
    plymouth-logo = "${pkgs.nixos-icons}/share/icons/hicolor/96x96/apps/nix-snowflake.png";

    sddm-theme = "breeze";
    sddm-package = mySDDMCatppuccin;
    sddm-cursor-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}-cursors";
    sddm-cursor-package = myCursorCatppuccin;
    sddm-cursor-size = 24;

    displayManager-background = "${pkgs.catppuccin-sddm-corners}/share/sddm/themes/catppuccin-sddm-corners/backgrounds/hashtags-large.png";
    backgroundFill = "#1D2231";

    icons-package = myIconCatppuccin;

    MonoSpace = "Comic Sans MS";
    MonoAlt = "Monofur Nerd Font Mono";
    Sans = "Comic Sans MS";
    Serif = "Comic Sans MS";
    Console = "${ConsolePackage}/share/consolefonts/ter-i16b.psf.gz";
    ConsolePackage = pkgs.terminus_font;
    plymouth-font = "${pkgs.dejavu_fonts.minimal}/share/fonts/truetype/DejaVuSans.ttf";
    Emoji = "Blobmoji";

    MonoSize = "10";


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

    myPlymouthCatppuccin = pkgs.catppuccin-plymouth.override {
        variant = myStuff.myCat.myGlobal-Flav; };

    mySDDMCatppuccin = pkgs.catppuccin-sddm.override {
      flavor = myStuff.myCat.myGlobal-Flav;
      font = MonoSpace;
      fontSize = MonoSize;
     #background = null;
     #loginBackground = false;
    };

    myCursorCatppuccin = pkgs.catppuccin-cursors."${myStuff.myCat.myGlobal-Flav}${myStuff.myCat.myGlobal-ColorC}";

    myIconCatppuccin = pkgs.catppuccin-papirus-folders.override {
      flavor = myStuff.myCat.myGlobal-Flav;
      accent = myStuff.myCat.myGlobal-Color;
    };

  in

{ config = lib.mkIf (config.my.systemTheme == "catppuccin-uni") {

  environment.systemPackages = with pkgs; [

   #catppuccin-sddm-corners
   #sddm-sugar-dark

   #(sddm-astronaut.override {
   #  embeddedTheme = "astronaut";
   #  themeConfig = {
   #   #ScreenWidth="1920";
   #   #ScreenHeight="1080";
   #   #ScreenPadding="";
   #    Font=MonoSpace;
   #    FontSize=MonoSize;
   #    RoundCorners="20";
   #   #Locale="";
   #    HourFormat="HH:mm";
   #    DateFormat="dddd d MMMM";
   #   #HeaderText="";
   #    FormPosition="center";
   #    Blur="0.0";
   #    Background="";
   #    BackgroundColor=backgroundFill;
   #  };
   #})

   #(pkgs.where-is-my-sddm-theme.override {
   #  themeConfig.General = {
   #   #background =displayManager-background ;
   #   #backgroundMode = "none";
   #    backgroundFill= backgroundFill;
   #    showSessionsByDefault=true;
   #    sessionsFontSize=13;
   #    showUsersByDefault=true;
   #    font=MonoSpace;
   #    passwordFontSize=20;
   #    passwordInputWidth=0.7;
   #    passwordcharacter="";
   #    cursorBlinkAnimation=false;
   #    passwordInputCursorVisible=false;
   #  };
   #})

   #(writeTextDir "share/sddm/themes/catppuccin-sddm-corners/theme.conf.user" ''
   #[General]
   #LoginScale="0.080"
   #UserPictureBorderWidth="0"
   #TextFieldHighlightWidth="0"
   #Padding="25"
   #GeneralFontSize="8"
   #'')

    (writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
    [General]
    background=${displayManager-background}
    '')

  ] ++ [

    plymouth-package
    icons-package
    sddm-package
    sddm-cursor-package

  ];

  boot.plymouth = {
    enable = true;
   #package = pkgs.plymouth.override {
   #            systemd = config.boot.initrd.systemd.package;
   #          };
    themePackages = lib.mkForce [ plymouth-package ];
    theme = lib.mkForce plymouth-theme;
    logo = lib.mkForce plymouth-logo;
   #font = lib.mkForce plymouth-font;
   #tpm2-totp = {
   #  enable = false;
   #  package = pkgs.tpm2-totp-"with"-plymouth;
   #};
  };

  services.displayManager = {
    sddm = {
     #theme = "where_is_my_sddm_theme";
     #theme = "sddm-astronaut-theme";
     #theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}-mauve";
     #theme = "breeze";
      theme = sddm-theme;
      settings = {
        Theme = {
          CursorTheme = sddm-cursor-theme;
          CursorSize = sddm-cursor-size;
        };
      };
    };
  };

  fonts = {
    fontconfig = {
      defaultFonts = {
        monospace = lib.mkForce [ MonoAlt ];
        serif = lib.mkForce [ MonoSpace ];
        sansSerif = lib.mkForce [ Sans ];
        emoji = lib.mkForce [ Emoji ];
      };
    };
  };

  console = {
    packages = [ ConsolePackage ];  #font, keymap etc packages
    font = lib.mkForce Console;
 #  colors = [
 #    base00
 #    base01
 #    base02
 #    base03
 #    base04
 #    base05
 #    base06
 #    base07
 #    base08
 #    base09
 #    base0A
 #    base0B
 #    base0C
 #    base0D
 #    base0E
 #    base0F
 #  ];
  };

  services.xserver.desktopManager.lxqt.iconThemePackage = icons-package;

  catppuccin = {
    enable = true;
      flavor = myStuff.myCat.myGlobal-Flav;
      accent = myStuff.myCat.myGlobal-Color;
   #cache.enable = true;
    grub = {
      enable = false;
        flavor = myStuff.myCat.myGlobal-Flav;
    };
    limine = {
      enable = true;
        flavor = myStuff.myCat.myGlobal-Flav;
    };
    plymouth = {
      enable = true;
        flavor = myStuff.myCat.myGlobal-Flav;
    };
    sddm = {
      enable = false;
        flavor = myStuff.myCat.myGlobal-Flav;
       #accentColor = "<color>";
        assertQt6Sddm = true;
       #background =
        loginBackground = true;
        font = MonoSpace;
        fontSize = MonoSize;
       #userIcon = true; #place a file in ~/.face.icon or FacesDir/username.face.icon
    };
    tty = {
      enable = true;
      flavor = myStuff.myCat.myGlobal-Flav;
    };
    gitea = {
      enable = true;
        flavor = myStuff.myCat.myGlobal-Flav;
        accent = myStuff.myCat.myGlobal-Color;
    };
  };

};}
