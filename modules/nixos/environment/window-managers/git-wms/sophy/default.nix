{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.sophy;
  sophy = pkgs.callPackage ./sophy.nix {
    conf = ''
#define MOD Mod4Mask

char *terminal[] = {"${config.my.default.terminal}",  0};
char *clock[]	 = {"xclock", 0};
char *menu[]     = {"dmenu_run", 0};

struct KeyEvent keys[] = {
	{MOD, XK_Return, spawn, {.v = terminal}},
	{MOD, XK_t, spawn, 		{.v = clock}},
	{MOD, XK_d, spawn,		{.v = menu}},
	{MOD, XK_c, kill, 		{0}},
};
    '';
  };

in

{

  options = {
    services.xserver.windowManager.sophy = {
      enable = mkEnableOption "sophy";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before sophy is started.
        '';
      };
      package = mkPackageOption pkgs "sophy" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "sophy" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "sophy";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${sophy}/usr/local/bin/sophy &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.sophy = {
      enable = true;
      extraSessionCommands = '' '';
      package = sophy;
    };

  };

}
