{ config, pkgs, lib, admin, nix-path, ... }:

let

  girm-full = pkgs.writeShellScriptBin "grim-full" ''
    grim ~/Pictures/Screenshot-$(date +%F_%H-%M-%S).png && notify-send "Screenshot saved" "Saved to ~/Pictures"
  '';

  grim-slurp = pkgs.writeShellScriptBin "grim-slurp" ''
    grim -g "$(slurp)" ~/Pictures/Screenshot-$(date +%F_%H-%M-%S).png && notify-send "Screenshot saved" "Saved to ~/Pictures"
  '';

  xlock = pkgs.writeShellScriptBin "xlock" ''
    ${config.services.screen-locker.lockCmd}
  '';

  xss-kill = pkgs.writeShellScriptBin "xss-kill" ''
    pkill .xscreensaver-w
    pkill xscreensaver-sy
    pkill .xscreensaver-s
    notify-send "XScreenSaver Disabled"
  '';

    # Usefull Commands to debug sleep/lock
  # xset q | grep -E "timeout|standby|suspend|off"
  # loginctl show-session $XDG_SESSION_ID | grep IdleAction
  # ps aux | grep -E "locker|lock|screensaver|powerdevil|gnome-screensaver|xscreensaver"

   # is this useful ?
  # systemd-inhibit --what=idle --why="Disable idle" sleep infinity &

  lock-kill = pkgs.writeShellScriptBin "lock-kill" ''
    systemctl --user stop xautolock-session.service
    systemctl --user stop xss-lock.service
    systemctl --user stop swayidle-mango.service
    systemctl --user stop swayidle-niri.service
    systemctl --user stop swayidle-sway.service
    systemctl --user stop swayidle.service
    systemctl --user stop hypridle.service
    xset s off
    xset s noblank
    xset s 0 0
    xset -dpms
    notify-send "Idle Inhibited "
  '';

  lock-restart = pkgs.writeShellScriptBin "lock-restart" ''
    systemctl --user restart xautolock-session.service
    systemctl --user restart xss-lock.service
    systemctl --user restart swayidle-mango.service
    systemctl --user restart swayidle-niri.service
    systemctl --user restart swayidle-sway.service
    systemctl --user restart swayidle.service
    systemctl --user restart hypridle.service
    xset s on
    xset s blank
    xset s 6000 6000
    xset +dpms
    notify-send "Lock Activated "
  '';

  xremap-x-lock-sleep = pkgs.writeShellScriptBin "xremap-x-lock-sleep" ''
    ${config.services.screen-locker.lockCmd} &
  '';

  x-logout = pkgs.writeShellScriptBin "x-logout" ''
    bspc quit
    pkill dwm
    pkill dwm
    openbox --exit
    i3-msg exit
  '';

  xremap-picom-toggle = pkgs.writeShellScriptBin "xremap-picom-toggle" ''
    if systemctl --user is-active --quiet picom.service; then
        systemctl --user stop picom.service
        notify-send "Picom Stopped"
    else
        systemctl --user restart picom.service
        notify-send "Picom Activated"
    fi
  '';

  volume= "$(pamixer --get-volume)";
  xremap-volume = pkgs.writeShellScriptBin "xremap-volume" ''
      #!/bin/bash

      function send_notification() {
      	volume=$(pamixer --get-volume)
      	dunstify -a "changevolume" -u low -r "9993" -h int:value:"$volume" -i "volume-$1" "Volume: ${volume}%" -t 2000
      }

      case $1 in
      up)
      	# Set the volume on (if it was muted)
      	pamixer -u
      	pamixer -i 2 --allow-boost
      	send_notification $1
      	;;
      down)
      	pamixer -u
      	pamixer -d 2 --allow-boost
      	send_notification $1
      	;;
      mute)
      	pamixer -t
      	if $(pamixer --get-mute); then
      		dunstify -i volume-mute -a "changevolume" -t 2000 -r 9993 -u low "Muted"
      	else
      		send_notification up
      	fi
      	;;
      esac

  '';

  xremap-pp = pkgs.writeShellScriptBin "xremap-pp" ''
    CURRENT_PROFILE=$(powerprofilesctl get)

    if [ "$1" = "--status" ]; then
        if [ "$CURRENT_PROFILE" = "performance" ]; then
            echo ""  # Performance icon
        elif [ "$CURRENT_PROFILE" = "power-saver" ]; then
            echo ""  # Power Saver icon
        else
            echo ""  # Balanced icon
        fi
        exit 0
    fi

    # Toggle between the profiles on click
    if [ "$CURRENT_PROFILE" = "performance" ]; then
        # Switch to Power Saver mode
        powerprofilesctl set power-saver
        echo "Switched to Power Saver mode."
        notify-send "Power-Saver Mode"
    elif [ "$CURRENT_PROFILE" = "power-saver" ]; then
        # Switch to Balanced mode
        powerprofilesctl set balanced
        echo "Switched to Balanced mode."
        notify-send "Balanced Mode"
    else
        # Switch to Performance mode
        powerprofilesctl set performance
        echo "Switched to Performance mode."
        notify-send "Performance Mode"
    fi
  '';

  xremap-time = pkgs.writeShellScriptBin "xremap-time" ''
    notify-send "⏲️ "$(date "+%I:%M:%S-%p" )" "$(date "+%p" ) "📅 "$(date "+%a")" "$(date "+%d-%b-%y")
  '';

  xremap-motd = pkgs.writeShellScriptBin "xremap-motd" ''
    notify-send "$(bullshit)"
  '';

  xremap-help = pkgs.writeShellScriptBin "xremap-help" ''
    ${builtins.readFile ./xremap-help.sh}
  '';

  xremap-weather = pkgs.writeShellScriptBin "xremap-weather" ''
    notify-send "$(curl -s "wttr.in/Tehran?format=%c+%C+%t+%f+%h+%w+%m+%l+%S+%s")"
  '';

 #vlc-env = pkgs.writeShellScriptBin "vlc-env" ''
 #  QT_QPA_PLATFORMTHEME=qt6ct vlc
 #'';

