{ config, pkgs, lib, nix-path, nix-path-alt, self, ... }:

let

  appletrcPath = toString ./plasma-org.kde.plasma.desktop-appletsrc;

in

{ config = lib.mkIf (config.my.kde.appletrc == "nirvana") {

 #xdg.configFile = {
 #
 #  "plasma-org.kde.plasma.desktop-appletsrc" = {
 #    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/hm/desktops/kde/appletrc/plasma-org.kde.plasma.desktop-appletsrc";
 #   #force = true;
 #   #target = "./plasma-org.kde.plasma.desktop-appletsrc";
 #  };
 #
 #};


  home.activation = {

   #PlasmaAppletsrc = lib.hm.dag.entryAfter ["writeBoundary"] ''
   #  cp -f ${appletrcPath} "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
   #  chmod 644 "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
   #  chown "$(id u):$(id -g)" "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
   #'';

    PlasmaAppletsrc = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ln -sf "${nix-path}/modules/hm/desktops/kde/appletrc/plasma-org.kde.plasma.desktop-appletsrc" "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    '';

  };

};}
