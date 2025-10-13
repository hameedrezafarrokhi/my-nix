{ config, pkgs, lib, myStuff, ... }:

{

  stylix = {
    enable = true;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    polarity = "dark";
    image = ./background.png;

    iconTheme = {
      enable = true;
      package = pkgs.catppuccin-papirus-folders;
      dark = "Papirus-Dark";
    };

    fonts.sizes.desktop = 10;
    fonts.sizes.applications = 12;
    fonts.sizes.popups = 10;

  };

  #qt.enable=true;
  #qt.platformTheme.name= lib.mkForce  "kde6";

}
