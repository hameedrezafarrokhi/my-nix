{ config, pkgs, lib, nix-path, ... }:

let

  rofi-noter = pkgs.writeShellScriptBin "rofi-noter" ''
    # Credits: https://github.com/rahriver/rofi-noter
    ${builtins.readFile ./scripts/rofi-noter}
  '';

  rofi-keepassxc = pkgs.writeShellScriptBin "rofi-keepassxc" ''
    # Credits: https://github.com/wzykubek/rofi-keepassxc
    ${builtins.readFile ./scripts/rofi-keepassxc}
  '';

  rofi-books = pkgs.writeShellScriptBin "rofi-books" ''
    # Credits: https://github.com/miroslavvidovic/rofi-scripts
    ${builtins.readFile ./scripts/rofi-books}
  '';

  rofi-github = pkgs.writeShellScriptBin "rofi-github" ''
    # Credits: https://github.com/miroslavvidovic/rofi-scripts
    ${builtins.readFile ./scripts/rofi-github}
  '';

  rofi-web = pkgs.writeShellScriptBin "rofi-web" ''
    # Credits: https://github.com/miroslavvidovic/rofi-scripts
    ${builtins.readFile ./scripts/rofi-web}
  '';

  rofi_trans = pkgs.writeShellScriptBin "rofi_trans" ''
    # Credits: https://github.com/garyparrot/rofi-translate
    ${builtins.readFile ./scripts/rofi_trans}
  '';

  rofi_trans_brief = pkgs.writeShellScriptBin "rofi_trans_brief" ''
    # Credits: https://github.com/garyparrot/rofi-translate
    ${builtins.readFile ./scripts/rofi_trans_brief}
  '';

  rofi_trans_delete = pkgs.writeShellScriptBin "rofi_trans_delete" ''
    # Credits: https://github.com/garyparrot/rofi-translate
    ${builtins.readFile ./scripts/rofi_trans_delete}
  '';

  rofi_trans_verbose = pkgs.writeShellScriptBin "rofi_trans_verbose" ''
    # Credits: https://github.com/garyparrot/rofi-translate
    ${builtins.readFile ./scripts/rofi_trans_verbose}
  '';

  rofi_verbose = pkgs.writeShellScriptBin "rofi_verbose" ''
    # Credits: https://github.com/garyparrot/rofi-translate
    ${builtins.readFile ./scripts/rofi_verbose}
  '';

  rofi-sound = pkgs.writeShellScriptBin "rofi-sound" ''
    # Credits: https://github.com/kellya/rofi-sound
    ${builtins.readFile ./scripts/rofi-sound}
  '';

  rofi-record = pkgs.writeShellScriptBin "rofi-record" ''
    # Credits: https://github.com/Andrey0189/recordrofi
    ${builtins.readFile ./scripts/rofi-record}
  '';

  rofi-wpctl = pkgs.writeShellScriptBin "rofi-wpctl" ''
    # Credits: https://codeberg.org/mikesaidani/rofi-wpctl
    ${builtins.readFile ./scripts/rofi-wpctl}
  '';

  rofi-vpn-mode = pkgs.writeShellScriptBin "rofi-vpn-mode" ''
    # Credits: https://codeberg.org/silvio/rofi-vpn-mode
    ${builtins.readFile ./scripts/rofi-vpn-mode}
  '';

  rofi-vpn-list = pkgs.writeShellScriptBin "rofi-vpn-list" ''
    # Credits: https://codeberg.org/silvio/rofi-vpn-mode
    rofi -show vpn -modi "vpn:$(which rofi-vpn-mode)"
  '';

  rofi-checklist = pkgs.writeShellScriptBin "rofi-checklist" ''
    # Credits: https://codeberg.org/ElnuDev/rofi-checklist
    ${builtins.readFile ./scripts/rofi-checklist}
  '';

  rofi-clock = pkgs.writeShellScriptBin "rofi-clock" ''
    ${builtins.readFile ./scripts/rofi-clock}
  '';

  rofi-quick-calc = pkgs.writeScriptBin "rofi-quick-calc" ''
    ${builtins.readFile ./scripts/rofi-quick-calc}
  '';

  rofi-scrn = pkgs.writeShellScriptBin "rofi-scrn" ''
    # Credits: https://github.com/ceuk/rofi-screenshot
    export ROFI_SCREENSHOT_DIR=$XDG_PICTURES_DIR/Screenshots
    export ROFI_SCREENSHOT_DATE_FORMAT="+%d-%m-%Y %H:%M:%S"
    ${builtins.readFile ./scripts/rofi-screenshot}
  ''; # -s for stop recording

  rofi-shortcuts = pkgs.writeShellScriptBin "rofi-shortcuts" ''
    #"$(cat ~/.config/rofi/rofi-shortcuts/rofi-shortcuts.conf | rofi -i -dmenu -p 'shortcuts')"
    "$(cat ${nix-path}/modules/hm/apps/rofi/rofi-shortcuts.conf | rofi -i -dmenu -p 'shortcuts')"
  '';

  rofi-yt = pkgs.writeShellScriptBin "rofi-yt" ''
    # C-h -- prev page
    # C-l -- next page
    # C-c -- clear
    #-theme yt_search.rasi \
    rofi  -modi blocks \
        -show blocks \
        -normal-window \
        -blocks-wrap yt_search_rofi_blocks \
        -kb-mode-complete "Control+Alt+l" \
        -kb-remove-char-back "BackSpace,Shift+BackSpace" \
        -kb-custom-1 "Control+h" \
        -kb-custom-2 "Control+l" \
        -kb-custom-3 "Control+c"
  '';

