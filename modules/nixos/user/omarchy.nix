{ config, pkgs, lib, inputs, ... }:

{ config = lib.mkIf (builtins.elem "omarchy" config.my.user.users) {

  users = {

    users = {

      omarchy = {
       #password  initialPassword  hashedPassword  initialHashedPassword hashedPasswordFile
       #initialPassword = ;
        isNormalUser = true;
        description = "omarchy";
        extraGroups = [ "networkmanager" "wheel" ];

        packages = with pkgs; [

         #_1password-cli
         #_1password-gui-beta
         #alacritty
         #avahi
         #bat
         #blueberry
         #brightnessctl
         #btop
         #cargo
         #dust
         #evince
         #eza
         #fastfetch
         #fd
         #ffmpegthumbnailer
         #fontconfig
         #fzf
         #github-copilot-cli
         #gnome-calculator
         #gnome-keyring
         #gnome-themes-extra
         #gum
         #hypridle
         #hyprland-qtutils
         #hyprlock
         #hyprpicker
         #hyprshot
         #hyprsunset
         #imagemagick
         #impala
         #imv
         #inetutils
         #iwd
         #jq
         #kdePackages.kdenlive
         #libsForQt5.qtstyleplugin-kvantum
         #kdePackages.qtstyleplugin-kvantum
         #lazygit
         #less
         #libyaml
         #libqalculate
         #libreoffice-still
         #localsend
         #luajitPackages.luarocks
         #mako
         #man
         #mariadb
         #mise
         #mpv
         #nautilus
         #noto-fonts
         #noto-fonts-cjk-sans
         #noto-fonts-cjk-serif
         #noto-fonts-emoji-blob-bin
         #nssmdns
         #neovim
         #vimPlugins.LazyVim
         #obs-studio
         #obsidian
         #brave
         #pamixer
         #pinta
         #playerctl
         #plocate
         #polkit_gnome
         #postgresql
         #power-profiles-daemon
         #gobject-introspection
         #python313Packages.pygobject3
         #poetry
         #terminaltexteffects
         #python313Packages.terminaltexteffects
         #libsForQt5.qt5.qtwayland
         #kdePackages.qtwayland
         #ripgrep
         #satty
         #signal-desktop
         #slurp
         #spotify
         #starship
         #sushi
         #swaybg
         #swayosd
         #system-config-printer
         #tldr
         #tree-sitter
         #nerd-fonts.caskaydia-mono
         #cascadia-code
         #ia-writer-mono
         #ia-writer-quattro
         #ia-writer-duospace
         #nerd-fonts.jetbrains-mono
         #typora
         #tzupdate
         #unzip
         #uwsm
         #walker
         #waybar
         #wf-recorder
         #whois
         #wireless-regdb
         #wiremix
         #wireplumber
         #wl-clip-persist
         #wl-clipboard
         #wl-screenrec
         #font-awesome
         #woff2
         #line-awesome
         #xdg-desktop-portal-gtk
         #xdg-desktop-portal-hyprland
         #xmlstarlet
         #xournalpp
         #yaru-theme
         #zoxide
         #
         #egl-wayland
         #gtk4-layer-shell
         #htop
         #intltool
         #sassc
         #webp-pixbuf-loader
         #wget
         #git

        ];

      };

    };

  };

   #home-manager.users.omarchy = {
   #
   #  imports = [ ./omarchy-hm.nix ];
   #
   #  services.xremap = {
   #    enable = false;
   #  };
   #
   #  home = {
   #    username = "omarchy";
   #    homeDirectory = "/home/omarchy";
   #
   #   #sessionVariables = {
   #   #
   #   #  OMARCHY_PATH = "/home/omarchy/.local/share/omarchy";
   #   #  OMARCHY_INSTALL = "$OMARCHY_PATH/install";
   #   #  OMARCHY_INSTALL_LOG_FILE = "/var/log/omarchy-install.log";
   #   #  PATH = "$OMARCHY_PATH/bin:$PATH";
   #   #
   #   #};
   #
   #  };
   #
   #};

};}
