{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.dael;
  dael = pkgs.callPackage ./dael.nix {
    conf = ''
/*
 * Colors are standard hex color codes, prefixed by '0x'
 */
#define BORDER_SIZE 1
#define BORDER_FOCUSED 0xff0000
#define BORDER_UNFOCUSED 0x043764

/*
 * The MODKEY is the modifier key used for keybinds.
 * Mod1Mask = Alt
 * Mod4Mask = Super/Windows Key
 */
#define MODKEY Mod4Mask

/*
 * The amount by which the master window gets resized when calling
 * increase_size or decrease_size
 * This is a percentage of the screen width.
 */
#define SIZE_INCREMENT 5

/* default master window size when on a new workspace */
#define MASTER_DEFAULT 50

#define MASTER_MAX 90 /* maximum master window size % */
#define MASTER_MIN 50 /* minimum master window size % */

static const Dael_Keybinding config_keys[] = {
/* Modifier------------Keycode-----------function----------args---------*/
 { MODKEY,             XK_d,             launch_program,   "dmenu_run" },
 { MODKEY,             XK_Return,        launch_program,   "st"        },
 { MODKEY | ShiftMask, XK_q,             kill_window                   },
 { MODKEY | ShiftMask, XK_e,             quit                          },
 { MODKEY | ShiftMask, XK_l,             next_workspace                },
 { MODKEY | ShiftMask, XK_h,             prev_workspace                },
 { MODKEY | ShiftMask, XK_w,             append_workspace              },
 { MODKEY,             XK_m,             cycle_tiling_mode             },
 { MODKEY,             XK_l,             focus_next                    },
 { MODKEY,             XK_h,             focus_prev                    },
 { MODKEY,             XK_space,         swap_master                   },
 { MODKEY,             XK_bracketright,  increase_size                 },
 { MODKEY,             XK_bracketleft,   decrease_size                 },



{ NoSymbol, 0, 0, 0 } /* end of keybind list (Do not remove) */
};
    '';
  };

in

{

  options = {
    services.xserver.windowManager.dael = {
      enable = mkEnableOption "dael";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before dael is started.
        '';
      };
      package = mkPackageOption pkgs "dael" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "dael" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "dael";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${dael}/bin/dael &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.dael = {
      enable = true;
      extraSessionCommands = '' '';
      package = dael;
    };

  };

}
