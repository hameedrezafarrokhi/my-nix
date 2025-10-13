{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (config.my.keyboard.xremap.enable) {

  home.packages = [
    pkgs.xremap
  ];

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

    yamlConfig = ''


      keymap:

        - name: Launch-default-Apps
          remap:
            Super-z:
              remap:
                    Enter:
                      launch: [ "${lib.getExe pkgs.kitty}" ]
                    b:
                      launch: [ "${lib.getExe pkgs.brave}" ]
                    e:
                      launch: ["bash", "${config.home.homeDirectory}/.local/state/home-manager/gcroots/current-home/home-path/share/applications/org.kde.dolphin.desktop"]
                    t:
                      launch: [ "kate" ]
                    r:
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





        - name: Launch-Alternative-Apps
          remap:
            Alt-x:
              remap:
                    Enter:
                      remap:
                            k:
                              launch: [ "konsole" ]
                            t:
                              launch: [ "kitty" ]
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
                    r:
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
                    p:
                      remap:
                            p:
                              launch: [ "flameshot", "gui" ]
                            w:
                             launch: [ "flameshot", "screen", "-p", "${config.home.homeDirectory}/Pictures/Screenshots" ]
                            c:
                              launch: [ "flameshot", "config" ]






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
                    o:
                      launch: [ "loginctl", "terminate-user", "${admin}" ]
                    l:
                      launch: [ "loginctl", "lock-session" ]
                    s:
                      launch: [ "systemctl", "suspend" ]
                    h:
                      launch: [ "systemctl", "hibernate" ]
                    m:
                      launch: [ "systemctl", "suspend-then-hibernate" ]






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
