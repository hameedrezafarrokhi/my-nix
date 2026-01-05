{ config, pkgs, lib, inputs, ... }:

let

  cfg = config.my.awesome;

in

{

  options.my.awesome.enable = lib.mkEnableOption "awesome";

  config = lib.mkIf cfg.enable {

    xsession.windowManager.awesome = {

      enable = true;
      package = pkgs.awesome;
      luaModules = [ pkgs.luaPackages.vicious pkgs.luaPackages.awesome-wm-widgets ];
      noArgb = false;

    };

    xdg.configFile = {

      awesome-rc = {
        target = "awesome/rc.lua";
        source = ./awesome/rc.lua;
      };
      awesome-autostart = {
        target = "awesome/modules/autostart.lua";
        source = ./awesome/modules/autostart.lua;
      };
      awesome-error_handling = {
        target = "awesome/modules/error_handling.lua";
        source = ./awesome/modules/error_handling.lua;
      };
      awesome-libraries = {
        target = "awesome/modules/libraries.lua";
        source = ./awesome/modules/libraries.lua;
      };
      awesome-menu = {
        target = "awesome/modules/menu.lua";
        source = ./awesome/modules/menu.lua;
      };
      awesome-notifications = {
        target = "awesome/modules/notifications.lua";
        source = ./awesome/modules/notifications.lua;
      };
      awesome-scratchpad = {
        target = "awesome/modules/scratchpad.lua";
        source = ./awesome/modules/scratchpad.lua;
      };
      awesome-screens = {
        target = "awesome/modules/screens.lua";
        source = ./awesome/modules/screens.lua;
      };
      awesome-theme-default = {
        target = "awesome/modules/theme.lua";
        source = ./awesome/modules/theme.lua;
      };
      awesome-theme = lib.mkDefault {
        target = "awesome/themes/default/theme.lua";
        source = ./awesome/themes.backup/default/theme.lua;
      };
      awesome-variables = {
        target = "awesome/modules/variables.lua";
        source = ./awesome/modules/variables.lua;
      };
      awesome-mousebindings = {
        target = "awesome/modules/mousebindings.lua";
        source = ./awesome/modules/mousebindings.lua;
      };
      awesome-layouts = {
        target = "awesome/modules/layouts.lua";
        source = ./awesome/modules/layouts.lua;
      };
      awesome-rules = {
        target = "awesome/modules/rules.lua";
        source = ./awesome/modules/rules.lua;
      };
      awesome-signals = {
        target = "awesome/modules/signals.lua";
        source = ./awesome/modules/signals.lua;
      };
      awesome-widgets = {
        target = "awesome/modules/widgets.lua";
        source = ./awesome/modules/widgets.lua;
      };
      awesome-wibar = {
        target = "awesome/modules/wibar.lua";
        source = ./awesome/modules/wibar.lua;
      };
      awesome-keybindings = {
        target = "awesome/modules/keybindings.lua";
        source = ./awesome/modules/keybindings.lua;
      };
      awesome-changevolume = {
        target = "awesome/scripts/changevolume";
        source = ./awesome/scripts/changevolume;
      };
      awesome-redshift-off = {
        target = "awesome/scripts/redshift-off";
        source = ./awesome/scripts/redshift-off;
      };
      awesome-redshift-on = {
        target = "awesome/scripts/redshift-on";
        source = ./awesome/scripts/redshift-on;
      };
      awesome-autorun = {
        target = "awesome/scripts/autorun.sh";
        source = ./awesome/scripts/autorun.sh;
      };
      awesome-power = {
        target = "awesome/scripts/power";
        source = ./awesome/scripts/power;
      };
      awesome-help = {
        target = "awesome/scripts/help";
        source = ./awesome/scripts/help;
      };
      awesome-rofi-config = {
        target = "awesome/rofi/config.rasi";
        source = ./awesome/rofi/config.rasi;
      };
      awesome-rofi-power = {
        target = "awesome/rofi/power.rasi";
        source = ./awesome/rofi/power.rasi;
      };

    };

  };

}
