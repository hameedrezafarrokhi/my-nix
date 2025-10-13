{ config, pkgs, lib, myStuff, ... }:

{

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    polarity = "dark";
    image = ./background.png;
  };
}
