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
        scx.enable = true;
        thermald.enable = true;
        opt = "power-profiles-daemon";
      };
      ram-tmp = {
        zram.enable = true;
        tmpfs.enable = true;
      };
     #fan = "cooler-control";
      mounts = [ ];
      bluetooth.enable = true;
      sound = "pipewire";
      dbus.enable = true;
      fwupd.enable = true;
      libinput.enable = true;
      touchegg.enable = true;
      keyboard = {
        enable = true;
       #xremap.enable = false;
      };
      storage.enable = true;
      gamepads.enable = true;
      logitech.enable = false;
      printer.enable = false;
      scanner.enable = false;
      power = {
        upower.enable = false;
      };
      cd.enable = false;
      screen.enable = true;
      rgb.enable = false;
      android.enable = true;
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
    defaultSession = "none+bspwm"; # "plasma";
    desktops = [

      # Wayland
      "plasma"
     #"cosmic"

      # Gnome-Based
     #"cinnamon"
     #"mate"
     #"budgie"
     #"gnome" "pantheon"  # WARNING THE DEVIL

      # X11
      "xfce"
     #"lumina"
     #"lxqt"
     #"enlightenment"

      # Misc
     #"retroarch"
     #"cde"               # WARNING BROKEN stable and unstable

    ];
    default-gnome-based-de = "gnome";
    window-managers = [

      # Wayland
      "hyprland"
     #"niri"
     #"sway"
     #"qtile"
     #"dwl"
     #"mango"
     #"labwc"
     #"river"
     #"wayfire"

      # Mir
     #"miracle-wm" "miriway"

      # X11
     #"icewm" "fluxbox"
      "openbox"
     #"windowlab" "windowmaker"
     #"i3"
     #"spectrwm" "herbstluftwm" "dk"
      "titus-wm" #"drew-wm" #"dwm" #"chadwm"  #"bread-wm" #"pd-wm"
      "bspwm"
     #"awesome"
     #"xmonad"
     #"exwm" "wmderland" "ragnarwm" "notion" "pekwm" "mlvwm"
     #"fvwm2" "fvwm3" "leftwm" "berry" "sawfish"
     #"twm" "jwm" "ratpoison" "e16"
     #"hypr"
     #"oxwm"

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
      keyring.enable = true;
    };

    network = {
      enable = true;
      ssh.enable = true;
      vpn.enable = true;
      shares.enable = true;
      avahi.enable = true;
      nm-applet.enable = true;
      nfs.enable = false;
      torrent.enable = false;
      tools.enable = true;
    };

    services.enable = true;

    locale = "en_US.UTF-8";
    geoclue.enable = false;
    timeZone = "Asia/Tehran";
    fonts.enable = true;

    tasks.enable = false;
    search.enable = false;

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
      podman.enable = false;
      docker.enable = false;
      waydroid.enable = false;
    };

    backup = {
      borg.enable = true;
      rsync.enable = true;
    };

    systemTheme = config.home-manager.users.${admin}.my.theme;

    software = {
      ai = {
        enable = false;
        exclude = with pkgs; [ gpt4all gpt4all-cuda chatd aichat yai ];
        include = with pkgs; [ ];
      };
      codecs = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      internet = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      multimedia = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      wallpaper = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      disk-utils = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      files = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      docs = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      tools = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      audio-control = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      daw = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      productivity = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      fetch = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      basic-cli = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      terminals = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      wine = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      hardware-monitor = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      peripherals = {
        enable = false;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      social = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
      theming = {
        enable = true;
        exclude = with pkgs; [ ];
        include = with pkgs; [ ];
      };
    };

    gaming = {
      steam.enable = true;
      native-games.enable = true;
      launchers.enable = true;
      tools.enable = true;
      emulators.enable = true;
      cli-games.enable = true;
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

          audio.enable = true;
          keyboard = {
            xremap.enable = true;
          };

          kde = {
            plasma.enable = true;
            appletrc = null;
            kate.enable = true;
            konsole.enable = true;
            elisa.enable = false;
            ghostwriter.enable = true;
            okular.enable = true;
            wallpaper-engine.enable = false;
          };
         #cosmic.enable = true;
          gnome.enable = true;
         #cinnamon.enable = true;
         #mate.enable = true;
          xfce.enable = true;
          hypr = {
            hyprland.enable = true;
          };
         #niri.enable = true;
         #sway.enable = true;
         #river.enable = true;
         #wayfire.enable = true;
          labwc.enable = false;
          dwm.enable = true;
          i3.enable = false;
          openbox.enable = true;
         #xmonad.enable = true;
          awesome.enable = false;
         #qtile.enable = true;
          bspwm.enable = true;
         #spectrwm.enable = true;
         #herbstluftwm.enable = true;
         #fluxbox.enable = true;
          mango.enable = false;
          rices-shells = [

           #"niri-dms" "niri-noctalia"
            /*"hyprland-uwsm"*/ "hyprland-noctalia" /*"hyprland-caelestia"*/ /*"hyprland-dms"*/ /*"hyprland-ax"*/ /*"hyprland-ashell"*/ /*"hyprland-exo"*/

          ];

          distrobox.enable = false;

          bar-shell.shells = [
            # wayland
            /*"ags"*/ "quickshell" /*"waybar"*/ /*"ashell"*/ /*"ignis"*/
            # x11
            "polybar"
            "tint2"
           #"trayer"
          ];
          apps = {
            alacritty.enable = true;
            amberol.enable = true;
            bat.enable = true;
            bazaar.enable = false;
            bluetuith.enable = true;
            borg.enable = true;
            btop.enable = true;
            cava.enable = true;
            copyq.enable = true;
            crystal-dock.enable = true;
            direnv.enable = true;
            dockbarx.enable = true;
            dunst.enable = true;
            fastfetch.enable = true;
            fd.enable = true;
            flameshot.enable = true;
            foliate.enable = false;
            freetube.enable = true;
            fzf.enable = true;
            git.enable = true;
            ghostty.enable = true;
            gpg.enable = true;
            htop.enable = true;
            joplin.enable = false;
            kdeconnect.enable = true;
            keyrings.enable = true;
            kitty.enable = true;
            lf.enable = true;
            ludusavi.enable = false;
            lutris.enable = true;
            mangohud.enable = true;
            mpv.enable = true;
            neovim.enable = true;
            nautilus.enable = false;
            obs.enable = true;
            obsidian.enable = false;
            onboard.enable = true;
            onlyoffice.enable = true;
            pay-respects.enable = true;
            plank.enable = false;
            qutebrowser.enable = true;
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
            wezterm.enable = true;
            wlogout.enable = true;

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
            file-alt = "dolphin";
            browser = "brave-browser";
            browser-alt-name = "brave";
            browser-package = pkgs.brave;
            image-viewer = "org.kde.gwenview";
            image-alt = "gwenview";
            video-player = "mpv"; #"org.gnome.Showtime";
            audio-player = "io.bassi.Amberol";
            audio-alt = "amberol";
            pdf-viewer = "org.kde.okular";
            pdf-alt = "okular";
            archive-manager = "org.kde.ark";
            archive-alt = "ark";
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
