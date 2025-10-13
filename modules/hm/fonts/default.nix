{ config, pkgs, lib, ... }:

let

  cfg = config.my.fonts;

in

{

  options.my.fonts.enable =  lib.mkEnableOption "fonts";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [

        junction-font

        noto-fonts noto-fonts-emoji noto-fonts-color-emoji noto-fonts-monochrome-emoji noto-fonts-emoji-blob-bin

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

    home.activation = {
      FontLink2 = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "$HOME/.local/share/fonts/noto-fonts-color-emoji"
        cp -rn "${pkgs.noto-fonts-color-emoji}/share/fonts/noto" "$HOME/.local/share/fonts/noto-fonts-color-emoji"
        mkdir -p "$HOME/.local/share/fonts/noto-fonts-emoji-blob-bin"
        cp -rn "${pkgs.noto-fonts-emoji-blob-bin}/share/fonts/blobmoji" "$HOME/.local/share/fonts/noto-fonts-emoji-blob-bin"
        mkdir -p "$HOME/.local/share/fonts"
        cp -rn "${pkgs.noto-fonts}/share/fonts/noto" "$HOME/.local/share/fonts"
        mkdir -p "$HOME/.local/share/fonts/corefonts"
        cp -rn "${pkgs.corefonts}/share/fonts/truetype" "$HOME/.local/share/fonts/corefonts"
        mkdir -p "$HOME/.local/share/fonts/junction-font"
        cp -rn "${pkgs.junction-font}/share/fonts/opentype" "$HOME/.local/share/fonts/junction-font"
        mkdir -p "$HOME/.local/share/fonts/roboto"
        cp -rn "${pkgs.roboto}/share/fonts/truetype" "$HOME/.local/share/fonts/roboto"
        mkdir -p "$HOME/.local/share/fonts/terminus"
        cp -rn "${pkgs.terminus_font}/share/fonts/terminus" "$HOME/.local/share/fonts/terminus"
        mkdir -p "$HOME/.local/share/fonts/terminus-ttf"
        cp -rn "${pkgs.terminus_font_ttf}/share/fonts/truetype" "$HOME/.local/share/fonts/terminus-ttf"
        mkdir -p "$HOME/.local/share/fonts/tamsyn"
        cp -rn "${pkgs.tamsyn}/share/fonts/misc" "$HOME/.local/share/fonts/tamsyn"
        mkdir -p "$HOME/.local/share/fonts/termsyn"
        cp -rn "${pkgs.termsyn}/share/fonts" "$HOME/.local/share/fonts/termsyn"
        mkdir -p "$HOME/.local/share/fonts/roboto-serif"
        cp -rn "${pkgs.roboto-serif}/share/fonts/truetype" "$HOME/.local/share/fonts/roboto-serif"
        mkdir -p "$HOME/.local/share/fonts/roboto-flex"
        cp -rn "${pkgs.roboto-flex}/share/fonts/truetype" "$HOME/.local/share/fonts/roboto-flex"
        mkdir -p "$HOME/.local/share/fonts/dejavu-fonts"
        cp -rn "${pkgs.dejavu_fonts.full-ttf}/share/fonts/truetype" "$HOME/.local/share/fonts/dejavu-fonts"
        mkdir -p "$HOME/.local/share/fonts/hack-font"
        cp -rn "${pkgs.hack-font}/share/fonts/truetype" "$HOME/.local/share/fonts/hack-font"
        mkdir -p "$HOME/.local/share/fonts/bront-fonts"
        cp -rn "${pkgs.bront_fonts}/share/fonts/truetype" "$HOME/.local/share/fonts/bront-fonts"
        mkdir -p "$HOME/.local/share/fonts/ir-standard-fonts"
        cp -rn "${pkgs.ir-standard-fonts}/share/fonts/ir-standard-fonts" "$HOME/.local/share/fonts/ir-standard-fonts"
        mkdir -p "$HOME/.local/share/fonts/vazir-fonts"
        cp -rn "${pkgs.vazir-fonts}/share/fonts/truetype" "$HOME/.local/share/fonts/vazir-fonts"
        mkdir -p "$HOME/.local/share/fonts/vazir-code-font"
        cp -rn "${pkgs.vazir-code-font}/share/fonts/truetype" "$HOME/.local/share/fonts/vazir-code-font"
        mkdir -p "$HOME/.local/share/fonts/nika-fonts"
        cp -rn "${pkgs.nika-fonts}/share/fonts/nika-fonts" "$HOME/.local/share/fonts/nika-fonts"
        mkdir -p "$HOME/.local/share/fonts/behdad-fonts"
        cp -rn "${pkgs.behdad-fonts}/share/fonts/behrad-fonts" "$HOME/.local/share/fonts/behdad-fonts"
        mkdir -p "$HOME/.local/share/fonts/shabnam-fonts"
        cp -rn "${pkgs.shabnam-fonts}/share/fonts/shabnam-fonts" "$HOME/.local/share/fonts/shabnam-fonts"
        mkdir -p "$HOME/.local/share/fonts/samim-fonts"
        cp -rn "${pkgs.samim-fonts}/share/fonts/samim-fonts" "$HOME/.local/share/fonts/samim-fonts"
        mkdir -p "$HOME/.local/share/fonts/sahel-fonts"
        cp -rn "${pkgs.sahel-fonts}/share/fonts/sahel-fonts" "$HOME/.local/share/fonts/sahel-fonts"
        mkdir -p "$HOME/.local/share/fonts/parastoo-fonts"
        cp -rn "${pkgs.parastoo-fonts}/share/fonts/parastoo-fonts" "$HOME/.local/share/fonts/parastoo-fonts"
        mkdir -p "$HOME/.local/share/fonts/nahid-fonts"
        cp -rn "${pkgs.nahid-fonts}/share/fonts/nahid-fonts" "$HOME/.local/share/fonts/nahid-fonts"
        mkdir -p "$HOME/.local/share/fonts/gandom-fonts"
        cp -rn "${pkgs.gandom-fonts}/share/fonts/gandom-fonts" "$HOME/.local/share/fonts/gandom-fonts"
        mkdir -p "$HOME/.local/share/fonts/comic-mono"
        cp -rn "${pkgs.comic-mono}/share/fonts" "$HOME/.local/share/fonts/comic-mono"
        mkdir -p "$HOME/.local/share/fonts/fira-sans"
        cp -rn "${pkgs.fira-sans}/share/fonts/opentype" "$HOME/.local/share/fonts/fira-sans"
        mkdir -p "$HOME/.local/share/fonts/material-symbols"
        cp -rn "${pkgs.material-symbols}/share/fonts" "$HOME/.local/share/fonts/material-symbols"
        mkdir -p "$HOME/.local/share/fonts/material-design-icons"
        cp -rn "${pkgs.material-design-icons}/share/fonts" "$HOME/.local/share/fonts/material-design-icons"
        mkdir -p "$HOME/.local/share/fonts/material-icons"
        cp -rn "${pkgs.material-icons}/share/fonts" "$HOME/.local/share/fonts/material-icons"
        mkdir -p "$HOME/.local/share/fonts/nerd-fonts/monofur"
        cp -rn "${pkgs.nerd-fonts.monofur}/share/fonts" "$HOME/.local/share/fonts/nerd-fonts/monofur"
        mkdir -p "$HOME/.local/share/fonts/nerd-fonts/meslo-lg"
        cp -rn "${pkgs.nerd-fonts.meslo-lg}/share/fonts" "$HOME/.local/share/fonts/nerd-fonts/meslo-lg"
        mkdir -p "$HOME/.local/share/fonts/nerd-fonts/jetbrains-mono"
        cp -rn "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts" "$HOME/.local/share/fonts/nerd-fonts/jetbrains-mono"
      '';
    };

       #mkdir -p "$HOME/.local/share/fonts/font-awesome"
       #cp -rn "${pkgs.font-awesome}/share/fonts/opentype" "$HOME/.local/share/fonts/font-awesome"

  };

}
