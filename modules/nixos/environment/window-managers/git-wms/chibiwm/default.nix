{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.chibiwm;
  chibiwm = pkgs.callPackage ./chibiwm.nix {
    conf = ''

// Mod1Mask - Alt
// Mod2Mask - Numlock
// Mod3Mask - Shift
// Mod4Mask - Super (aka win button)
// Mod5Mask - Shift
#define MODMASK Mod4Mask

#define BORDER_SIZE 4
#define BORDER_INACTIVE_COLOR 0x444444
#define BORDER_ACTIVE_COLOR 0x0077ff

#define BAR_SIZE 25
#define BAR_BACKGROUND_COLOR 0x222222
#define BAR_FONT "monospace:size=12"
#define BAR_FONT_SIZE 12 // should be the same as in the BAR_FONT
#define BAR_ACTIVE_WS_COLOR "#0077ff"
#define BAR_INACTIVE_WS_COLOR "#bbbbbb"

#define BAR_LAYOUT_COLOR "#dddddd"
#define BAR_STATUS_COLOR "#dddddd"

#define WORKSPACES 6

//example:			x("button", MaskForAdditionalButton or 0,		function in c)
#define TBL(x)  	x("c", 0, 			XKillClient(d, e.xkey.subwindow))	\
                  x("e", ShiftMask, 	running = false)					\
                	x("Return", ShiftMask, 			system("${config.my.default.terminal} &"))				\
                	x("space", 0, 			system("rofi -show drun -theme .config/rofi/themes/main.rasi &")) 		\
                	x("t", 0, 			toggle_layout(tiling))				\
                	x("f", 0, 			toggle_layout(floating))			\
                	x("Return", 0, 			toggle_layout(fullscreen))	 		\
                	x("Up", ShiftMask, 			tiling_change_master_size(0.05))	\
                	x("Down", ShiftMask, 			tiling_change_master_size(-0.05))	\
					x("1", 0, 			switch_ws(d, 0))					\
					x("2", 0, 			switch_ws(d, 1))					\
					x("3", 0, 			switch_ws(d, 2))					\
					x("4", 0, 			switch_ws(d, 3))					\
					x("5", 0, 			switch_ws(d, 4))					\
					x("6", 0, 			switch_ws(d, 5))					\
					x("1", ShiftMask, 	move_to_ws(d, e.xkey.subwindow, 0)) \
					x("2", ShiftMask, 	move_to_ws(d, e.xkey.subwindow, 1)) \
					x("3", ShiftMask, 	move_to_ws(d, e.xkey.subwindow, 2)) \
					x("4", ShiftMask, 	move_to_ws(d, e.xkey.subwindow, 3)) \
					x("5", ShiftMask, 	move_to_ws(d, e.xkey.subwindow, 4)) \
					x("6", ShiftMask, 	move_to_ws(d, e.xkey.subwindow, 5)) \


    '';
  };

in

{

  options = {
    services.xserver.windowManager.chibiwm = {
      enable = mkEnableOption "chibiwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before chibiwm is started.
        '';
      };
      package = mkPackageOption pkgs "chibiwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "chibiwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "chibiwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${chibiwm}/bin/chibiwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.chibiwm = {
      enable = true;
      extraSessionCommands = ''
        systemctl --user stop xremap.service
      '';
      package = chibiwm;
    };

  };

}
