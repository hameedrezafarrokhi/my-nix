{ config, pkgs, lib, admin, ... }:

let

  cfg = config.my.hardware.libinput;

in

{

  options.my.hardware.libinput.enable = lib.mkEnableOption "enable mouse and touchpad support";

  config = lib.mkIf cfg.enable {

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput = {
      enable = true;
     #mouse = {};    # same config goes for both
     #touchpad = {
     #  transformationMatrix = null; # example "0.5 0 0 0 0.8 0.1 0 0 1"
     #  calibrationMatrix = null; # example "0.5 0 0 0 0.8 0.1 0 0 1"
     #  buttonMapping = null; # example "1 6 3 4 5 0 7" (maps to 1 2 3 4 5 6 7... of the device)
     #  tappingDragLock = true;
     #  tappingButtonMap = null; # one of "lrm", "lmr" (left midlle right)
     #  tapping = true;
     #  sendEventsMode = "enabled"; # one of "disabled", "enabled", "disabled-on-external-mouse"
     #  scrollMethod = "twofinger"; # one of "twofinger", "edge", "button", "none"
     #  scrollButton = null; # Designates a button as scroll button. If the ScrollMethod is button
     #  naturalScrolling = false;
     #  middleEmulation = true; # pressing the left and right buttons simultaneously
     #  leftHanded = false;
     #  horizontalScrolling = true;
     #  disableWhileTyping = false;
     #  dev = null;
     #  clickMethod = null; # one of "none", "buttonareas", "clickfinger"
     # #additionalOptions = '' ''; # example: Option "DragLockButtons" "L1 B1 L2 B2"
     #  accelProfile = "adaptive"; # one of "flat", "adaptive", "custom" (custome uses settings from below)
     #  accelSpeed = null; # string. example: "-0.5"
     #  accelStepScroll = null; # signed integer or floating point number
     #  accelStepMotion = null;
     #  accelStepFallback = null;
     #  accelPointsScroll = null;
     #  accelPointsMotion = null;
     #  accelPointsFallback = null;
     #};
    };

    services.ratbagd = {
      enable = false;
      package = pkgs.libratbag;
    };

    hardware.uinput.enable = true;
    users.groups.uinput.members = [ admin ];
    users.groups.input.members = [ admin ];

  };

}
