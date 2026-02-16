{ config, pkgs, lib, inputs, mypkgs, ... }:

let

  cfg = config.my.x11;

  x-cursor = pkgs.writeShellScriptBin "x-cursor" ''sleep 3 && xsetroot -cursor_name left_ptr'';
  x-cursor-start = pkgs.writeTextFile {
    name = "x-cursor.desktop";
    text = ''
      [Desktop Entry]
      Name=X-Cursor
      Comment=X-Cursor
      Exec=${x-cursor}/bin/x-cursor
    '';
  };

  # ${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 10 -n -c 24273a &
 #x-lock-sleep = pkgs.writeShellScriptBin "x-lock-sleep" ''
 #  # Time before sleep (in seconds)
 #  DELAY0=120  # 2 minutes
 #  DELAY=180   # 3 minutes
 #
 #  yes | xsession-manager -s temp &
 #  dunstctl set-paused true
 #
 #  ${pkgs.betterlockscreen}/bin/betterlockscreen -l dimblur --off 30 --show-layout &
 #  LOCK_PID=$!
 #
 #  # Wait for delay
 #  sleep "$DELAY0"
 #
 #  # If i3lock is still running, system is still locked
 #  if kill -0 "$LOCK_PID" 2>/dev/null; then
 #      xset dpms force standby
 #  fi
 #
 #  # Wait for delay
 #  sleep "$DELAY"
 #
 #  # If i3lock is still running, system is still locked
 #  if kill -0 "$LOCK_PID" 2>/dev/null; then
 #      systemctl suspend
 #  fi
 #
 #  # Just in case: when i3lock exits, kill this script
 #  wait "$LOCK_PID"
 #'';

  x-lock-sleep = pkgs.writeShellScriptBin "x-lock-sleep" ''
    echo "y" | xsession-manager -s temp
    dunstctl set-paused true
    ${pkgs.betterlockscreen}/bin/betterlockscreen -l dimblur --off 120 --show-layout
    sleep 180
    if pgrep betterlock > /dev/null; then
        systemctl suspend
    fi
  '';

  x-lock = pkgs.writeShellScriptBin "x-lock" ''
    echo "y" | xsession-manager -s temp
    dunstctl set-paused true
    ${pkgs.betterlockscreen}/bin/betterlockscreen -l dimblur --off 120 --show-layout
  '';

  xsession-save = pkgs.writeShellScriptBin "xsession-save" ''
    OUT="$HOME/.cache/xsession-restore"
    mkdir -p "$(dirname "$OUT")"
    : > "$OUT"

    # Use xlsclients to extract command strings for each GUI client
    xlsclients -l | awk '/command/ {sub(/^.*command: /,""); print}' | while read -r cmd
    do
        # Filter out empty or weird commands
        if [ -n "$cmd" ] && [[ "$cmd" != "??" ]]; then
            echo "$cmd" >> "$OUT"
        fi
    done

    notify-send -e -u critical -t 5000 "Session saved" "Stored in ~/.cache/xsession-restore"
  '';

  xsession-load = pkgs.writeShellScriptBin "xsession-load" ''
    IN="$HOME/.cache/xsession-restore"

    if [ ! -f "$IN" ]; then
        notify-send -e -u critical -t 5000 "Restore failed" "No saved session file found."
        exit 1
    fi

    while IFS= read -r cmd
    do
        if [ -n "$cmd" ]; then
            # Launch each application in background
            bash -c "$cmd" &
        fi
    done

    notify-send -e -u critical -t 5000 "Session restored" "Applications launched."
  '';

  feh-cycle = pkgs.writeShellScriptBin "feh-cycle" ''
    ${builtins.readFile ./feh-cycle.sh}
  '';

 #feh-rofi = pkgs.writeShellScriptBin "feh-rofi" ''
 #  dir="${config.home.homeDirectory}/Pictures/Wallpapers/${config.my.theme}/" # ends with a /
 #  cd $dir
 #  wallpaper="none is selected"
 #  set="feh --bg-fill"
 #  view="feh -F"
 #  selectpic(){
 #      wallpaper=$(ls $dir | rofi -dmenu -p "select: ($wallpaper)" -theme $HOME/.config/rofi/themes/main.rasi)
 #
 #      if [[ $wallpaper == "qq" ]]; then
 #          exit
 #      else
 #          action
 #      fi
 #  }
 #  action(){
 #    whattodo=$(echo -e "view\nset" | rofi -dmenu -p "action ($wallpaper)" -theme $HOME/.config/rofi/themes/main.rasi)
 #      if [[ $whattodo == "set" ]]; then
 #          set_wall
 #      else
 #          view_wall
 #      fi
 #  }
 #  set_wall(){
 #      $set $wallpaper && pkill feh &
 #  }
 #  view_wall(){
 #      $view $wallpaper &
 #      set_after_view
 #  }
 #  set_after_view(){
 #    setorno=$(echo -e "set\nback" | rofi -dmenu -p "set it? ($wallpaper)" -theme $HOME/.config/rofi/themes/main.rasi)
 #
 #    if [[ $setorno == "set" ]]; then
 #        set_wall
 #    else
 #        pkill feh &
 #        sleep 1 &
 #        feh-rofi &
 #    fi
 #  }
 #  selectpic
 #'';

  feh-rofi = pkgs.writeShellScriptBin "feh-rofi" ''
    WALL_DIR="${config.home.homeDirectory}/Pictures/Wallpapers/${config.my.theme}"
    CACHE_DIR="$HOME/.cache/feh-picker/thumbs"
    ROFI_THEME="$HOME/.config/rofi/themes/thumb.rasi"
    mkdir -p "$CACHE_DIR"
    find "$WALL_DIR" -maxdepth 1 -type f \
      \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
      | while read -r img; do
          thumb="$CACHE_DIR/$(basename "$img")"
          if [ ! -f "$thumb" ]; then
            magick "$img" -strip -thumbnail 500x500^ -gravity center -extent 500x500 "$thumb"
          fi
        done
    choice=$(
      find "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        | sort \
        | while read -r img; do
            base="$(basename "$img")"
            printf "%s\0icon\x1f%s\n" "$base" "$CACHE_DIR/$base"
          done \
        | rofi \
            -show drun \
            -dmenu \
            -show-icons \
            -theme "$ROFI_THEME" \
            -p "Wallpaper"
    )

    [ -z "$choice" ] && exit 0
    pkill paperview-rs
    feh --bg-fill "$WALL_DIR/$choice"
  '';

  feh-rofi-manual = pkgs.writeShellScriptBin "feh-rofi-manual" ''
    ROFI_THEME="$HOME/.config/rofi/themes/main.rasi"
    choice=$(rofi -dmenu -theme "$ROFI_THEME" -p "Wallpaper Path:")
    [[ -z "$choice" ]] && exit 0

    PROC="paperview-rs"
    PID=$(pgrep -n "$PROC")
    kill -CONT "$PID"
    pkill paperview-rs

    CMD="feh --bg-fill $choice"
    eval "$CMD"
  '';

  paperview-rofi = pkgs.writeShellScriptBin "paperview-rofi" ''
    WALL_DIR="${inputs.assets}/live-wallpapers" # TODO: Not Working With Nix Symlinks, Only Works With Normal Files
    LIVE_BG="$HOME/.live-bg"
    CACHE_DIR="$HOME/.cache/paperview-picker/thumbs"
    ROFI_THEME="$HOME/.config/rofi/themes/thumb.rasi"
    DEFAULT_SPEED=10
    RES="${config.my.display.primary.x}:${config.my.display.primary.y}:0:0"
    mkdir -p "$CACHE_DIR"
    find "$WALL_DIR" -maxdepth 4 -type f \
      \( -iname "*.png" \) \
      | while read -r img; do
          thumb="$CACHE_DIR/$(basename "$img")"
          if [ ! -f "$thumb" ]; then
            ffmpeg -i "$img" -map_metadata -1 -vf "scale='if(gt(iw,ih),-1,500)':'if(gt(iw,ih),500,-1)',crop=500:500" "$thumb"
          fi
        done
    choice=$(
      find "$WALL_DIR" -maxdepth 3 -type d \
        | while read -r dir; do
            img=$(find "$dir" -maxdepth 1 -type f \
              \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
              | head -n 1)
            [ -z "$img" ] && continue
            thumb="$CACHE_DIR/$(basename "$img")"
            printf "%s\0icon\x1f%s\n" "$dir" "$thumb"
          done \
        | rofi \
            -dmenu \
            -show-icons \
            -theme "$ROFI_THEME" \
            -p "Wallpaper"
    )
    [ -z "$choice" ] && exit 0

    PROC="paperview-rs"
    PID=$(pgrep -n "$PROC")
    kill -CONT "$PID"
    pkill paperview-rs

    CMD="paperview-rs --bg \"$RES:$choice:$DEFAULT_SPEED\""
    echo "#!/bin/bash" > "$LIVE_BG"
    echo "$CMD" >> "$LIVE_BG"
    chmod +x "$LIVE_BG"
    cd $HOME/.cache && eval "$CMD"
  '';

  live-bg-manual = pkgs.writeShellScriptBin "live-bg-manual" ''
    LIVE_BG="$HOME/.live-bg"
    ROFI_THEME="$HOME/.config/rofi/themes/main.rasi"
    DEFAULT_SPEED=10
    RES="${config.my.display.primary.x}:${config.my.display.primary.y}:0:0"
    choice=$(rofi -dmenu -theme "$ROFI_THEME" -p "Live Wallpaper Path:")
    [[ -z "$choice" ]] && exit 0

    PROC="paperview-rs"
    PID=$(pgrep -n "$PROC")
    kill -CONT "$PID"
    pkill paperview-rs

    CMD="paperview-rs --bg \"$RES:$choice:$DEFAULT_SPEED\""
    echo "#!/bin/bash" > "$LIVE_BG"
    echo "$CMD" >> "$LIVE_BG"
    chmod +x "$LIVE_BG"
    cd $HOME/.cache && eval "$CMD"
  '';

  live-bg = pkgs.writeShellScriptBin "live-bg" ''
    LIVE_BG="$HOME/.live-bg"
    LIVE_DIR="$HOME/Pictures/live-wallpapers"
    RES="${config.my.display.primary.x}:${config.my.display.primary.y}:0:0"
    DEFAULT_FOLDER=1
    DEFAULT_SPEED=10

    PROC="paperview-rs"
    PID=$(pgrep -n "$PROC")
    if [ -z "$PID" ]; then
      echo "not running"
    else
      kill -CONT "$PID"
      pkill paperview-rs
      exit 0
    fi
    #pkill paperview-rs 2>/dev/null && touch $HOME/.fehbg && exit 0

    if [[ -f "$LIVE_BG" ]]; then
        touch $HOME/.live-bg
        cd $HOME/.cache && bash "$LIVE_BG"
        exit 0
    fi

    CMD="paperview-rs --bg \"$RES:$LIVE_DIR/$DEFAULT_FOLDER/:$DEFAULT_SPEED\""
    echo "#!/bin/bash" > "$LIVE_BG"
    echo "$CMD" >> "$LIVE_BG"
    chmod +x "$LIVE_BG"
    cd $HOME/.cache && eval "$CMD"
  '';

  live-bg-cycle = pkgs.writeShellScriptBin "live-bg-cycle" ''
    LIVE_BG="$HOME/.live-bg"
    LIVE_DIR="$HOME/Pictures/live-wallpapers"
    RES="${config.my.display.primary.x}:${config.my.display.primary.y}:0:0"
    DEF_FOLDER=1
    DEF_SPEED=10
    ACTION="$1"

    PROC="paperview-rs"
    PID=$(pgrep -n "$PROC")
    pkill paperview-rs 2>/dev/null && kill -CONT "$PID"

    if [[ -f "$LIVE_BG" ]]; then
        CUR_FOLDER=$(grep -oP 'live-wallpapers/\K[0-9]+' "$LIVE_BG")
        CUR_SPEED=$(grep -oP ':[0-9]+$' "$LIVE_BG" | tr -d :)
    fi

    [[ -z "$CUR_FOLDER" ]] && CUR_FOLDER=$DEF_FOLDER
    [[ -z "$CUR_SPEED"  ]] && CUR_SPEED=$DEF_SPEED
    MAX=$(ls -d "$LIVE_DIR"/*/ 2>/dev/null | wc -l)
    if [[ "$ACTION" == "+" ]]; then
        ((CUR_FOLDER++))
        ((CUR_FOLDER > MAX)) && CUR_FOLDER=1
    elif [[ "$ACTION" == "-" ]]; then
        ((CUR_FOLDER--))
        ((CUR_FOLDER < 1)) && CUR_FOLDER=$MAX
    else
        exit 1
    fi
    CMD="paperview-rs --bg \"$RES:$LIVE_DIR/$CUR_FOLDER/:$CUR_SPEED\""
    printf '#!/bin/bash\n%s\n' "$CMD" > "$LIVE_BG"
    chmod +x "$LIVE_BG"
    cd $HOME/.cache && eval "$CMD"
  '';

  live-bg-speed = pkgs.writeShellScriptBin "live-bg-speed" ''
    LIVE_BG="$HOME/.live-bg"
    LIVE_DIR="$HOME/Pictures/live-wallpapers"
    RES="${config.my.display.primary.x}:${config.my.display.primary.y}:0:0"
    DEF_FOLDER=1
    DEF_SPEED=10
    ACTION="$1"

    PROC="paperview-rs"
    PID=$(pgrep -n "$PROC")
    pkill paperview-rs 2>/dev/null && kill -CONT "$PID"

    if [[ -f "$LIVE_BG" ]]; then
        CUR_FOLDER=$(sed -n 's|.*/live-wallpapers/\([0-9]\+\)/.*|\1|p' "$LIVE_BG")
        CUR_SPEED=$(sed -n 's|.*:\([0-9]\+\)".*|\1|p' "$LIVE_BG")
    fi
    [[ -z "$CUR_FOLDER" ]] && CUR_FOLDER=$DEF_FOLDER
    [[ -z "$CUR_SPEED"  ]] && CUR_SPEED=$DEF_SPEED
    if [[ "$ACTION" == "+" ]]; then
        CUR_SPEED=$((CUR_SPEED + 1))
    elif [[ "$ACTION" == "-" ]]; then
        CUR_SPEED=$((CUR_SPEED - 1))
        ((CUR_SPEED < 1)) && CUR_SPEED=1
    else
        exit 1
    fi
    CMD="paperview-rs --bg \"$RES:$LIVE_DIR/$CUR_FOLDER/:$CUR_SPEED\""
    printf '#!/bin/bash\n%s\n' "$CMD" > "$LIVE_BG"
    chmod +x "$LIVE_BG"
    cd $HOME/.cache && eval "$CMD"
  '';

  live-bg-pause = pkgs.writeShellScriptBin "live-bg-pause" ''
    PROC="paperview-rs"
    PID=$(pgrep -n "$PROC")
    if [ -z "$PID" ]; then
        echo "Process not running"
        exit 1
    fi
    STATE=$(ps -o state= -p "$PID")
    if [[ "$STATE" == *T* ]]; then
        kill -CONT "$PID"
        echo "Resumed $PROC"
    else
        kill -STOP "$PID"
        echo "Paused $PROC"
    fi
  '';

  live-bg-speed-manual = pkgs.writeShellScriptBin "live-bg-speed-manual" ''
    FILE="$HOME/.live-bg"
    [ -f "$FILE" ] || exit 0
    SPEED=$(rofi -dmenu -p "Speed" -theme $HOME/.config/rofi/themes/power.rasi)
    [ -z "$SPEED" ] && exit 0
    sed -i "s/:\([0-9]\+\)\"$/:$SPEED\"/" "$FILE"

    PROC="paperview-rs"
    PID=$(pgrep -n "$PROC")
    pkill paperview-rs && kill -CONT "$PID" && $HOME/.live-bg
  '';

  rofi-monitor = pkgs.writeShellScriptBin "rofi-monitor" ''
    ${builtins.readFile ./rofi-monitor}
  '';

  xfilesctl = pkgs.writeShellScriptBin "xfilesctl" ''
    ${builtins.readFile ./xfilesctl}
  '';

  xfilesthumb = pkgs.writeShellScriptBin "xfilesthumb" ''
    ${builtins.readFile ./xfilesthumb}
  '';

in

{

  options = {

    my.x11.enable =  lib.mkEnableOption "x11 configs";

    services.screen-locker.inactiveIntervalString = lib.mkOption {
       type = lib.types.nullOr (lib.types.str);
       default = "6000";
    };

    services.screen-locker.xss-lock.screensaverCycleString = lib.mkOption {
       type = lib.types.nullOr (lib.types.str);
       default = "6000";
    };

  };

  config = lib.mkIf cfg.enable {

    # "!XDG_BACKEND=wayland"
    systemd.user.services.snixembed.Unit.ConditionEnvironment = "!XDG_SESSION_TYPE=wayland";

    systemd.user.services.x-cursor = {
      Unit = {
        Description = "x-cursor";
        After = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${x-cursor}/bin/x-cursor";
        RemainsAfterExit = "yes";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    home.packages = [
      pkgs.feh
      pkgs.xkb-switch
      pkgs.xdotool
      pkgs.pamixer
      pkgs.wayback-x11
      pkgs.xdo
      pkgs.xbacklight
      pkgs.xkblayout-state
      pkgs.skippy-xd
      pkgs.xcolor
      mypkgs.stable.xmagnify
      pkgs.xzoom
      pkgs.sxcs
      pkgs.betterlockscreen
      pkgs.pmenu
      pkgs.xmessage
      pkgs.gxmessage
     #pkgs.deadd-notification-center
      (pkgs.xmenu.override {
        imlib2 = pkgs.imlib2Full;
      })


      x-cursor
      x-lock-sleep
      x-lock
      xsession-load
      xsession-save
      rofi-monitor
      feh-rofi
      feh-cycle
      feh-rofi-manual
      live-bg
      live-bg-speed
      live-bg-cycle
      live-bg-pause
      live-bg-speed-manual
      live-bg-manual
      paperview-rofi
      xfilesctl
      xfilesthumb
    ];

    xsession = {

      enable = true;
      numlock.enable = true;
      preferStatusNotifierItems = true;
      profilePath = ".xprofile";
      scriptPath = ".xsession";

      initExtra = ''

        # first number Rate (faster start spawning repeating key when held) second number Delay (faster key press when held)
        xset r rate 250 35 &
        xset s $(( ${toString config.services.screen-locker.inactiveInterval} * 60 )) ${toString config.services.screen-locker.xss-lock.screensaverCycle} &
        xset +dpms &
        # Standby: 30 Suspend: 40 Off: 90
        # Default is 600 600 600
        #xset dpms 2100 2400 2700 &
        #xset dpms 6000 6000 6000 &
        xset dpms $(( ${toString config.services.screen-locker.inactiveInterval} * 60 )) $(( ${toString config.services.screen-locker.inactiveInterval} * 60 )) $(( ${toString config.services.screen-locker.inactiveInterval} * 60 )) &
        #xset -dpms &
        #xset dpms 0 0 0 &
        #xset dpms 2100 2400 2700
        export GDK_BACKEND=x11 &
        setxkbmap -layout us,ir -option "grp:alt_caps_toggle" &
        #blueman-applet &
        #skippy-xd --start-daemon &
        #xclickroot -r xmenu-app &

      '';

      profileExtra = ''

        # Load One By One

        #export GDK_BACKEND=x11
        #QT_QPA_PLATFORM=xcb
        #XDG_SESSION_TYPE=x11    # Breaks QT SNI

        systemctl --user import-environment DESKTOP_SESSION XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP

        #systemctl --user import-environment DESKTOP_SESSION XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_PATH XCURSOR_PATH XDG_SESSION_ID XDG_SESSION_CLASS COLORTERM XDG_MENU_PREFIX XDG_DESKTOP_DIR LIBVA_DRIVER_NAME XDG_DATA_HOME XDG_STATE_HOME XDG_CONFIG_HOME LD_LIBRARY_PATH NIX_LD LOCALE_ARCHIVE HOME NIX_LD_LIBRARY_PATH ANV_DEBUG QT_STYLE_OVERRIDE LOGNAME TERMINFO INFOPATH GTK2_RC_FILE MESA_VK_DEVICE_SELECT NIX_USER_PROFILE_DIR GDK_PIXBUF_MODULE_FILE NAUTILUS_4_EXTENSION_DIR GTK_PATH GTK_A11Y NIX_GSETTINGS_OVERRIDES_DIR NIX_XDG_DESKTOP_PORTAL_DIR NH_FLAKE STEAM_EXTRA_COMPAT_TOOLS_PATHS XDG_TEMPLATES_DIR EDITOR PAGER KITTY_INSTALLATION_DIR NIX_PROFILES XDG_VIDEOS_DIR SSH_ASKPASS SHELL XDG_DATA_DIRS SSH_TPM_AUTH_SOCK TERM DISPLAY NIXOS_XDG_OPEN_USE_PORTAL XDG_MUSIC_DIR XDG_DOWNLOAD_DIR VDPAU_DRIVER XCURSOR_THEME XDG_CACHE_HOME XCURSOR_SIZE XDG_PICTURES_DIR XDG_DOCUMENTS_DIR XDG_CONFIG_DIR STARSHIP_SHELL XDG_MISC_DIR XDG_RUNTIME_DIR HM_XPROFILE_SOURCED STARSHIP_CONFIG XAUTHORITY JAVA_HOME _JAVA_AWT_WM_NONREPARENTING DBUS_SESSION_BUS_ADDRESS XDG_SEAT_PATH XDG_SEAT GNUPGHOME TERMINFO_DIRS SSH_AUTH_SOCK VISUAL NIXPKGS_CONFIG TERMINAL TPM2TOOLS_TCTI FZF_DEFAULT_OPTS GIO_EXTRA_MODULES NIX_PATH XDG_PUBLICSHARE_DIR XCURSOR_PATH



        # To Load Everything (QT Apps Dont play well)

        #dbus-update-activation-environment --systemd --all
        #systemctl --user import-environment

      '';

      importedVariables = [ ];

      windowManager.command = lib.mkForce "test -n \"$1\" && eval \"$@\"";
    };

    systemd.user.services.xautolock-session.Service.ExecStart = lib.mkForce (lib.concatStringsSep " " (
      [
        "${config.services.screen-locker.xautolock.package}/bin/xautolock"
        "-time ${toString config.services.screen-locker.inactiveInterval}"
        "-locker '${config.services.screen-locker.lockCmd}'"
      ]
      ++ lib.optional config.services.screen-locker.xautolock.detectSleep "-detectsleep"
      ++ config.services.screen-locker.xautolock.extraOptions
    ));


    services = {

      xsettingsd = {
        enable = true;
        package = pkgs.xsettingsd;
        settings = {
          "Net/CursorBlinkTime" = 1000;
          "Net/CursorBlink" = 1;
          "Gdk/UnscaledDPI" = 98304;
          "Gdk/WindowScalingFactor" = 1;
        };
      };

      # Bridge for Legacy X Apps thta dont have SNI features ( Choose One )
      snixembed.enable = true; # StandAlone and lightweight ( works great in x11 but breaks wayland wm tray )
      xembed-sni-proxy = { # Part of Plasma ecosystem ( works great in wayland but breaks x11 tray )
        enable = false;
        package = pkgs.kdePackages.plasma-workspace;
      };

      screen-locker = {
        enable = true;
        inactiveInterval = 30; # min 1 max 60 (minutes)
        lockCmdEnv = [
          "XSECURELOCK_PAM_SERVICE=xsecurelock"
        ];
        lockCmd = "${x-lock-sleep}/bin/x-lock-sleep";
        # "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 10 -n -c 24273a -p default";
        # "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 10 -n -c 24273a -p default"
        #lib.mkDefault "${pkgs.i3lock}/bin/i3lock -n -c 000000 -f -k ";
        # "${pkgs.betterlockscreen}/bin/betterlockscreen --lock"
        # betterlockscreen -l --wallpaper-cmd "feh --bg-fill /home/hrf/Pictures/Wallpapers/astronaut-macchiato.png" -u "/home/hrf/Pictures/Wallpapers/astronaut-macchiato.png"
        xautolock = {
          enable = true; # Either This Or XSS, ONLY ONE CAN BE USED (xauto lock uses loginctl (which doesnt work on x) and doesnt set xset s AND doesnt use lockCMD instead uses its own things (llisted below) BUT Detects sleep and other features, xss Uses lockCMD And sets xset s BUT its bear bones)
          package = pkgs.xautolock; # pkgs.xidlehook
          detectSleep = true;
          extraOptions = [
           #"-time mins         " # time before locking the screen [1 <= mins <= 60]. # IS DEFINED WITH inactiveInterval
           #"-locker locker     " # program used to lock.                             # IS DEFINED WITH lockCmd
           #"-nowlocker locker  " # program used to lock immediately.
           #"-killtime killmins " # time after locking at which to run the killer [10 <= killmins <= 120].
           #"-killer killer     " # program used to kill.
           #"-notify margin     " # notify this many seconds before locking.
           #"-notifier notifier " # program used to notify.
           #"-bell percent      " # loudness of notification beeps.
           #"-corners xxxx      " # corner actions (0, +, -) in this order topleft topright bottomleft bottomright
           #"-cornerdelay secs  " # time to lock screen in a `+' corner.
           #"-cornerredelay secs" # time to relock screen in a `+' corner.
           #"-cornersize pixels " # size of corner areas.
           #"-nocloseout        " # do not close stdout.
           #"-nocloseerr        " # do not close stderr.
           #"-noclose           " # close neither stdout nor stderr.
           #"-enable            " # enable a running xautolock.
           #"-disable           " # disable a running xautolock.
           #"-toggle            " # toggle a running xautolock.
           #"-locknow           " # tell a running xautolock to lock.
           #"-unlocknow         " # tell a running xautolock to unlock.
           #"-restart           " # tell a running xautolock to restart.
           #"-exit              " # kill a running xautolock.
           #"-secure            " # ignore enable, disable, toggle, locknow unlocknow, and restart messages.
           #"-resetsaver        " # reset the screensaver when starting the locker.
           #"-detectsleep       " # reset timers when awaking from sleep.             # IS DEFINED WITH detectSleep
           #"-lockaftersleep    " # lock immediately after waking up from sleep.
          ];
        };
        xss-lock = {
          package = pkgs.xss-lock;
          extraOptions = [ ];
          screensaverCycle = (config.services.screen-locker.inactiveInterval * 60); # 1800; # max 3600;
          screensaverCycleString = "1800";
        };
      };
     #betterlockscreen = {
     #  enable = true;
     # #package = ;
     #  arguments = [ ];
     #  inactiveInterval = 60;
     #};

      xscreensaver = {
        enable = false;
        package = pkgs.xscreensaver;
        settings = {
          fadeTicks = 20;
          mode = "off"; # "blank" "random" "one"
          lock = true;
         #timeout = "0:02:00";
        };
      };

      picom ={
        enable = true;
        package = pkgs.picom;
       #package = pkgs.callPackage ../../../nixos/myPackages/picom-ft.nix { };# pkgs.picom-pijulius; # pkgs.picom;
        backend = "egl"; # "egl", "glx", "xrender", "xr_glx_hybrid"

        shadow = true;
        shadowOpacity = 0.80;
       #shadowOffsets = [ 15 15 ];
        shadowExclude = [
         #"name = 'Notification'"
         #"class_g ?= 'Notify-osd'"

          "_GTK_FRAME_EXTENTS@:c && (window_type = 'menu' || window_type = 'dropdown_menu')" # this is for brave

          "class_g = 'ulauncher'"
          "class_g = 'Ulauncher'"

          "class_g = 'dockx'"
          "class_g = 'Dockx'"

          # only way for gtk4 menu stuff
          #class_g = 'firefox' && (window_type = 'menu' || window_type = 'dropdown_menu' || window_type = 'popup_menu' || window_type = 'utility' || window_type = 'unknown' || window_type = 'toolbar' || window_type = 'tooltip' || window_type = 'dialog')"
          "class_g = 'iotas' && (window_type = 'menu' || window_type = 'dropdown_menu')"
          "class_g = '.warehouse-wrapped' && (window_type = 'menu' || window_type = 'dropdown_menu')"
          "class_g = 'org.gnome.Mines' && (window_type = 'menu' || window_type = 'dropdown_menu')"
          "class_g = 'resources' && (window_type = 'menu' || window_type = 'dropdown_menu')"
          "class_g = 'baobab' && (window_type = 'menu' || window_type = 'dropdown_menu')"
        ];

        fade = true;
        fadeSteps = [ 0.05 0.05 ];
        fadeDelta = 10;
        fadeExclude = [ ];

        activeOpacity = 1.0;
        menuOpacity = 1.0;
        inactiveOpacity = 0.85;
        opacityRules = [ # doesnt work
         #"100:class_g = 'firefox'"
         #"100:class_g = 'chromium'"
         #"100:class_g = 'brave-browser'"
         #"100:class_g *= 'Brave-browser'"
         #"100:class_g = 'brave'"
         #"100:class_g = 'Brave'"
         #"95:class_g =  'kitty'"
         #"95:class_g =  'dolphin'"
         #"100:class_name *= 'Dunst'"
         #"100:class_name *= 'iotas'"
        ];

        settings = {
          blur = {
            method = "dual_kawase"; # "gaussian";
            size = 13;
            strength = 7;
            deviation = 6.0;
            background-frame = false;
            kern = "3x3box";
            background-exclude = [ # use the oher option for exclude blurs
              "window_type = 'Polybar'"
              "window_type = 'desktop'"
              "window_type = 'dock'"

             #"window_type = 'tooltip'"
             #"window_type = 'popup_menu'"
             #"window_type = 'toolbar'"
             #"window_type = 'menu'"
             #"window_type = 'dialog'"
             #"window_type = 'dropdown_menu'"
             #"window_type = 'unknown'"
             #"window_type = 'utility'"

             #"role = 'xborder'"
              "class_g = 'Conky'"
              "class_g = 'conky'"

             #"name = 'Notification'" # doesnt work
             #"class_g = 'Dunst'" # doesnt work

             #"_GTK_FRAME_EXTENTS"
             #"_GTK_FRAME_EXTENTS@:c"
             #"class_g = 'GtkFrame'"

             #"class_g = 'ulauncher'" # doesnt work
             #"class_g = 'Ulauncher'" # doesnt work
              "class_g = 'dockx'"
              "class_g = 'Dockx'"
             #"class_g = 'Gtk'" # works for gtk3
             #"class_g = 'iotas'" # gtk4 apps dont work at all
            ];
          };
         #blur-kern = "3x3box";
          corner-radius = 10;
          shadow-radius = 20;
         #shadow-offset-x = "5";
         #shadow-offset-y = "-5";
          shadow-color = "#000000";
          frame-opacity = 1.0;
          inactive-opacity-override = true;
         #round-borders = 8;
          blur-background-exclude = [
            "window_type = 'dock'"
            "window_type = 'desktop'"

           #"_GTK_FRAME_EXTENTS@:c" # wroks (for brave)

           #"GtkFrame@:c"

           #"window_type = 'tooltip'"
           #"window_type = 'toolbar'"
           #"window_type = 'dialog'"
           #"window_type = 'unknown'"
           #"window_type = 'utility'"

           # works:
           #"window_type = 'popup_menu'" # affects things like copyq popus menu
            "window_type = 'menu'"
            "window_type = 'dropdown_menu'"

            "class_g = 'ulauncher'"
            "class_g = 'Ulauncher'"

           #"class_g = 'iotas'"  # this is correct
          ];
          rounded-corners-exclude = [
            "window_type = 'dock'"
            "window_type = 'desktop'"
            "name = 'Notification'"
            "class_g = 'i3-frame'"
           #"class_g = 'rofi'"
           #"class_g = 'Rofi'"
           #"class_name = 'rofi'"
            "class_g = 'dunst'"
            "class_g = 'Dunst'"
           #"class_name = 'dunst'"
            "class_g = 'dockx'"
            "class_g = 'Dockx'"
          ];
          vsync = true;
          mark-wmwin-focused = true;
         #mark-ovredir-focused = true;
          detect-rounded-corners = true;
          detect-client-opacity = true;
          detect-transient = true;
         #use-damage = true;  # WARNING DEGRADES PERFORMANCE
          wintypes = {
            tooltip = {
              fade = true;
              shadow = false;
              opacity = 0.95;
              focus = true;
              full-shadow = false;
            };
            dock = {
              shadow = false;
              clip-shadow-above = true;
            };
            dnd = { shadow = false; };
           #popup_menu = { opacity = 1.0; };
           #dropdown_menu = { opacity = 1.0; };
          };


          fade-time = 300;  # Increase fade-time to 300ms for a more gradual fade-in
          fade-duration = 400;  # Slightly longer fade-duration for a smoother transition
          no-fading-openclose = true;  # Keep this to prevent fade during open/close transitions
          no-fading-destroyed-argb = true;

          glx-use-copysubbuffer-mesa = true;
         #glx-copy-from-front = true;
         #glx-swap-method = 2;
          xrender-sync = true;
          xrender-sync-fence = true;


        };

          # OG PICOM CONFIG
         extraConfig = ''
 animations = (
     {
         triggers = ["close", "hide"];
         opacity = {
             curve = "linear";
             duration = 0.2;  # Slightly longer duration for smoother opacity fade
             start = "window-raw-opacity-before";
             end = 0;
         };
         shadow-opacity = "opacity";
         scale-x = {
             curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
             duration = 0.4;  # Smoother zoom-out
             start = 1;  # Start at full size
             end = 0;  # Zoom out to 0
         };
         scale-y = "scale-x";
         shadow-scale-x = "scale-x";
         shadow-scale-y = "scale-y";

         # Adjust offsets to zoom from the center
         offset-x = "(1 - scale-x) / 2 * window-width";
         offset-y = "(1 - scale-y) / 2 * window-height";
         shadow-offset-x = "offset-x";
         shadow-offset-y = "offset-y";

         # Add blur effect during close
         blur = {
             curve = "linear";
             duration = 0.4;  # Smooth blur fade
             start = 0;
             end = 10;  # Max blur (you can adjust this value for stronger/weaker blur)
         };
     },
     {
         triggers = ["open", "show"];
         opacity = {
             curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
             duration = 0.15;  # Smoother fade-in with longer duration
             start = 0;
             end = "window-raw-opacity";
         };
         offset-x = "(1 - scale-x) / 2 * window-width";  # Start from center
         offset-y = "(1 - scale-y) / 2 * window-height";  # Start from center
         scale-x = {
             curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
             duration = 0.15;  # Slower zoom-in for smooth effect
             start = 0;  # Start very small
             end = 1;  # Zoom in to full size
         };
         scale-y = "scale-x";
         shadow-scale-x = "scale-x";
         shadow-scale-y = "scale-y";
         shadow-offset-x = "offset-x";
         shadow-offset-y = "offset-y";
     },
     {
         triggers = ["geometry", "position"];
         scale-x = {
             curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
             duration = 0.15;  # Smoother scaling
             start = "window-width-before / window-width";
             end = 1;
         };
         scale-y = {
             curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
             duration = 0.15;  # Smoother scaling
             start = "window-height-before / window-height";
             end = 1;
         };
         offset-x = {
             curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
             duration = 0.15;  # Smoother positioning
             start = "window-x-before - window-x";
             end = 0;
         };
         offset-y = {
             curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
             duration = 0.15;  # Smoother positioning
             start = "window-y-before - window-y";
             end = 0;
         };
         shadow-scale-x = "scale-x";
         shadow-scale-y = "scale-y";
         shadow-offset-x = "offset-x";
         shadow-offset-y = "offset-y";
     },
     {
         triggers = ["workspace-out"];
         offset-x = {
             duration = 0.15;
             timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
             start = "0";
             end = "-window-monitor-height";
         };
         shadow-offset-x = "offset-x";
         opacity = {
             duration = 0.15;
             timing = "0.15s linear";
             start = "window-raw-opacity-before";
             end = "window-raw-opacity-before";
         };
         blur-opacity = "opacity";
         shadow-opacity = "opacity";
     },
     {
         triggers = ["workspace-out-inverse"];
         offset-x = {
             duration = 0.15;
             timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
             start = "0";
             end = "window-monitor-height";
         };
         shadow-offset-x = "offset-x";
         opacity = {
             duration = 0.15;
             timing = "0.15s linear";
             start = "window-raw-opacity-before";
             end = "window-raw-opacity-before";
         };
         blur-opacity = "opacity";
         shadow-opacity = "opacity";
     },
     {
         triggers = ["workspace-in-inverse"];
         offset-x = {
             duration = 0.15;
             timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
             start = "-window-monitor-height";
             end = "0";
         };
         shadow-offset-x = "offset-x";
         opacity = {
             duration = 0.15;
             timing = "0.15s linear";
             start = "window-raw-opacity";
             end = "window-raw-opacity";
         };
         blur-opacity = "opacity";
         shadow-opacity = "opacity";
     },
     {
         triggers = ["workspace-in"];
         offset-x = {
             duration = 0.15;
             timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
             start = "window-monitor-height";
             end = "0";
         };
         shadow-offset-x = "offset-x";
         opacity = {
             duration = 0.15;
             timing = "0.15s linear";
             start = "window-raw-opacity";
             end = "window-raw-opacity";
         };
         blur-opacity = "opacity";
         shadow-opacity = "opacity";
     },
     {
        triggers = ["focus-change"];
        scale-x = {
            curve = "cubic-bezier(0.25,0.8,0.25,1)";
            duration = 0.2;
            start = 0.95;
            end = 1;
        };
        scale-y = "scale-x";
        opacity = {
            curve = "linear";
            duration = 0.2;
            start = 0.8;
            end = 1;
        };
     }

 )

 animation-exclude = [
   "class_g *= 'conky'",
   "class_g *= 'Conky'"
 ];
         '';

       #extraArgs = { };

      };

    };

  };

}
