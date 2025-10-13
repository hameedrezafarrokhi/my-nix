{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.kde.plasma.enable) {

 #home.packages = with pkgs; [ plasma-panel-colorizer ];

  programs.plasma = {
    enable = true;

   #file = {};
   #configFile = {};
   #dataFile = {};
   #resetFiles = [];
   #resetFilesExclude = []; # if overrideConfig is true
    overrideConfig = false;
    immutableByDefault = false;

    desktop = {
      icons = {
        alignment = "left"; # “left”, “right”
        arrangement = "topToBottom"; # “leftToRight”, “topToBottom”
        folderPreviewPopups = true;
        lockInPlace = false;
       #previewPlugins = [  ];
        size = 3;  # between 0 and 6
        sorting  = {
          descending = null;
          foldersFirst = true;
          mode = null; # “date”, “manual”, “name”, “size”, “type”
        };
      };
      mouseActions = {
        leftClick = null;
        middleClick = null;
        rightClick = null;
        verticalScroll = null;
      };
     #widgets = {};
    };

    input = {
      keyboard = {
       #model = "";
        switchingPolicy = "window"; # “global”, “desktop”, “winClass”, “window”
        layouts = [
          { layout = "us"; displayName = "EN"; }
          { layout = "ir"; displayName = "FA"; }
        ];
        numlockOnStartup = "on";
       #options = [ "" ];
        repeatDelay = 600;  # between 100 and 5000
        repeatRate = 25.0;  # between 0.2 and 100.0
      };
     #mice = [
     # #{ # THIS IS AN EXAMPLE
     # #  acceleration = 0.5;
     # #  accelerationProfile = "none";
     # #  enable = true;
     # #  leftHanded = false;
     # #  middleButtonEmulation = false;
     # #  name = "Logitech G403 HERO Gaming Mouse";
     # #  naturalScroll = false;
     # #  productId = "c08f";
     # #  scrollSpeed = 1;
     # #  vendorId = "046d";
     # #}
     #];
      touchpads = [
        {
          name = "SynPS/2 Synaptics TouchPad";      # looking at the Name attribute in the section in the /proc/bus/input/devices path belonging to the touchpad.
          productId = "0007"; # looking at the Product attribute in the section in the /proc/bus/input/devices path belonging to the touchpad
          vendorId = "0002";  # looking at the Vendor attribute in the section in the /proc/bus/input/devices path belonging to the touchpad.

          enable = true;
          disableWhileTyping = false;
          leftHanded = false;

          scrollMethod = "twoFingers";      # “touchPadEdges”, “twoFingers”
          naturalScroll = false;
          scrollSpeed = 0.5;                # between 0.1 and 20
          pointerSpeed = 0;                 # between -1 and 1
          accelerationProfile = "default";  # “default”, “none”

          middleButtonEmulation = true;
          tapToClick = true;
          tapAndDrag = true;
          tapDragLock = true;
          rightClickMethod = "bottomRight";  # “bottomRight”, “twoFingers”
          twoFingerTap = "rightClick";      # “rightClick”, “middleClick”
        }
      ];
    };

    shortcuts = {

      "kwin" = {

        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Switch to Desktop 5" = "Meta+5";
        "Switch to Desktop 6" = "Meta+6";
        "Switch to Desktop 7" = "Meta+7";
        "Switch to Desktop 8" = "Meta+8";
        "Switch to Desktop 9" = "Meta+9";

        "Window to Desktop 1" = "Meta+!";
        "Window to Desktop 2" = "Meta+@";
        "Window to Desktop 3" = "Meta+#";
        "Window to Desktop 4" = "Meta+$";
        "Window to Desktop 5" = "Meta+%";
        "Window to Desktop 6" = "Meta+^";
        "Window to Desktop 7" = "Meta+&";
        "Window to Desktop 8" = "Meta+*";
        "Window to Desktop 9" = "Meta+(";

        "Window Close" = "Meta+C";

        "Switch Window Right" = "Meta+Right";
        "Switch Window Left" = "Meta+Left";
        "Switch Window Up" = "Meta+Up";
        "Switch Window Down" = "Meta+Down";

        "Window Quick Tile Bottom" = "";
        "Window Quick Tile Bottom Left" = "";
        "Window Quick Tile Bottom Right" = "";
        "Window Quick Tile Left" = "";
        "Window Quick Tile Right" = "";
        "Window Quick Tile Top" = "";
        "Window Quick Tile Top Left" = "";
        "Window Quick Tile Top Right" = "";

      };

      "plasmashell" = {

        "activate task manager entry 1" = "Meta+F1";
        "activate task manager entry 2" = "Meta+F2";
        "activate task manager entry 3" = "Meta+F3";
        "activate task manager entry 4" = "Meta+F4";
        "activate task manager entry 5" = "Meta+F5";
        "activate task manager entry 6" = "Meta+F6";
        "activate task manager entry 7" = "Meta+F7";
        "activate task manager entry 8" = "Meta+F8";
        "activate task manager entry 9" = "Meta+F9";

        "activate application launcher" = "Meta+Alt+Space";

        "show-on-mouse-pos" = "Meta+Shift+V";

      };

      "org_kde_powerdevil" = {

        "powerProfile" = "Meta+Shift+P";

      };

      "KDE Keyboard Layout Switcher" = {

        "Switch to Next Keyboard Layout" = "Alt+Shift+Space";
        "Switch to Last-Used Keyboard Layout" = "Alt+Shift+Ctrl+Space";

      };

    };

   #hotkeys = {
   #  commands = {
   #    <name> = {
   #      name = "";
   #      command = "";
   #      comment = "";
   #      key = "";
   #      keys = "";
   #      logs = {
   #        enabled = true;
   #        extraArgs = "";
   #        identifier = "plasma-manager-commands-‹name›";
   #      };
   #    };
   #  };
   #};

    startup = {
   #  dataDir = "data";
   # #dataFile = { "" };
   # #desktopScript = {
   # #  <name> = {
   # #    preCommands = "";
   # #    postCommands = "";
   # #    priority = 0; # between 0 and 8
   # #    restartServices = [ "" ];
   # #    runAlways = false;
   # #    text = ''  '';
   # #  };
   # #};
      scriptsDir = "scripts";
      startupScript = {
       #<name> = {
       #  priority = 0; # between 0 and 8
       #  restartServices = [ "" ];
       #  runAlways = false;
       #  text = ''  '';
       #};

       #Yakuake = {
       #  runAlways = true;
       #  text = ''
       #    ${pkgs.kdePackages.yakuake}/bin/yakuake &
       #  '';
       #};
      };
    };

    windows.allowWindowsToRememberPositions = true;
   #window-rules = {
   # #<name> = {
   # #  apply = {
   # #    <name> = {
   # #      apply = "initially"; # “do-not-affect”, “force”, “initially”, “remember”
   # #      value = ; # boolean or floating point number or signed integer or string
   # #    };
   # #  };
   # #  match = {
   # #    machine = {
   # #      type = "exact"; # “exact”, “regex”, “substring”
   # #      value = ""; # Name to match.
   # #    };
   # #    title = {
   # #      type = "exact"; # “exact”, “regex”, “substring”
   # #      value = ""; # Name to match
   # #    };
   # #    window-class = {
   # #      match-whole = true;
   # #      type = "exact"; # “exact”, “regex”, “substring”
   # #      value = ""; # Name to match
   # #    };
   # #    window-role = {
   # #      type = "exact"; # “exact”, “regex”, “substring”
   # #      value = ""; # Name to match
   # #    };
   # #    window-type = [ ]; # one of “desktop”, “dialog”, “dock”, “menubar”, “normal”, “osd”, “spash”, “toolbar”, “torn-of-menu”, “utility”
   # #  };
   # #};
   #};

    workspace = {
      clickItemTo = "select"; # "select" "open"
      tooltipDelay = null;    # milliseconds
    };

    krunner = {
      activateWhenTypingOnDesktop = true;
      historyBehavior = "enableSuggestions"; # “disabled”, “enableSuggestions”, “enableAutoComplete”
      position = "top"; # “top”, “center”
      shortcuts = {
        launch = "Meta+Space";
        runCommandOnClipboard = "Ctrl+Shift+C+Space";
      };
    };

    spectacle = {
      shortcuts = {
        captureActiveWindow = [ "Meta+Print" ];
        captureEntireDesktop = [ "Shift+Print" ];
        captureRectangularRegion = [ "Print" ];
        captureWindowUnderCursor = [ "Meta+Ctrl+Print" ];
        launch = [ "Meta+Alt+Print" ];
        launchWithoutCapturing = [ "Meta+Ctrl+Alt+Print" ];
       #captureCurrentMonitor = [ "Print" ];

        recordRegion = null;
        recordScreen = null;
        recordWindow = null;
      };

    };

    session = {
      general.askForConfirmationOnLogout = true;
      sessionRestore = {
       #excludeApplications = [  ];
        restoreOpenApplicationsOnLogin = "whenSessionWasManuallySaved"; # “onLastLogout”, “startWithEmptySession”, “whenSessionWasManuallySaved”
      };
    };

    powerdevil = {
      general = {
        pausePlayersOnSuspend = true;
      };
      AC = {
        powerProfile = "performance"; # “performance”, “balanced”, “powerSaving”
        powerButtonAction = "showLogoutScreen"; # “hibernate”, “lockScreen”, “nothing”, “showLogoutScreen”, “shutDown”, “sleep”, “turnOffScreen”
        autoSuspend = {
          action = "nothing";
          idleTimeout = null; # between 60 and 600000
        };
        whenLaptopLidClosed = "turnOffScreen"; # “doNothing”, “hibernate”, “lockScreen”, “shutDown”, “sleep”
        inhibitLidActionWhenExternalMonitorConnected = null;
        whenSleepingEnter = null; # “hybridSleep”, “standby”, “standbyThenHibernate”
        dimDisplay = {
          enable = true;
          idleTimeout = 1800;
        };
        turnOffDisplay = {
          idleTimeout = 5400;           # “never” or between 30 and 600000
          idleTimeoutWhenLocked = null; # “whenLockedAndUnlocked”, “immediately” or integer between 20 and 600000
        };
        displayBrightness = null; # between 0 and 100
      };
     #battery = {}; # Same as AC Options
     #batteryLevels = {};
     #lowBattery = {};
    };

    kscreenlocker = {
      autoLock = true;
      timeout = 120;
      lockOnResume = true;
      lockOnStartup = false;
      passwordRequired = true;
      passwordRequiredDelay = 10;
      appearance = {
       # A Bunch Of Wallpaper Options That I Dont Care About
       #wallpaper = ./themes/background.png;
        alwaysShowClock = true;
        showMediaControls = true;
      };
    };

    kwin = {
      borderlessMaximizedWindows = null;
      cornerBarrier = null; # boolean
      edgeBarrier = null; # integer between 0 and 1000

      effects = {
        minimization = {
          animation = null; # “squash”, “magiclamp”, “off”
          duration = null; # milliseconds
        };
        blur = {
          enable = true;
          noiseStrength = null; # between 0 and 14
          strength = null; # between 1 and 15
        };
        desktopSwitching.animation = "off";
        dimInactive.enable = true;
        dimAdminMode.enable = true;
        translucency.enable = true;
        cube.enable = null;
        fallApart.enable = null;
        fps.enable = null;
        shakeCursor.enable = null;
        slideBack.enable = null;
        snapHelper.enable = null;
        windowOpenClose.animation = null; # “fade”, “glide”, “scale”, “off”
        wobblyWindows.enable = null;
      };

      nightLight = {
        enable = null;
        mode = null;  # “constant”, “location”, “times”
        temperature = {
          day = null; # positive integer, example = 4500
          night = null;
        };
        location = {
          latitude = null;
          longitude = null;
        };
        time = {
          evening = null; # time of day, example = "19:30"
          morning = null;
        };
        transitionTime = null; # in minutes
      };

      virtualDesktops = {
        number = 5;
        names = [ "1" "2" "3" "4" "5" ];
        rows = 1;
      };

      scripts.polonium = {
        enable = null;
        settings = {
          enableDebug = null;
          borderVisibility = "borderSelected"; #  “noBorderAll”, “noBorderTiled”, “borderSelected”, “borderAll”
          callbackDelay = null; # between 1 and 200
          filter = {
            processes = null; # [ "firefox" "chromium" ]
            windowTitles = null; # [ "Discord" "Telegram" ]
          };
          layout = {
            engine = null; # “binaryTree”, “half”, “threeColumn”, “monocle”, “kwin”
            insertionPoint = null; # “left”, “right”, “activeWindow”
            rotate = null; # boolean
          };
          maximizeSingleWindow = null;
          resizeAmount = null; # between 1 and 450
          saveOnTileEdit = null; # boolean
          tilePopups = null; # boolean
        };
      };

      tiling.layout = null; # kwin tiling submodules that I dont care about
    };

    panels = [
      {#MyBottomPanel
        location = "bottom";
        alignment = "center";
        floating = true;
        opacity = "translucent";
        height = 40;
        hiding = "dodgewindows";
        lengthMode = "custom";
        maxLength = 1024;
        minLength = 100;
       #offset = ;
       #screen = ;
       #extraSettings = ;
        widgets = [
          {iconTasks = {
             launchers = [
               "applications:org.kde.dolphin.desktop"
               "applications:brave-browser.desktop"
               "applications:kitty.desktop"
               "applications:org.kde.kate.desktop"
             ];
             iconsOnly = true;
             appearance = {
               showTooltips = true;
               highlightWindows = true;
               indicateAudioStreams = true;
               fill = true;
               iconSpacing = "small"; # "small" "medium" "large"
               rows = {
                 multirowView = "never";  # "never" "lowSpace" "always"
                 maximum = 1;
               };
             };
             behavior = {
               grouping = {
                 method = "byProgramName"; # "byProgramName" "none"
                 clickAction = "cycle";    # "cycle" "showTooltips" "showPresentWindowsEffect" "showTextualList"
               };
               sortingMethod = "manually"; # "none" "manually" "alphabetically" "byDesktop" "byActivity"
               minimizeActiveTaskOnClick = true;
              #middleClickAction = "bringToCurrentDesktop";  # "none" "close" "newInstance" "toggleMinimized" "toggleGrouping" "bringToCurrentDesktop"
               wheel = {
                 switchBetweenTasks = true;
                 ignoreMinimizedTasks = true;
               };
               showTasks = {
                 onlyInCurrentScreen = false;
                 onlyInCurrentDesktop = false;
                 onlyInCurrentActivity = false;
                 onlyMinimized = false;
               };
               unhideOnAttentionNeeded = true;
               newTasksAppearOn = "right";  # "right" "left"
             };
          };}
        ];
      }
      {#MyTopPanel
        location = "top";
        alignment = "center";
        floating = false;
        opacity = "translucent";
        height = 28;
        hiding = "none";
        lengthMode = "fill";
       #maxLength = 1024;
       #minLength = 300;
       #offset = ;
       #screen = ;
       #extraSettings = ;
        widgets = [
          "org.kde.plasma.kicker"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.lock_logout"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemmonitor.memory"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemmonitor.cpu"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemmonitor.net"

          {panelSpacer = {
            expanding = false;
            length = 277;
          };}

          "org.kde.plasma.timer"
          {panelSpacer = {
            expanding = false;
            length = 50;
          };}
          "org.kde.plasma.weather"
          {digitalClock = {
             date = {
               enable = true;
              #format = "shortDate";  # "shortDate" "longDate" "isoDate"
               format.custom = "ddd d";
               position = "besideTime";  # "besideTime" "belowTime" "adaptive"
             };
             time = {
               showSeconds = "onlyInTooltip"; # "never" "always" "onlyInTooltip"
               format = "24h";  # "12h" "24h" "default"
             };
             timeZone = {
              #selected = [ osConfig.my.timeZone ];
              #lastSelected = [ osConfig.my.timeZone ];
               format = "city";  # "city" "code" "offset"
               changeOnScroll = true;
               alwaysShow = false;
             };
             calendar = {
               firstDayOfWeek = "saturday";
              #plugins = [ "" ];
               showWeekNumbers = true;
             };
             font = {
               family = "Comic Sans MS";
               bold = true;
               size = 12;
             };
          };}
          {panelSpacer = {
            expanding = false;
            length = 50;
          };}
          "org.dhruv8sh.kara"

          "org.kde.plasma.panelspacer"

          "org.kde.plasma.systemtray"
          "org.kde.plasma.showdesktop"

         #"org.kde.plasma.kickoff"
         #{kickoff = {
         #  #icon = "";
         #  #label = "Menu";
         #  #sortAlphabetically = true;
         #  #compactDisplayStyle = true;
         #  #sidebarPosition = "left";        # "right" "left"
         #  #favoritesDisplayMode = "grid;    # "grid" "list"
         #  #applicationsDisplayMode = "list" # "grid" "list"
         #   showActionButtonCaptions = false;
         #  #pin = true;
         #  #showButtonsFor = [ ]             # "lock-screen" "logout" "save-session" "switch-user" "suspend" "hibernate" "reboot" "shutdown"
         #  #popupWidth = 653;
         #  #popupHeight = 626;
         #};}

        ];
      }
    ];

    file = {

      "/.config/kwinrc" = {
        "Effect-diminactive" = {
          "Strength" = 60;
        };
      };
      "/.config/kwinrc" = {
        "Windows" = {
          "DelayFocusInterval" = 0;
        };
      };
      "/.config/kwinrc" = {
        "Windows" = {
          "FocusPolicy" = "FocusFollowsMouse";
        };
      };
      "/.config/kwinrc" = {
        "Plugins" = {
          "krohnkiteEnabled" = true;
        };
      };
      "/.config/kwinrc" = {
        "Script-krohnkite" = {
          "binaryTreeLayoutOrder" = 1;
          "screenGapBetween" = 8;
          "screenGapBottom" = 8;
          "screenGapLeft" = 8;
          "screenGapRight" = 8;
          "screenGapTop" = 8;
          "tileLayoutOrder" = 11;
        };
      };

     #"/.config/plasma-org.kde.plasma.desktop-appletsrc" = {
     #  "Containments][527][Applets][534][Configuration][Appearance]" = {
     #    "chartFace" = "org.kde.ksysguard.piechart";
     #  };
     #};

    };

  };

 #home.activation = {
 #
 #  PlasmaAppletsrc = lib.hm.dag.entryAfter ["writeBoundary"] ''
 #    cp -f /etc/nixos/user/hrf/plasma-org.kde.plasma.desktop-appletsrc "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
 #    chmod 644 "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
 #    chown "$(id u):$(id -g)" "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
 #  '';
 #
 #};

};}
