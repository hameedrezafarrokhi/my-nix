{ config, pkgs, lib, ... }:

let

  cfg = config.my.apps;

in

{

  options.my.apps = {

    amberol.enable = lib.mkEnableOption "amberol";
    bazaar.enable = lib.mkEnableOption "bazaar";
    borg.enable = lib.mkEnableOption "borg";
    btop.enable = lib.mkEnableOption "btop";
    cava.enable = lib.mkEnableOption "cava";
    direnv.enable = lib.mkEnableOption "direnv";
    dunst.enable = lib.mkEnableOption "dunst";
    fastfetch.enable = lib.mkEnableOption "fastfetch";
    fd.enable = lib.mkEnableOption "fd";
    flameshot.enable = lib.mkEnableOption "flameshot";
    foliate.enable = lib.mkEnableOption "foliate";
    freetube.enable = lib.mkEnableOption "freetube";
    fzf.enable = lib.mkEnableOption "fzf";
    git.enable = lib.mkEnableOption "git";
    gpg.enable = lib.mkEnableOption "gpg";
    htop.enable = lib.mkEnableOption "htop";
    joplin.enable = lib.mkEnableOption "joplin";
    keyrings.enable = lib.mkEnableOption "keyrings";
    kitty.enable = lib.mkEnableOption "kitty";
    lf.enable = lib.mkEnableOption "lf";
    ludusavi.enable = lib.mkEnableOption "ludusavi";
    lutris.enable = lib.mkEnableOption "lutris";
    mangohud.enable = lib.mkEnableOption "mangohud";
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
    udiskie.enable = lib.mkEnableOption "udiskie";
    vim.enable = lib.mkEnableOption "vim";
    yazi.enable = lib.mkEnableOption "yazi";
    yt-dlp.enable = lib.mkEnableOption "yt-dlp";

    webapps.enable = lib.mkEnableOption "webapps collection";

  };

    imports = [

      ./amberol.nix
      ./bazaar.nix
      ./borg.nix
      ./btop.nix
      ./cava.nix
      ./direnv.nix
      ./dunst.nix
      ./fastfetch.nix
      ./fd.nix
      ./flameshot.nix
      ./foliate.nix
      ./freetube.nix
      ./fzf.nix
      ./git.nix
      ./gpg.nix
      ./htop.nix
      ./joplin.nix
      ./keyrings.nix
      ./kitty.nix
      ./lf.nix
      ./ludusavi.nix
      ./lutris.nix
      ./mangohud.nix
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
      ./udiskie.nix
      ./vim.nix
      ./yazi.nix
      ./yt-dlp.nix
      ./television.nix

      ./webapps-chromium.nix
      ./webapps-firefox.nix

  ]
    ;

}
