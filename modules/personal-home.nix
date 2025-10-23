{ config, lib, pkgs, mypkgs, admin, ... }:

{

  imports = [ ./hm ];

  nix.package = pkgs.nix;
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = false;
   #allowBroken = true;
   #permittedInsecurePackages = [ ];
  };

  home = {
    username = admin;
    homeDirectory = "/home/${admin}";
  };

  my = lib.mkDefault {

    nix.enable = true;

    shells = [ "bash" "fish" ];
    shellAliases = true;
    xdg.enable = true;
    uwsm.enable = true;
    x11.enable = true;

    ssh.enable = true;

    keyboard = {
      xremap.enable = true;
    };

    kde = {
      plasma.enable = true;
      appletrc = null;
      kate.enable = true;
      konsole.enable = true;
      elisa.enable = true;
      ghostwriter.enable = true;
      okular.enable = true;
      wallpaper-engine.enable = false;
    };
    gnome.enable = true;
    cinnamon.enable = true;
    mate.enable = true;
    xfce.enable = true;
    hypr = {
      hyprland.enable = true;
    };
    niri.enable = true;
    sway.enable = true;
    river.enable = true;
    wayfire.enable = true;
    labwc.enable = true;
    dwm.enable = true;
    i3.enable = true;
    xmonad.enable = true;
    awesome.enable = true;
    qtile.enable = true;
    bspwm.enable = true;
    spectrwm.enable = true;
    herbstluftwm.enable = true;
    fluxbox.enable = true;
    mango.enable = true;
    rice-shells = [

      "niri-dms" "niri-noctalia"
      "hyprland-uwsm" "hyprland-noctalia" "hyprland-caelestia" "hyprland-dms" "hyprland-ax" "hyprland-ashell" "hyprland-exo"

    ];

    distrobox.enable = true;

    bar-shell.shells = [
      # wayland
      "ags" "quickshell" "waybar" "ashell" "ignis"
      # x11
      "polybar"
      "tint2"
     #"trayer"
    ];
    apps = {
      amberol.enable = true;
      bazaar.enable = false;
      borg.enable = true;
      btop.enable = true;
      cava.enable = true;
      direnv.enable = true;
      dunst.enable = true;
      fastfetch.enable = true;
      fd.enable = true;
      flameshot.enable = true;
      foliate.enable = true;
      freetube.enable = true;
      fzf.enable = true;
      git.enable = true;
      gpg.enable = true;
      htop.enable = true;
      joplin.enable = false;
      keyrings.enable = true;
      kitty.enable = true;
      lf.enable = true;
      ludusavi.enable = false;
      lutris.enable = true;
      mangohud.enable = true;
      neovim.enable = true;
      nautilus.enable = true;
      obs.enable = true;
      obsidian.enable = false;
      onboard.enable = true;
      onlyoffice.enable = true;
      pay-respects.enable = true;
      plank.enable = true;
      qutebrowser.enable = false;
      resources.enable = true;
      rofi.enable = true;
      sioyek.enable = true;
      starship.enable = true;
      superfile.enable = true;
      swww.enable = true;
      television.enable = true;
      tldr.enable = true;
      udiskie.enable = true;
      vim.enable = true;
      yazi.enable = true;
      yt-dlp.enable = true;

      webapps.enable = true;
    };

    gaming = {
      proton = {
        cachy.enable = true;
        ge.enable = true;
        sarek.enable = false;
      };
    };

    default = {

      terminal = "kitty";
      tui-editor = "nvim";
      gui-editor = "org.kde.kate";
      gui-editor-alt-name = "kate";
      file-manager = "org.kde.dolphin";
      browser = "brave-browser";
      browser-alt-name = "brave";
      browser-package = pkgs.brave;
      image-viewer = "org.kde.gwenview";
      video-player = "org.gnome.Showtime";
      audio-player = "io.bassi.Amberol";
      pdf-viewer = "org.kde.okular";
      archive-manager = "org.kde.ark";
    };

    firefox.enable = true;

    custom-desktop-entries.enable = true;

    theme = "catppuccin-uni";
    fonts.enable = true;
    nix-artwork.enable = true;

    flatpak.enable = true;

    inputs-readme-files.enable = true;

  };

}
