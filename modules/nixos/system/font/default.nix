{ config, pkgs, lib, ... }:

let

  cfg = config.my.fonts;

in

{

  options.my.fonts.enable = lib.mkEnableOption "enable fonts";

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      fontconfig freetype
      font-manager gnome-font-viewer fontfinder
      embellish get-google-fonts fontpreview fontfor
      fontforge fontforge-fonttools
      fontforge-gtk
    ];

    console = {                                  # to find font "sudo find /nix/store -name '*terminus*'"
      packages = with pkgs; [ terminus_font ];   #font, keymap etc packages
      font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-i16b.psf.gz";
      keyMap = "us";
    };

    fonts = {

      enableDefaultPackages = true;
      enableGhostscriptFonts = true;

      fontconfig = {
        enable = true;
       #cache32Bit = true;  #32bit support for some app

        allowType1 = false;
        allowBitmaps = true;
        useEmbeddedBitmaps = false;

        antialias = true;
        subpixel = {
          rgba = "none";
          lcdfilter = "default";
        };
        hinting = {
          enable = true;
          style = "slight";
          autohint = false;
        };

       #localConf = "";     #has higher priority than defaultFonts
        includeUserConf = true;
        defaultFonts = {
          monospace = lib.mkDefault [ "Hack Nerd Font Mono" ];
          serif = lib.mkDefault [ "Noto Serif" ];
          sansSerif = lib.mkDefault [ "Noto Sans" ];
          emoji = lib.mkDefault [ "Noto Color Emoji" ];
        };
      };

      fontDir = {
        enable = true;
        decompressFonts = config.programs.xwayland.enable;
      };

      packages = with pkgs; [
        junction-font

        noto-fonts /*noto-fonts-emoji*/ noto-fonts-color-emoji noto-fonts-monochrome-emoji noto-fonts-emoji-blob-bin

        terminus_font tamsyn termsyn terminus_font_ttf

        roboto roboto-mono roboto-serif roboto-flex

        dejavu_fonts hack-font font-awesome bront_fonts

        ir-standard-fonts vazir-fonts vazir-code-font
        nika-fonts behdad-fonts shabnam-fonts samim-fonts sahel-fonts
        parastoo-fonts nahid-fonts gandom-fonts

        corefonts   # ms unfree fonts
        comic-mono

        fira-sans

        material-symbols material-design-icons material-icons

        nerd-fonts.bitstream-vera-sans-mono nerd-fonts.fantasque-sans-mono nerd-fonts.aurulent-sans-mono nerd-fonts.comic-shanns-mono
        nerd-fonts.iosevka-term-slab nerd-fonts.bigblue-terminal nerd-fonts.dejavu-sans-mono nerd-fonts.daddy-time-mono
        nerd-fonts.droid-sans-mono nerd-fonts.inconsolata-lgc nerd-fonts.proggy-clean-tt nerd-fonts.shure-tech-mono
        nerd-fonts.departure-mono nerd-fonts.jetbrains-mono nerd-fonts.caskaydia-cove nerd-fonts.recursive-mono
        nerd-fonts.sauce-code-pro nerd-fonts.code-new-roman nerd-fonts.inconsolata-go nerd-fonts.caskaydia-mono
        nerd-fonts.open-dyslexic nerd-fonts.atkynson-mono nerd-fonts.terminess-ttf nerd-fonts.iosevka-term
        nerd-fonts.symbols-only nerd-fonts.martian-mono nerd-fonts.adwaita-mono nerd-fonts.commit-mono nerd-fonts.roboto-mono
        nerd-fonts.inconsolata nerd-fonts.intone-mono nerd-fonts.ubuntu-mono nerd-fonts.victor-mono nerd-fonts.envy-code-r
        nerd-fonts.ubuntu-sans nerd-fonts.heavy-data nerd-fonts.im-writing nerd-fonts.space-mono nerd-fonts.geist-mono
        nerd-fonts.liberation nerd-fonts.monaspace nerd-fonts.fira-mono nerd-fonts.anonymice nerd-fonts.fira-code
        nerd-fonts.blex-mono nerd-fonts.zed-mono nerd-fonts.d2coding nerd-fonts.overpass nerd-fonts._0xproto
        nerd-fonts.mononoki nerd-fonts.meslo-lg nerd-fonts.gohufont nerd-fonts.hasklug nerd-fonts.cousine
        nerd-fonts.go-mono nerd-fonts.iosevka nerd-fonts.monofur nerd-fonts.profont nerd-fonts.monoid
        nerd-fonts.ubuntu nerd-fonts.hurmit nerd-fonts.lekton nerd-fonts.lilex nerd-fonts.agave
        nerd-fonts.tinos nerd-fonts.arimo nerd-fonts._3270 nerd-fonts.hack nerd-fonts.noto nerd-fonts."m+"
      ];
    };



  };

}
