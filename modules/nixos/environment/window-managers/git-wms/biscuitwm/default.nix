{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.biscuitwm;
  biscuitwm = pkgs.callPackage ./biscuitwm.nix {
    conf = ''
{
	"dev": {
		"debug": 1
	},
	"placement": {
		"auto_window_placement": 1,
		"auto_window_fit": 1,
		"auto_window_raise": 1,
		"center_window_placement": 1
	},
	"deskbar": {
		"enabled": 1,
		"background_color": "white",
		"foreground_color": "black",
		"clock": {
			"enabled": 1,
			"show_day": 1,
			"show_date": 1,
			"show_seconds": 0
		}
	},
	"xround": {
		"enabled": 1
	},
	"appearance": {
		"window_border_width": 4,
		"active_window_border_color": "red",
		"inactive_window_border_color": "lightgray",
		"background_color": "slategray"
	}
}
    '';
  };

in

{

  options = {
    services.xserver.windowManager.biscuitwm = {
      enable = mkEnableOption "biscuitwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before biscuitwm is started.
        '';
      };
      package = mkPackageOption pkgs "biscuitwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "biscuitwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "biscuitwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${biscuitwm}/bin/biscuitwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.biscuitwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = biscuitwm;
    };

  };

}
