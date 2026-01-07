{ config, pkgs, lib, ... }:

  let

    cursor-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}-${myStuff.myCat.myGlobal-Color}-cursors";

    plymouth-theme = "catppuccin-${myStuff.myCat.myGlobal-Flav}";
    plymouth-package = myPlymouthCatppuccin;
    plymouth-logo = "${pkgs.nixos-icons}/share/icons/hicolor/96x96/apps/nix-snowflake.png";

    sddm-theme = "breeze";
    sddm-package = mySDDMCatppuccin;
    sddm-cursor-theme = cursor-theme;
    sddm-cursor-package = myCursorCatppuccin;
    sddm-cursor-size = 24;

    displayManager-background = "${pkgs.catppuccin-sddm-corners}/share/sddm/themes/catppuccin-sddm-corners/backgrounds/hashtags-large.png";
    backgroundFill = "#1D2231";

    icons-package = myIconCatppuccin;

    MonoSpace = "Comic Mono";
    MonoAlt = "Monofur Nerd Font Mono";
    Sans = "Comic Sans MS";
    Serif = "Comic Sans MS";
    Console = "${ConsolePackage}/share/consolefonts/ter-i16b.psf.gz";
    ConsolePackage = pkgs.terminus_font;
    plymouth-font = "${pkgs.dejavu_fonts.minimal}/share/fonts/truetype/DejaVuSans.ttf";
    Emoji = "Blobmoji";

    MonoSize = "10";


    BRosewater = "f4dbd6";  Rosewater = "#${Rosewater}"; base00 =     BBase;
    BFlamingo =  "f0c6c6";  Flamingo =  "#${Flamingo}";  base01 =     BRed;
    BPink =      "f5bde6";  Pink =      "#${Pink}";      base02 =     BGreen;
    BMauve =     "c6a0f6";  Mauve =     "#${Mauve}";     base03 =     BYellow;
    BRed =       "ed8796";  Red =       "#${Red}";       base04 =     BBlue;
    BMaroon =    "ee99a0";  Maroon =    "#${Maroon}";    base05 =     BPink;
    BPeach =     "f5a97f";  Peach =     "#${Peach}";     base06 =     BTeal;
    BYellow =    "eed49f";  Yellow =    "#${Yellow}";    base07 =     BSubtext1;
    BGreen =     "a6da95";  Green =     "#${Green}";     base08 =     BSurface2;
    BTeal =      "8bd5ca";  Teal =      "#${Teal}";      base09 =     BRed;
    BSky =       "91d7e3";  Sky =       "#${Sky}";       base0A =     BGreen;
    BSapphire =  "7dc4e4";  Sapphire =  "#${Sapphire}";  base0B =     BYellow;
    BBlue =      "8aadf4";  Blue =      "#${Blue}";      base0C =     BBlue;
    BLavender =  "b7bdf8";  Lavender =  "#${Lavender}";  base0D =     BPink;
                                                         base0E =     BTeal;
    BText =      "cad3f5";  Text =      "#${Text}";      base0F =     BSubtext0;
    BSubtext1 =  "b8c0e0";  Subtext1 =  "#${Subtext1}";
    BSubtext0 =  "a5adcb";  Subtext0 =  "#${Subtext0}";
    BOverlay2 =  "939ab7";  Overlay2 =  "#${Overlay2}";
    BOverlay1 =  "8087a2";  Overlay1 =  "#${Overlay1}";
    BOverlay0 =  "6e738d";  Overlay0 =  "#${Overlay0}";
    BSurface2 =  "5b6078";  Surface2 =  "#${Surface2}";
    BSurface1 =  "494d64";  Surface1 =  "#${Surface1}";
    BSurface0 =  "363a4f";  Surface0 =  "#${Surface0}";
    BBase =      "24273a";  Base =      "#${Base}";
    BMantle =    "1e2030";  Mantle =    "#${Mantle}";
    BCrust =     "181926";  Crust =     "#${Crust}";

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
    colors = [
      base00
      base01
      base02
      base03
      base04
      base05
      base06
      base07
      base08
      base09
      base0A
      base0B
      base0C
      base0D
      base0E
      base0F
    ];
  };

  services.xserver.desktopManager.lxqt.iconThemePackage = icons-package;

 #programs.dconf.profiles.gdm.databases = [
 #  {
 #    lockAll = true;
 #    settings."org/gnome/desktop/interface" = {
 #      cursor-theme = cursor-theme;
 #    };
 #  }
 #];

  catppuccin = {
    enable = true;
    flavor = myStuff.myCat.myGlobal-Flav;
    accent = myStuff.myCat.myGlobal-Color;
   #cache.enable = true;

    cursors.enable = false;
    plymouth.enable = false;
    tty.enable = false;
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
  };

 #stylix.targets = {
 #  console.enable = false;
 #  plymouth.enable = false;
 #};

   #fcitx5           C
   #forgejo          C  S
   #gitea            C
   #grub             C  S
   #gtk (gdm icons)  C
   #limine           C  S
   #lightdm             S
   #regreet             S

};}
