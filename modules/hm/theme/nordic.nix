{ config, pkgs, lib, myStuff, ... }:

{

  gtk.enable = true;
  gtk.theme.package = pkgs.nordic;
  gtk.theme.name = "Nordic";
  gtk.iconTheme.package = pkgs.nordic;
  gtk.iconTheme.name = "Nordic-bluish";

  qt.enable = true;
  qt.platformTheme.name = "kde6";
  qt.style.name = "Nordic-bluish";
  qt.style.package = pkgs.nordic;

 #programs.kitty.themeFile = "Nord";
  programs.kitty.settings = {
  foreground = "#ABCFD4";
  background = "#353C4A";
  selection_foreground = "#FFFFFF";
  selection_background = "#331551";
  color0 = "#FFFFFF";
  color8 = "#171421";   #: black
  color1 = "#fa202f";
  color9 = "#C01C28";   #: red
  color2  = "#33D17A";
  color10 = "#26A269";  #: green
  color3  = "#E9AD0C";
  color11 = "#A2734C";  #: yellow
  color4  = "#2A7BDE";
  color12 = "#12488B";  #: blue
  color5  = "#C061CB";
  color13 = "#A347BA";  #: magenta
  color6  = "#33C7DE";
  color14 = "#2AA1B3";  #: cyan
  color7  = "#FFFFFF";
  color15 = "#D0CFCC";  #: white
  mark1_foreground = "black";    #: Color for marks of type 1
  mark1_background = "#31C5DE";  #: Color for marks of type 1 (light steel blue)
  mark2_foreground = "black";    #: Color for marks of type 2
  mark2_background = "#f2dcd3";  #: Color for marks of type 1 (beige)
  mark3_foreground = "black";    #: Color for marks of type 3
  mark3_background = "#f274bc";  #: Color for marks of type 3 (violet)
};

}