in

{ config = lib.mkIf (config.my.keyboard.xremap.enable) {

  services.screen-locker.lockCmd = lib.mkDefault "${pkgs.betterlockscreen}/bin/betterlockscreen --lock";

  home.packages = [
    pkgs.xremap
    pkgs.yq
    girm-full
    grim-slurp
    xlock
    xss-kill
    lock-kill
    lock-restart
    xremap-x-lock-sleep
    x-logout
    xremap-picom-toggle
    xremap-volume
    xremap-pp
    xremap-time
    xremap-help
    xremap-motd
    xremap-weather
   #vlc-env
  ];

 #xdg.desktopEntries = {
 #  "vlc-env" = { name="vlc-env"; exec="vlc-env"; };
 #};

  services.xremap = {
    enable = true;
    package = pkgs.xremap;
   #userName = admin;
   #userId = 1000;
    watch = true;
    mouse = true;
   #deviceNames = [ ];
   #extraArgs = [ ];
   #debug = true;

   #withSway = true;
   #withWlroots = true;
   #withX11 = true;
   #withKDE = true;
   #withHypr = true;
   #withGnome = true;

   # TO Find Key Names ", xev | grep keysym"

   # "bash", "${config.home.homeDirectory}/.local/state/home-manager/gcroots/current-home/home-path/share/applications/org.kde.dolphin.desktop"
   # "${lib.getExe pkgs.kitty}"
   # "${lib.getExe pkgs.brave}"
   # "flameshot", "full", "-p", "${config.home.homeDirectory}/Pictures/Screenshots"



       #- name: easy-life
       #  remap:
       #    CAPSLOCK: SUPER-Z
       #
       #- name: New-CapsLock
       #  remap:
       #    Super-CapsLock: CapsLock

       # launch: [ "bash", "${config.home.homeDirectory}/.local/state/home-manager/gcroots/current-home/home-path/share/applications/org.kde.dolphin.desktop" ]

    yamlConfig = ''

      modmap:

        - name: caps
          remap:
            CAPSLOCK:
              held: [LEFTMETA, Z]
              alone: CAPSLOCK
              alone_timeout_millis: 5000

        - name: r-ctrl
          remap:
            RIGHTCTRL:
              alone: [LEFTMETA, Z]
              held: RIGHTCTRL
              alone_timeout_millis: 1000

        - name: r-alt
          remap:
            RIGHTALT:
              held: RIGHTALT
              alone: [LEFTALT, X]
              alone_timeout_millis: 1000

      keymap:

        - name: Launch-default-Apps
          remap:
            Super-z:
              remap:
                    Enter:
                      launch: [ "kitty" ]
                    b:
                      launch: [ "brave" ]
                    e:
                      launch: [ "bash", "${config.home.homeDirectory}/.local/state/home-manager/gcroots/current-home/home-path/share/applications/org.kde.dolphin.desktop" ]
                    t:
                      launch: [ "kate" ]
                    Space:
                      launch: [ "rofi", "-show", "drun", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                    o:
                      launch: [ "onlyoffice-desktopeditors" ]
                    m:
                      launch: [ "vlc" ]
                    a:
                      launch: [ "amberol" ]
                    v:
                      launch: [ "protonvpn-app" ]
                    l:
                      launch: [ "Telegram" ]
                    k:
                      launch: [ "kdeconnect-app" ]
                    g:
                      remap:
                            s:
                              launch: [ "steam" ]
                            h:
                              launch: [ "heroic" ]
                            l:
                              launch: [ "lutris" ]
                    p:
                      launch: [ "flameshot", "full", "-p", "${config.home.homeDirectory}/Pictures/Screenshots" ]
                    KEY_SEMICOLON:
                      launch: [ "grim-full" ]
                    h:
                      launch: [ "xremap-help" ]





        - name: Launch-Alternative-Apps
          remap:
            Alt-x:
              remap:
                    Enter:
                      remap:
                            p:
                              launch: [ "konsole" ]
                            k:
                              launch: [ "kitty" ]
                            g:
                              launch: [ "ghostty" ]
                            w:
                              launch: [ "wezterm" ]
                            a:
                              launch: [ "alacritty" ]
                            f:
                              launch: [ "foot" ]
                            y:
                              launch: [ "yakuake" ]
                            s:
                              launch: [ "st" ]
                            q:
                              launch: [ "xterm" ]
                            x:
                              launch: [ "xfce4-terminal" ]
                            h:
                              launch: [ "hyper" ]
                            u:
                              launch: [ "guake" ]
                            c:
                              launch: [ "cosmic-term" ]
                            m:
                              launch: [ "mate-terminal" ]
                            u:
                              launch: [ "urxvt" ]
                            t:
                              launch: [ "tilda" ]
                    b:
                      remap:
                            b:
                              launch: [ "brave" ]
                            f:
                              launch: [ "firefox" ]
                    e:
                      remap:
                            d:
                              launch: [ "dolphin" ]
                            g:
                              launch: [ "nautilus" ]
                            n:
                              launch: [ "nemo" ]
                            t:
                              launch: [ "thunar" ]
                    t:
                      remap:
                            k:
                              launch: [ "kate" ]
                            n:
                              launch: [ "kitty", "nvim" ]
                            v:
                              launch: [ "kitty", "vim" ]
                    o:
                      remap:
                            o:
                              launch: [ "onlyoffice-desktopeditors" ]
                            l:
                              launch: [ "libreoffice" ]
                    m:
                      remap:
                            v:
                              launch: [ "vlc" ]
                            s:
                              launch: [ "showtime" ]
                            m:
                              launch: [ "mpv" ]
                            c:
                              launch: [ "celluloid" ]
                    a:
                      remap:
                            a:
                              launch: [ "amberol" ]
                            s:
                              launch: [ "spotify" ]
                    v:
                      remap:
                            p:
                              launch: [ "protonvpn-app" ]
                    Space:
                      remap:
                            Enter:
                              launch: [ "rofi", "-show", "run", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            e:
                              launch: [ "rofi", "-show", "filebrowser", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            w:
                              launch: [ "rofi", "-show", "window", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            m:
                              launch: [ "rofi", "-show", "emoji", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            c:
                              launch: [ "rofi", "-show", "calc", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            s:
                              launch: [ "rofi", "-show", "ssh", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            r:
                              launch: [ "rofi", "-show", "combi", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            h:
                              launch: [ "rofi", "-show", "keys", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            t:
                              launch: [ "rofi", "-show", "top", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            b:
                              launch: [ "rofi", "-show", "blezz", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            n:
                              launch: [ "rofi", "-show", "nerdy", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            g:
                              launch: [ "rofi", "-show", "games", "-modi", "drun", "-line-padding", "4", "-hide-scrollbar", "-show-icons" ]
                            Space:
                              launch: [ "jgmenu_run" ]

                    p:
                      remap:
                            p:
                              launch: [ "flameshot", "gui" ]
                            w:
                             launch: [ "flameshot", "screen", "-p", "${config.home.homeDirectory}/Pictures/Screenshots" ]
                            c:
                              launch: [ "flameshot", "config" ]
                    KEY_SEMICOLON:
                      remap:
                            KEY_SEMICOLON:
                              launch: [ "grim-slurp" ]







        - name: Dangerous-Actions
          remap:
            Super-Shift-Ctrl-z:
              remap:
                    r:
                      launch: [ "reboot" ]
                    p:
                      launch: [ "shutdown", "now" ]
                    w:
                      launch: [ "wayland-logout" ]
                    q:
                      launch: [ "x-logout" ]
                    l:
                      launch: [ "loginctl", "lock-session" ]
                    s:
                      launch: [ "systemctl", "suspend" ]
                    h:
                      launch: [ "systemctl", "hibernate" ]
                    m:
                      launch: [ "systemctl", "suspend-then-hibernate" ]
                    x:
                      launch: [ "xscreensaver", "-no-splash" ]
                    k:
                      launch: [ "lock-kill" ]
                    KEY_SEMICOLON:
                      launch: [ "swaylock", "-fF" ]
                    j:
                      launch: [ "lock-restart" ]
                    c:
                      launch: [ "xremap-pp" ]

            Super-Shift-Ctrl-l:
                      launch: [ "xlock" ]
            Super-Shift-Ctrl-KEY_SEMICOLON:
                      launch: [ "xremap-x-lock-sleep" ]
            Super-Shift-Ctrl-x:
                      launch: [ "xss-kill" ]
            Super-Shift-Ctrl-p:
              launch: [ "xremap-picom-toggle" ]





        - name: Commands
          remap:
            Super-z:
              remap:
                Esc:
                  remap:
                    v:
                      remap:
                        w:
                          remap:
                                c:
                                  launch: [ "bash", "warp-cli", "connect" ]
                                d:
                                  launch: [ "bash", "warp-cli", "disconnect" ]





        - name: Actions
          remap:
            Super-Shift-v:
              launch: [ "copyq", "menu" ]
            Super-Ctrl-t:
              launch: [ "xremap-time" ]
            Super-Ctrl-q:
              launch: [ "xremap-motd" ]
            Super-Ctrl-w:
              launch: [ "xremap-weather" ]




        - name: Media-Control
          remap:
            Super-Ctrl-p:
              launch: [ "xremap-volume", "up" ]
            Super-Ctrl-o:
              launch: [ "xremap-volume", "down" ]
            Super-Ctrl-i:
              launch: [ "xremap-volume", "mute" ]
            Super-Ctrl-l:
              launch: [ "playerctl", "play-pause" ]
            Super-Ctrl-k:
              launch: [ "playerctl", "stop" ]
            Super-Ctrl-j:
              launch: [ "playerctl", "loop" ]
            Super-Ctrl-KEY_SEMICOLON:
              launch: [ "playerctl", "previous" ]
            Super-Ctrl-KEY_APOSTROPHE:
              launch: [ "playerctl", "next" ]
            Super-Ctrl-f:
              launch: [ "playerctl", "position", "1+" ]
            Super-Ctrl-g:
              launch: [ "playerctl", "position", "5+" ]
            Super-Ctrl-h:
              launch: [ "playerctl", "position", "30+" ]
            Super-Ctrl-d:
              launch: [ "playerctl", "position", "1-" ]
            Super-Ctrl-s:
              launch: [ "playerctl", "position", "5-" ]
            Super-Ctrl-a:
              launch: [ "playerctl", "position", "30-" ]
            KEY_PLAYPAUSE:
              launch: [ "playerctl", "play-pause" ]
            KEY_STOP:
              launch: [ "playerctl", "stop" ]
            KEY_PREVIOUS:
              launch: [ "playerctl", "previous" ]
            KEY_NEXT:
              launch: [ "playerctl", "next" ]
            KEY_MUTE:
              launch: [ "xremap-volume", "mute" ]






        - name: WebApps
          remap:
            Super-z:
              remap:
                w:
                  remap:
                    s:
                      remap:
                            g:
                              launch: [ "google"         ]
                            d:
                              launch: [ "ddgo"           ]
                            b:
                              launch: [ "brave-search"   ]
                            m:
                              launch: [ "bing-search"    ]
                            y:
                              launch: [ "yahoo"          ]
                            w:
                              launch: [ "wikipedia"      ]
                            i:
                              launch: [ "google-images"  ]
                            f:
                              launch: [ "imdb"           ]
                    i:
                      remap:
                            g:
                              launch: [ "GPT"            ]
                            x:
                              launch: [ "grok"           ]
                            d:
                              launch: [ "deepseek"       ]
                            c:
                              launch: [ "claude-code"    ]
                    n:
                      remap:
                            p:
                              launch: [ "nix-packages"   ]
                            o:
                              launch: [ "nix-options"    ]
                            s:
                              launch: [ "nix-status"     ]
                            h:
                              launch: [ "nix-hydra"      ]
                            w:
                              launch: [ "nix-wiki"       ]
                            g:
                              launch: [ "nix-github"     ]

                            a:
                              launch: [ "arch-wiki"      ]
                            r:
                              launch: [ "repology"       ]
                    e:
                      remap:
                            g:
                              launch: [ "Gmail"          ]
                            y:
                              launch: [ "yahoo-mail"     ]
                            p:
                              launch: [ "Proton-mail"    ]
                    v:
                      remap:
                            y:
                              launch: [ "YouTube"        ]
                            t:
                              launch: [ "TwitchTV"       ]
                            i:
                              launch: [ "iran-tv"        ]
                    a:
                      remap:
                            s:
                              launch: [ "Spotify-Web"    ]
                            p:
                              launch: [ "Pandora-Web"    ]
                            s:
                              launch: [ "SoundCloud-Web" ]
                            y:
                              launch: [ "ytMusic-Web"    ]
                            r:
                              launch: [ "iHeart-Web"     ]
                    x:
                      remap:
                            w:
                              launch: [ "Whatsapp-Web"   ]
                            i:
                              launch: [ "Instagram-Web"  ]
                            f:
                              launch: [ "Facebook-Web"   ]
                            x:
                              launch: [ "X-Web"          ]
                            z:
                              launch: [ "Zoom-Web"       ]
                            d:
                              launch: [ "Discord-Web"    ]
                            r:
                              launch: [ "Reddit-Web"     ]
                    g:
                      remap:
                            i:
                              launch: [ "Online-Games"   ]
                            p:
                              launch: [ "Play-PS2"       ]
                            e:
                              launch: [ "Epic-Gmaes"     ]
                            g:
                              launch: [ "Google-Games"   ]
                            r:
                              launch: [ "Roblox"         ]
                            y:
                              launch: [ "Yahoo-Games"    ]
                    m:
                      remap:
                            u:
                              launch: [ "up-to-date"     ]
                            m:
                              launch: [ "medscape"       ]
                    c:
                      remap:
                            g:
                              launch: [ "google-photos"  ]
                            d:
                              launch: [ "Dropbox"        ]
                            b:
                              launch: [ "BorgBase"       ]
                    p:
                      remap:
                            p:
                              launch: [ "PhotoShop"      ]
                            o:
                              launch: [ "office365"      ]
                            b:
                              launch: [ "BoxySVG"        ]
                    w:
                      remap:
                            m:
                              launch: [ "google-maps"    ]
                            e:
                              launch: [ "google-earth"   ]
                            w:
                              launch: [ "weather-online" ]
                            t:
                              launch: [ "time-ir"        ]
                    b:
                      remap:
                            i:
                              launch: [ "irancell"       ]
                            h:
                              launch: [ "hamrah"         ]


    '';

    #launch: [ "${lib.getExe pkgs.${config.my.default.terminal}}" ] # Example


   #config = {
   # #modemap = [ ]; # for single key remaping
   #  keymap = [
   #    {  name = "terminal";
   #      remap = {
   #        "alt-d" = {
   #          remap = {};
   #        };
   #      };
   #    }
   #
   #  ];
   #};

  };

  xdg.configFile = {
    xremap = {
      target = "xremap/xremap.yaml";
      text = config.services.xremap.yamlConfig;
    };
  };

 #home.activation = {
 #
 #  xremap-time-chmod = lib.hm.dag.entryAfter ["writeBoundary"] ''
 #    [ -f ${nix-path}/modules/hm/keyboard/time.sh ] && chmod +x ${nix-path}/modules/hm/keyboard/time.sh
 #  '';
 #};

  #systemd.user.services.xremap = {
  #  Unit = {
  #    Description = "xremap service";
  #    PartOf = [ "graphical-session.target" ];
  #    After = [ "graphical-session.target" ];
  #  };
  #  Service = {
  #      Type = "simple";
  #      ExecStart = lib.getExe pkgs.xremap + (" --watch --mouse");
  #      Restart = "always";
  #    };
  #  Install.WantedBy = [ "graphical-session.target" ];
  #};

};}
