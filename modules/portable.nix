{ config, lib, pkgs, mypkgs, admin, ... }:

{

  imports = [ ./nixos ];

  my = lib.mkDefault {

    boot = {
      bootloader = "systemd-boot";
      kernel = pkgs.linuxPackages_latest;
    };

    systemd.enable = true;
    hardware = {
      gpu = "none";
      cpu = {
        brand = "intel";
        opt = "power-profiles-daemon";
      };
      ram-tmp = {
        zram.enable = true;
        tmpfs.enable = true;
      };
      mounts = [ ];
      bluetooth.enable = true;
      sound = "pipewire";
      dbus.enable = true;
      fwupd.enable = true;
      libinput.enable = true;
      touchegg.enable = false;
      keyboard = {
        enable = true;
       #xremap.enable = false;
      };
      storage.enable = true;
      power = {
        upower.enable = false;
      };
      screen.enable = true;
      android.enable = true;
    };

    tty = {
      startx.enable = true;
      sx.enable = true;
    };
    display-manager = "sddm";
    defaultSession = "plasma";
    desktops = [ "plasma" ];
    default-gnome-based-de = "gnome";
    window-managers = [ "hyprland" "niri" "i3" "drew-wm" "titus-wm" "bspwm" ];
    rices-shells = config.home-manager.users.${admin}.my.rices-shells;
    x11.enable = true;
    xdg.enable = true;
    dconf.enable = true;

    security = {
      sudo.enable = true;
      polkit.enable = true;
      pam.enable = true;
      tpm.enable = true;
      keyring.enable = true;
    };

    network = {
      enable = true;
      ssh.enable = true;
      vpn.enable = true;
      nm-applet.enable = true;
      tools.enable = true;
    };

    services.enable = true;

    locale = "en_US.UTF-8";
    timeZone = "Asia/Tehran";
    fonts.enable = true;

    search.enable = true;

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
    };

    backup = {
      borg.enable = true;
      rsync.enable = true;
    };

    systemTheme = config.home-manager.users.${admin}.my.theme;

    software = {
      ai = {
        enable = false;
      };
      codecs = {
        enable = true;
      };
      internet = {
        enable = true;
      };
      multimedia = {
        enable = true;
      };
      wallpaper = {
        enable = true;
      };
      disk-utils = {
        enable = true;
      };
      files = {
        enable = true;
      };
      docs = {
        enable = true;
      };
      tools = {
        enable = true;
      };
      audio-control = {
        enable = true;
      };
      daw = {
        enable = false;
      };
      productivity = {
        enable = true;
      };
      fetch = {
        enable = true;
      };
      basic-cli = {
        enable = true;
      };
      terminals = {
        enable = true;
      };
      wine = {
        enable = true;
      };
      hardware-monitor = {
        enable = true;
      };
      peripherals = {
        enable = true;
      };
      social = {
        enable = true;
      };
      theming = {
        enable = true;
      };
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
          hypr = {
            hyprland.enable = true;
          };
          niri.enable = true;
          dwm.enable = true;
          i3.enable = true;
          bspwm.enable = true;
          rices-shells = [ "niri-dms" "niri-noctalia" "hyprland-caelestia" "hyprland-exo" ];


          bar-shell.shells = [ "quickshell" "ignis" "polybar" ];

          apps = {
            alacritty.enable = true;
            amberol.enable = true;
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
            ghostty.enable = true;
            gpg.enable = true;
            htop.enable = true;
            kdeconnect.enable = true;
            keyrings.enable = true;
            kitty.enable = true;
            lf.enable = true;
            neovim.enable = true;
            nautilus.enable = true;
            obs.enable = true;
            onboard.enable = true;
            onlyoffice.enable = true;
            pay-respects.enable = true;
            plank.enable = true;
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
