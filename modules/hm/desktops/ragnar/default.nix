{ config, pkgs, lib, nix-path, ... }:

let

  cfg = config.my.ragnar;

in

{

  options.my.ragnar.enable = lib.mkEnableOption "ragnar";

  config = lib.mkIf cfg.enable {

    home.packages = [ ];

    xdg.configFile = {

      "ragnarwm/ragnar.cfg".text = lib.mkAfter ''

# Options:
# ----------------------
# Modifiers:
#   - "Shift"
#   - "Control"
#   - "Alt"
#   - "Super"
# Mouse buttons:
#   - "LeftMouse"
#   - "MiddleMouse"
#   - "RightMouse"
# Layout types:
#   - "LayoutFloating"
#   - "LayoutTiledMaster"
#   - "LayoutVerticalStripes"
#   - "LayoutHorizontalStripes"
# Cursor images:
#   - "arrow"
#   - "based_arrow"
#   - "cross"
#   - "hand1"
#   - "hand2"
#   - "double_arrow"
#   - "top_left_arrow"
#   - "bottom_right_arrow"
#   - "left_ptr"
#   - "right_ptr"
#   - "xterm"
# Keycallback functions:
#   - terminate_successfully
#   - cyclefocusdown
#   - cyclefocusup
#   - killfocus
#   - togglefullscreen
#   - raisefocus
#   - cycledesktopup
#   - cycledesktopdown
#   - cyclefocusdesktopup
#   - cyclefocusdesktopdown
#   - switchdesktop
#   - switchfocusdesktop
#   - runcmd
#   - addfocustolayout
#   - settiledmaster
#   - setverticalstripes
#   - sethorizontalstripes
#   - setfloatingmode
#   - updatebarslayout
#   - cycledownlayout
#   - addmasterlayout
#   - removemasterlayout
#   - incmasterarealayout
#   - decmasterarealayout
#   - incgapsizelayout
#   - decgapsizelayout
#   - inclayoutsizefocus
#   - declayoutsizefocus
#   - movefocusup
#   - movefocusdown
#   - movefocusleft
#   - movefocusright
#   - cyclefocusmonitordown
#   - cyclefocusmonitorup
#   - togglescratchpad
#
# ----------------------
# NOTE: For all key options, see:
# https://github.com/cococry/ragnar/blob/main/src/structs.h#L89
# ----------------------
#

# Specifies whether or not to log messages
# to the console
log_messages = true;

# Specifies whether or not to log messages
# to the log file
should_log_to_file = true;

# Specifies the maximum number of scratchpads
# that can be allocated
max_scratchpads = 10;

# --------------------------------

# =========== Key bindings ===========

keybinds = (
  {
    mod = "Super";
    key = "KeyEscape";
    do = "terminate_successfully";
  },
  {
    mod = "%mod_key";
    key = "KeyTab";
    do = "cyclefocusdown";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyTab";
    do = "cyclefocusup";
  },
  {
    mod = "%mod_key";
    key = "KeyQ";
    do = "killfocus";
  },
  {
    mod = "%mod_key";
    key = "KeyF";
    do = "togglefullscreen";
  },
  {
    mod = "%mod_key";
    key = "KeyR";
    do = "raisefocus";
  },
  {
    mod = "%mod_key";
    key = "KeyR";
    do = "raisefocus";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyW";
    do = "movefocusup";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyA";
    do = "movefocusleft";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyS";
    do = "movefocusdown";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyD";
    do = "movefocusright";
  },
  {
    mod = "%mod_key";
    key = "KeyRight";
    do = "cyclefocusmonitorup";
  },
  {
    mod = "%mod_key";
    key = "KeyLeft";
    do = "cyclefocusmonitordown";
  },
  {
    mod = "%mod_key";
    key = "KeyD";
    do = "cycledesktopup";
  },
  {
    mod = "%mod_key";
    key = "KeyA";
    do = "cycledesktopdown";
  },
  {
    mod = "%mod_key";
    key = "KeyP";
    do = "cyclefocusdesktopup";
  },
  {
    mod = "%mod_key";
    key = "KeyO";
    do = "cyclefocusdesktopdown";
  },
  {
    mod = "%mod_key";
    key = "Key1";
    do = "switchdesktop";
    i = 0;
  },
  {
    mod = "%mod_key";
    key = "Key2";
    do = "switchdesktop";
    i = 1;
  },
  {
    mod = "%mod_key";
    key = "Key3";
    do = "switchdesktop";
    i = 2;
  },
  {
    mod = "%mod_key";
    key = "Key4";
    do = "switchdesktop";
    i = 3;
  },
  {
    mod = "%mod_key";
    key = "Key5";
    do = "switchdesktop";
    i = 4;
  },
  {
    mod = "%mod_key";
    key = "Key6";
    do = "switchdesktop";
    i = 5;
  },
  {
    mod = "%mod_key";
    key = "Key7";
    do = "switchdesktop";
    i = 6;
  },
  {
    mod = "%mod_key";
    key = "Key8";
    do = "switchdesktop";
    i = 7;
  },
  {
    mod = "%mod_key";
    key = "Key9";
    do = "switchdesktop";
    i = 8;
  },
  {
    mod = "%mod_key | Shift";
    key = "Key1";
    do = "switchfocusdesktop";
    i = 0;
  },
  {
    mod = "%mod_key | Shift";
    key = "Key2";
    do = "switchfocusdesktop";
    i = 1;
  },
  {
    mod = "%mod_key | Shift";
    key = "Key3";
    do = "switchfocusdesktop";
    i = 2;
  },
  {
    mod = "%mod_key | Shift";
    key = "Key4";
    do = "switchfocusdesktop";
    i = 3;
  },
  {
    mod = "%mod_key | Shift";
    key = "Key5";
    do = "switchfocusdesktop";
    i = 4;
  },
  {
    mod = "%mod_key | Shift";
    key = "Key6";
    do = "switchfocusdesktop";
    i = 5;
  },
  {
    mod = "%mod_key | Shift";
    key = "Key7";
    do = "switchfocusdesktop";
    i = 6;
  },
  {
    mod = "%mod_key | Shift";
    key = "Key8";
    do = "switchfocusdesktop";
    i = 7;
  },
  {
    mod = "%mod_key | Shift";
    key = "Key9";
    do = "switchfocusdesktop";
    i = 8;
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyT";
    do = "settiledmaster";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyR";
    do = "setfloatingmode";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyH";
    do = "sethorizontalstripes";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyV";
    do = "setverticalstripes";
  },
  {
    mod = "%mod_key";
    key = "KeySpace";
    do = "addfocustolayout";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyB";
    do = "updatebarslayout";
  },
  {
    mod = "%mod_key";
    key = "KeyJ";
    do = "cycledownlayout";
  },
  {
    mod = "%mod_key";
    key = "KeyK";
    do = "cycleuplayout";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyJ";
    do = "inclayoutsizefocus";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyK";
    do = "declayoutsizefocus";
  },
  {
    mod = "%mod_key";
    key = "KeyM";
    do = "addmasterlayout";
  },
  {
    mod = "%mod_key | Shift";
    key = "KeyM";
    do = "removemasterlayout";
  },
  {
    mod = "%mod_key";
    key = "KeyH";
    do = "decmasterarealayout";
  },
  {
    mod = "%mod_key";
    key = "KeyL";
    do = "incmasterarealayout";
  },
  {
    mod = "%mod_key";
    key = "KeyMinus";
    do = "decgapsizelayout";
  },
  {
    mod = "%mod_key";
    key = "KeyPlus";
    do = "incgapsizelayout";
  },
  {
    mod = "%mod_key";
    key = "KeyReturn";
    do = "runcmd";
    cmd = "alacritty &";
  },
  {
    mod = "%mod_key";
    key = "KeyS";
    do = "runcmd";
    cmd = "dmenu &";
  },
  {
    mod = "%mod_key";
    key = "KeyW";
    do = "runcmd";
    cmd = "firefox &";
  },
  {
    mod = "%mod_key";
    key = "KeyE";
    do = "runcmd";
    cmd = "flameshot gui &";
  },
  {
    mod = "%mod_key";
    key = "KeyF1";
    do = "togglescratchpad";
    cmd = "alacritty &";
    i = 0;
  },
  {
    mod = "%mod_key";
    key = "KeyF2";
    do = "togglescratchpad";
    cmd = "alacritty -e nvim &";
    i = 1;
  },
  {
    mod = "%mod_key";
    key = "KeyF3";
    do = "togglescratchpad";
    cmd = "alacritty -e mocp &";
    i = 2;
  },
  {
    mod = "%mod_key";
    key = "KeyC";
    do = "reloadconfigfile";
  },
  {
    mod = "%mod_key";
    key = "KeyAudioLowerVolume";
    do  = "runcmd";
    cmd = "amixer sset Master 5%-";
  },
  {
    mod = "%mod_key";
    key = "KeyAudioRaiseVolume";
    do  = "runcmd";
    cmd = "amixer sset Master 5%+";
  },
  {
    mod = "%mod_key";
    key = "KeyAudioMute";
    do  = "runcmd";
    cmd = "amixer sset Master toggle";
  }
);
      '';

    };


  };

}
