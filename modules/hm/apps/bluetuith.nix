{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.bluetuith.enable) {

  programs.bluetuith = {
    enable = true;
    package = pkgs.bluetuith;
    settings = {
   #  adapter = "hci0";
      receive-dir = "${config.home.homeDirectory}/Downloads";

      keybindings = {
        Menu = "Alt+m";
      };

   #  theme = {
   #    Adapter = "red";
   #  };
    };
  };

  home.packages = [

    (pkgs.writeShellScriptBin "bluetuith-gui" ''${config.my.default.terminal} --name bluetuith --class bluetuith sh -c 'bluetuith' '')

  ];

};}