in

{
  imports = [

  ];

  config = lib.mkIf (config.my.apps.rofi.enable) {

  home.packages = [
    pkgs.rofi-systemd
    rofi-clock
    rofi-yt
    rofi-quick-calc
    rofi-scrn
    rofi-github
    rofi-books
    rofi-web
    rofi_verbose
    rofi_trans
    rofi_trans_brief
    rofi_trans_delete
    rofi_trans_verbose
    rofi-sound
    rofi-shortcuts
    rofi-record
    rofi-wpctl
    rofi-vpn-mode
    rofi-checklist
    rofi-noter
    rofi-vpn-list
    rofi-keepassxc

   #pkgs.rofi-rbw-x11
   #pkgs.rofi-rbw-wayland
    pkgs.rofi-rbw

    pkgs.todofi-sh
    pkgs.clerk

    pkgs.bzmenu
    pkgs.iwmenu
    pkgs.pwmenu

    pkgs.ffcast
    pkgs.slop
    pkgs.xclip

    pkgs.udiskie

    pkgs.ddgr

    # themes
    (pkgs.callPackage ./themes/newmanls.nix { })
    (pkgs.callPackage ./themes/murzchnvok.nix { })

    # apps
    (pkgs.callPackage ./apps/rofi-desktop.nix { })
    (pkgs.callPackage ./apps/rofication.nix { })
    (pkgs.callPackage ./apps/rofi-ftw.nix { })
    (pkgs.callPackage ./apps/menu-calc.nix { })
    (pkgs.callPackage ./apps/rofi-udiskie.nix { })
    (pkgs.callPackage ./apps/rofi-search.nix { })
    (pkgs.callPackage ./apps/rofi-commands.nix { })
    (pkgs.callPackage ./apps/rofi-ytx.nix { })
    (pkgs.callPackage ./apps/rofi-cliphist.nix { })
    (pkgs.callPackage ./apps/rofi-copyq.nix { })
    (pkgs.callPackage ./apps/rofi-extended.nix { })
    (pkgs.callPackage ./apps/rofi-mixer.nix { })
    (pkgs.callPackage ./apps/rofi-nix-run.nix { })
    (pkgs.callPackage ./apps/rofi-nix.nix { })
   #(pkgs.callPackage ./apps/rofi-clip.nix { })    # needs appmenu gtk
    (pkgs.callPackage ./apps/rofi-fontawesome.nix { })
   #(pkgs.callPackage ./apps/rofi-chrome-switch.nix { })
    (pkgs.callPackage ./apps/rofi-powerblur.nix { })
   #(pkgs.callPackage ./apps/mounch.nix { })
   #(pkgs.callPackage ./apps/marcador.nix { })
    (pkgs.callPackage ./apps/marcador-bin.nix { })
    (pkgs.callPackage ./apps/rofi-shell.nix {
      bg = "#24273a";
      fg = "#cad3f5";
      bgAlt = "#1e2030";
    })

    (pkgs.callPackage ./apps/xdisplayinfo.nix { })

    # modules
    (pkgs.callPackage ./modules/python-rofi.nix { })

  ];

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
   #finalPackage = ;
    plugins = with pkgs; [

      rofimoji
      rofi-vpn
      rofi-top
      rofi-systemd
      rofi-screenshot
      rofi-power-menu
      rofi-network-manager
      rofi-nerdy
      rofi-mpd
      rofi-menugen
      rofi-games
      rofi-file-browser
      rofi-emoji
      rofi-calc
      rofi-bluetooth
      rofi-blezz
      rofi-pass-wayland
      rofi-pass
      rofi-obsidian
     #rofi-rbw-x11
     #rofi-rbw-wayland
      rofi-rbw
      rofi-pulse-select

    ]
    ++ [(pkgs.callPackage ../../../nixos/myPackages/rofi-blocks.nix { })]
   #++ [(pkgs.callPackage ./apps/rofi-chrome-switch.nix { })]
    ++ [(pkgs.callPackage ./apps/rofi-nix-run.nix { })]
    ;

    modes = [
      "drun"
     #"run"
     #"emoji"
     #"ssh"
     #"window"
     #"windowcd"
     #"combi"
     #"keys"
     #"filebrowser"
     #"calc"
     #"top"
     #"blezz"
     #"games"
     #"nerdy"
     #"file-browser-extended"
     #"recursivebrowser"
     #{
     #  name = "top";
     #  path = lib.getExe pkgs.rofi-top;
     #}
    ];
    cycle = true;
    terminal = "${lib.getExe pkgs.${config.my.default.terminal}}";

    location = "center"; # "bottom", "bottom-left", "bottom-right", "center", "left", "right", "top", "top-left" ....
   #yoffset = 0;
   #xoffset = 0;

   #pass = {
   #  stores = ;
   #  package = ;
   #  extraConfig = ;
   #  enable = ;
   #};

   #configPath = ;
   #extraConfig = '' '';

  };

  xdg.configFile = {
    "rofi/recorder.rasi".source = ./themes/recorder.rasi;
    "rofi/recfonts.rasi".source = ./themes/recfonts.rasi;
    "rofi/reccolors.rasi".source = ./themes/reccolors.rasi;
  };

};}
