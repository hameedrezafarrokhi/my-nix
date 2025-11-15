{ config, pkgs, lib, admin, ... }:

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

 #vlc-env = pkgs.writeShellScriptBin "vlc-env" ''
 #  QT_QPA_PLATFORMTHEME=qt6ct vlc
 #'';

in

{ config = lib.mkIf (config.my.keyboard.xremap.enable) {

  services.screen-locker.lockCmd = lib.mkDefault "${pkgs.betterlockscreen}/bin/betterlockscreen --lock";

  home.packages = [
    pkgs.xremap
    girm-full
    grim-slurp
    xlock
    xss-kill
    lock-kill
    lock-restart
    xremap-x-lock-sleep
    x-logout
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

            Super-Shift-Ctrl-l:
                      launch: [ "xlock" ]
            Super-Shift-Ctrl-KEY_SEMICOLON:
                      launch: [ "xremap-x-lock-sleep" ]
            Super-Shift-Ctrl-x:
                      launch: [ "xss-kill" ]





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
