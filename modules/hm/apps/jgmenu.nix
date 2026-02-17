{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.jgmenu.enable) {

  home.packages = [
    pkgs.jgmenu
  ];

  xdg.configFile = {

    jgmenu-prepend = {
      target = "jgmenu/prepend.csv";
      text = ''
        Terminal,${config.my.default.terminal},utilities-terminal
        Browser,${config.my.default.browser-alt-name},${config.my.default.browser-alt-name}
        File manager,${config.my.default.file-alt},system-file-manager
        ^sep()
      '';
    };

    jgmenu-append = {
      target = "jgmenu/append.csv";
      text = ''
        ^sep()
        Lock,x-lock
        Exit,^checkout(exit),system-shutdown
        ^tag(exit)
        Suspend,systemctl -i suspend,system-log-out
        Reboot,systemctl -i reboot,system-reboot
        Poweroff,systemctl -i poweroff,system-shutdown
      '';
    };

    jgmenu-startup = {
      target = "jgmenu/startup";
      text = ''
        ${builtins.readFile ./jgmenu-startup}
      '';
    };

    jgmenu-hooks = {
      target = "jgmenu/hooks";
      text = ''
        ~/.config/gtk-3.0/settings.ini,jgmenu_run gtktheme
      '';
    };

  };

};}
