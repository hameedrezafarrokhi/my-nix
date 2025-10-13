{ config, pkgs, lib, inputs, ... }:

{

  home = {

        activation = {

          omarchy-install = lib.hm.dag.entryAfter ["writeBoundary"] ''

            rm -rf ~/.local/share/omarchy/

            mkdir -p ~/.local/share/omarchy/

            cp -r ${inputs.omarchy}/* ~/.local/share/omarchy/

            export OMARCHY_PATH="~/.local/share/omarchy"
            export OMARCHY_INSTALL="$OMARCHY_PATH/install"
            export OMARCHY_INSTALL_LOG_FILE="/var/log/omarchy-install.log"
            export PATH="$OMARCHY_PATH/bin:$PATH"

            mkdir -p ~/.local/share/fonts
            cp ~/.local/share/omarchy/config/omarchy.ttf ~/.local/share/fonts/
            fc-cache

            ICON_DIR="~/.local/share/applications/icons"
            mkdir -p "$ICON_DIR"
            cp ~/.local/share/omarchy/applications/icons/*.png "$ICON_DIR/"

            if [[ ! -d "~/.config/nvim" ]]; then
              omarchy-lazyvim-setup
            fi

            omarchy-tui-install "Disk Usage" "bash -c 'dust -r; read -n 1 -s'" float "$ICON_DIR/Disk Usage.png"
            omarchy-tui-install "Docker" "lazydocker" tile "$ICON_DIR/Docker.png"

            omarchy-webapp-install "HEY" https://app.hey.com HEY.png
            omarchy-webapp-install "Basecamp" https://launchpad.37signals.com Basecamp.png
            omarchy-webapp-install "WhatsApp" https://web.whatsapp.com/ WhatsApp.png
            omarchy-webapp-install "Google Photos" https://photos.google.com/ "Google Photos.png"
            omarchy-webapp-install "Google Contacts" https://contacts.google.com/ "Google Contacts.png"
            omarchy-webapp-install "Google Messages" https://messages.google.com/web/conversations "Google Messages.png"
            omarchy-webapp-install "ChatGPT" https://chatgpt.com/ ChatGPT.png
            omarchy-webapp-install "YouTube" https://youtube.com/ YouTube.png
            omarchy-webapp-install "GitHub" https://github.com/ GitHub.png
            omarchy-webapp-install "X" https://x.com/ X.png
            omarchy-webapp-install "Figma" https://figma.com/ Figma.png
            omarchy-webapp-install "Discord" https://discord.com/channels/@me Discord.png
            omarchy-webapp-install "Zoom" https://app.zoom.us/wc/home Zoom.png "omarchy-webapp-handler-zoom %u" "x-scheme-handler/zoommtg;x-scheme-handler/zoomus"

            mkdir -p ~/.config/omarchy/branding
            cp ~/.local/share/omarchy/icon.txt ~/.config/omarchy/branding/about.txt
            cp ~/.local/share/omarchy/logo.txt ~/.config/omarchy/branding/screensaver.txt

            mkdir -p ~/.config
            cp -r ~/.local/share/omarchy/config/* ~/.config/

            # Use default bashrc from Omarchy
            cp ~/.local/share/omarchy/default/bashrc ~/.bashrc

            # Copy over the keyboard layout that's been set in Arch during install to Hyprland
            conf="/etc/vconsole.conf"
            hyprconf="~/.config/hypr/input.conf"

            if grep -q '^XKBLAYOUT=' "$conf"; then
              layout=$(grep '^XKBLAYOUT=' "$conf" | cut -d= -f2 | tr -d '"')
              sed -i "/^[[:space:]]*kb_options *=/i\  kb_layout = $layout" "$hyprconf"
            fi

            if grep -q '^XKBVARIANT=' "$conf"; then
              variant=$(grep '^XKBVARIANT=' "$conf" | cut -d= -f2 | tr -d '"')
              sed -i "/^[[:space:]]*kb_options *=/i\  kb_variant = $variant" "$hyprconf"
            fi

            omarchy-lazyvim-setup

            updatedb

            omarchy-refresh-applications
            update-desktop-database ~/.local/share/applications

            # Open all images with imv
            xdg-mime default imv.desktop image/png
            xdg-mime default imv.desktop image/jpeg
            xdg-mime default imv.desktop image/gif
            xdg-mime default imv.desktop image/webp
            xdg-mime default imv.desktop image/bmp
            xdg-mime default imv.desktop image/tiff

            # Open PDFs with the Document Viewer
            xdg-mime default org.gnome.Evince.desktop application/pdf

            # Use Chromium as the default browser
            xdg-settings set default-web-browser chromium.desktop
            xdg-mime default chromium.desktop x-scheme-handler/http
            xdg-mime default chromium.desktop x-scheme-handler/https

            # Open video files with mpv
            xdg-mime default mpv.desktop video/mp4
            xdg-mime default mpv.desktop video/x-msvideo
            xdg-mime default mpv.desktop video/x-matroska
            xdg-mime default mpv.desktop video/x-flv
            xdg-mime default mpv.desktop video/x-ms-wmv
            xdg-mime default mpv.desktop video/mpeg
            xdg-mime default mpv.desktop video/ogg
            xdg-mime default mpv.desktop video/webm
            xdg-mime default mpv.desktop video/quicktime
            xdg-mime default mpv.desktop video/3gpp
            xdg-mime default mpv.desktop video/3gpp2
            xdg-mime default mpv.desktop video/x-ms-asf
            xdg-mime default mpv.desktop video/x-ogm+ogg
            xdg-mime default mpv.desktop video/x-theora+ogg
            xdg-mime default mpv.desktop application/ogg

            # Add ./bin to path for all items in ~/Work
            mkdir -p "~/Work"

            cat >"~/Work/.mise.toml" <<'EOF'
            [env]
            _.path = "{{ cwd }}/bin"
            EOF

            mise trust ~/Work/.mise.toml

            # Set links for Nautilius action icons
           #sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-previous-symbolic.svg
           #sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-next-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-next-symbolic.svg

            # Setup theme links
            mkdir -p ~/.config/omarchy/themes
            for f in ~/.local/share/omarchy/themes/*; do ln -nfs "$f" ~/.config/omarchy/themes/; done

            # Set initial theme
            mkdir -p ~/.config/omarchy/current
            ln -snf ~/.config/omarchy/themes/tokyo-night ~/.config/omarchy/current/theme
            ln -snf ~/.config/omarchy/current/theme/backgrounds/1-scenery-pink-lakeside-sunset-lake-landscape-scenic-panorama-7680x3215-144.png ~/.config/omarchy/current/background

            # Set specific app links for current theme
            ln -snf ~/.config/omarchy/current/theme/neovim.lua ~/.config/nvim/lua/plugins/theme.lua

            mkdir -p ~/.config/btop/themes
            ln -snf ~/.config/omarchy/current/theme/btop.theme ~/.config/btop/themes/current.theme

            mkdir -p ~/.config/mako
            ln -snf ~/.config/omarchy/current/theme/mako.ini ~/.config/mako/config

            mkdir -p ~/.config/eza
            ln -snf ~/.config/omarchy/current/theme/eza.yml ~/.config/eza/theme.yml

            # Add managed policy directories for Chromium and Brave for theme changes
           #sudo mkdir -p /etc/chromium/policies/managed
           #sudo chmod a+rw /etc/chromium/policies/managed

           #sudo mkdir -p /etc/brave/policies/managed
           #sudo chmod a+rw /etc/brave/policies/managed

            # Set default XCompose that is triggered with CapsLock
            tee ~/.XCompose >/dev/null <<EOF
            include "~/.local/share/omarchy/default/xcompose"

            # Identification
            <Multi_key> <space> <n> : "$OMARCHY_USER_NAME"
            <Multi_key> <space> <e> : "$OMARCHY_USER_EMAIL"
            EOF

            gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
            gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
            gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"

          '';

        };

  };

}
