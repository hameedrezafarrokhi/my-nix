{ config, lib, pkgs, mypkgs, admin, ... }:

{

  imports = [ ./nixos ];

  my = lib.mkDefault {

    boot = {
      bootloader = "systemd-boot";
      kernel = pkgs.linuxPackages_latest;
    };

    hardware = {
      gpu = "none";
      cpu = {
        brand = "intel";
        scx.enable = true;
        thermald.enable = true;
        opt = "power-profiles-daemon";
      };
      ram-tmp = {
        zram.enable = true;
        tmpfs.enable = true;
      };
      fan = "cooler-control";
      mounts = [ ];
      bluetooth.enable = true;
      sound = "pipewire";
      dbus.enable = true;
      fwupd.enable = true;
      libinput.enable = true;
      keyboard = {
        enable = true;
       #xremap.enable = false;
      };
      storage.enable = true;
      gamepads.enable = true;
      logitech.enable = true;
      printer.enable = false;
      scanner.enable = false;
      power = {
        upower.enable = false;
      };
      cd.enable = false;
    };

    tty = {
      startx.enable = true;
      sx.enable = true;
    };
    remoteDesktop = {
      xpra.enable = false;
      vnc.enable =  false;
    };
    display-manager = "sddm";
    defaultSession = "plasma";
    desktops = [

      "plasma"
      "cosmic"
      "cinnamon"
      "mate"
      "budgie"
      "xfce"
     #"lxqt"
      "lumina"
     #"retroarch"
     #"cde"               # WARNING BROKEN    (build fail)
      "enlightenment"     # WARNING BROKEN    (python 3.13 incompatibility)
     #"gnome" "pantheon"  # WARNING THE DEVIL

    ];
    window-managers = [

      "hyprland" "niri"
      "sway" "qtile" "dwl"
      "labwc" "river" "wayfire"
      "miracle-wm" "miriway"
      "mango"

      "icewm" "fluxbox" "openbox" "windowlab" "windowmaker"
      "i3" "spectrwm" "herbstluftwm" "dk"
      "dwm" "chadwm" "drew-wm" "titus-wm" "bread-wm"
      "bspwm" "awesome" "xmonad"
      "exwm" "wmderland" "ragnarwm" "notion" "pekwm" "mlvwm"
      "fvwm2" "fvwm3" "leftwm" "berry" "sawfish"
      "twm" "jwm" "ratpoison" "e16"
      "hypr"  # WARNING BROKEN

    ];
    rices-shells = config.home-manager.users.${admin}.my.rices-shells;
    x11.enable = true;
    xdg.enable = true;
    dconf.enable = true;

    security = {
      sudo.enable = true;
      polkit.enable = true;
      pam.enable = true;
      tpm.enable = true;
    };

    network = {
      enable = true;
      ssh.enable = true;
      vpn.enable = true;
      shares.enable = true;
      avahi.enable = true;
      nm-applet.enable = true;
      nfs.enable = true;
    };

    locale = "en_US.UTF-8";
    geoclue.enable = true;
    timeZone = "Asia/Tehran";
    fonts.enable = true;

    user = {
      enable = true;
      users = [

        admin
        "test"
        "root"
       #"hello"
       #"omarchy"

      ];
    };

    shell = {
      shells = [ "bash" "fish" ];
      default = "fish";
      alias.enable = true;
    };

    nix.enable = true;

    containers = {
      flatpak.enable = true;
      appimage.enable = true;
      podman.enable = true;
      docker.enable = false;
      waydroid.enable = false;
    };

    backup = {
      borg.enable = true;
      rsync.enable = true;
    };

    systemTheme = config.home-manager.users.${admin}.my.theme;

    software = {
      programs.enable = true;
      services.enable = true;

      connectivity.enable = true;
      codecs.enable = true;
      internet.enable = true;
      multimedia.enable = true;
      wallpaper.enable = true;
      disk-utils.enable = true;
      files.enable = true;
      docs.enable = true;
      tools.enable = true;
      audio-control.enable = true;
      daw.enable = true;
      productivity.enable = true;
      fetch.enable = true;
      basic-cli.enable = true;
      terminals.enable = true;
      wine.enable = true;
      hardware-monitor.enable = true;
      peripherals.enable = true;
      social.enable = true;
      ai.enable = true;
      theming.enable = true;
    };

    gaming = {
      steam.enable = true;
      native-games.enable = true;
      launchers.enable = true;
      tools.enable = true;
      emulators.enable = true;
    };

    default = config.home-manager.users.${admin}.my.default;

    inputs-readme-files.enable = true;
    home-manager.enable = true;

  };

  home-manager = {
    users = {

      ${admin} = {

        imports = [ ./hm ];

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
          rices-shells = [

            "niri-dms" "niri-noctalia"
            "hyprland-uwsm" "hyprland-noctalia" "hyprland-caelestia" "hyprland-dms" "hyprland-ax" "hyprland-ashell"

          ];

          distrobox.enable = true;

          bar-shell.shells = [
            # wayland
            "ags" "quickshell" "waybar" "ashell"
            # x11
            "polybar"
           #"tint2"   # WARNING BROKEN
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
      };

      test = {

        home = {
          username = "test";
          homeDirectory = "/home/test";
        };

        imports = [ ./hm/keyboard ];

        my.keyboard.xremap.enable = true;

      };

    };
  };

}
