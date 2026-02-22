{ config, pkgs, lib, ... }:

let

  cfg = config.my.apps;

in

{

  options.my.apps = {

    alacritty.enable = lib.mkEnableOption "alacritty";
    amberol.enable = lib.mkEnableOption "amberol";
    bat.enable = lib.mkEnableOption "bat";
    bazaar.enable = lib.mkEnableOption "bazaar";
    bluetuith.enable = lib.mkEnableOption "bluetuith";
    borg.enable = lib.mkEnableOption "borg";
    btop.enable = lib.mkEnableOption "btop";
    cava.enable = lib.mkEnableOption "cava";
    copyq.enable = lib.mkEnableOption "copyq";
    crystal-dock.enable = lib.mkEnableOption "crystal dock";
    direnv.enable = lib.mkEnableOption "direnv";
    dockbarx.enable = lib.mkEnableOption "dockbarx";
    dunst.enable = lib.mkEnableOption "dunst";
    fastfetch.enable = lib.mkEnableOption "fastfetch";
    fd.enable = lib.mkEnableOption "fd";
    flameshot.enable = lib.mkEnableOption "flameshot";
    foliate.enable = lib.mkEnableOption "foliate";
    freetube.enable = lib.mkEnableOption "freetube";
    fzf.enable = lib.mkEnableOption "fzf";
    geany.enable = lib.mkEnableOption "geany";
    git.enable = lib.mkEnableOption "git";
    ghostty.enable = lib.mkEnableOption "ghostty";
    gpg.enable = lib.mkEnableOption "gpg";
    htop.enable = lib.mkEnableOption "htop";
    jgmenu.enable = lib.mkEnableOption "jgmenu";
    joplin.enable = lib.mkEnableOption "joplin";
    kdeconnect.enable =  lib.mkEnableOption "kde connect";
    keyrings.enable = lib.mkEnableOption "keyrings";
    kitty.enable = lib.mkEnableOption "kitty";
    lf.enable = lib.mkEnableOption "lf";
    ludusavi.enable = lib.mkEnableOption "ludusavi";
    lutris.enable = lib.mkEnableOption "lutris";
    mangohud.enable = lib.mkEnableOption "mangohud";
    mpv.enable = lib.mkEnableOption "mpv";
    neovim.enable = lib.mkEnableOption "neovim";
    nautilus.enable = lib.mkEnableOption "nautilus";
    obs.enable = lib.mkEnableOption "obs";
    obsidian.enable = lib.mkEnableOption "obsidian";
    onboard.enable = lib.mkEnableOption "onboard";
    onlyoffice.enable = lib.mkEnableOption "onlyoffice";
    pay-respects.enable = lib.mkEnableOption "pay-respects";
    plank.enable = lib.mkEnableOption "plank";
    qutebrowser.enable = lib.mkEnableOption "qutebrowser";
    resources.enable = lib.mkEnableOption "resources";
    rofi.enable = lib.mkEnableOption "rofi";
    sioyek.enable = lib.mkEnableOption "sioyek";
    starship.enable = lib.mkEnableOption "starship";
    superfile.enable = lib.mkEnableOption "superfile";
    swww.enable = lib.mkEnableOption "swww";
    television.enable = lib.mkEnableOption "television";
    tldr.enable = lib.mkEnableOption "tldr";
    tmux.enable = lib.mkEnableOption "tmux";
    udiskie.enable = lib.mkEnableOption "udiskie";
    vim.enable = lib.mkEnableOption "vim";
    yazi.enable = lib.mkEnableOption "yazi";
    yt-dlp.enable = lib.mkEnableOption "yt-dlp";
    wezterm.enable = lib.mkEnableOption "wezterm";
    wlogout.enable = lib.mkEnableOption "wlogout";

    webapps.enable = lib.mkEnableOption "webapps collection";

  };

    imports = [

      ./alacritty.nix
      ./amberol.nix
      ./bat.nix
      ./bazaar.nix
      ./bluetuith.nix
      ./borg.nix
      ./btop.nix
      ./cava.nix
      ./copyq.nix
      ./crystal-dock.nix
      ./direnv.nix
      ./dockbarx.nix
      ./dunst.nix
      ./fastfetch.nix
      ./fd.nix
      ./flameshot.nix
      ./foliate.nix
      ./freetube.nix
      ./fzf.nix
      ./geany.nix
      ./git.nix
      ./ghostty.nix
      ./gpg.nix
      ./htop.nix
      ./jgmenu.nix
      ./joplin.nix
      ./kdeconnect.nix
      ./keyrings.nix
      ./kitty.nix
      ./lf.nix
      ./ludusavi.nix
      ./lutris.nix
      ./mangohud.nix
      ./mpv.nix
      ./neovim.nix
      ./nautilus.nix
      ./obs.nix
      ./obsidian.nix
      ./onboard.nix
      ./onlyoffice.nix
      ./pay-respects.nix
      ./plank.nix
      ./qutebrowser.nix
      ./resources.nix
      ./rofi.nix
      ./sioyek.nix
      ./starship.nix
      ./superfile.nix
      ./swww.nix
      ./tldr.nix
      ./tmux.nix
      ./udiskie.nix
      ./vim.nix
      ./yazi.nix
      ./yt-dlp.nix
      ./television.nix
      ./wezterm.nix
      ./wlogout.nix

      ./webapps-chromium.nix
      ./webapps-firefox.nix

  ]
    ;

}
