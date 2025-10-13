{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.software.productivity.enable) {

  environment.systemPackages = with pkgs; [

   #krita                         ##Drawing app
   #drawing                       ##Drawing app
   #pinta                         ##Drawing app
   #gimp                          ##Image manipulation
   #gimp3-with-plugins                                  # figure out plugins
   #upscayl                       ##Image upscale
   #upscaler                      ##Image upscale
   #inkscape                      ##SVG vector
    inkscape-with-extensions                            # figure out extensions
   #dia                           ##Diagram app
   #blender
   #blender-hip
   #darktable                     ##Raw Image Editor

   #obs-studio                    ##Screen recorde      # figure out plugins
    kdePackages.kdenlive          ##Video editor (KDE)
   #footage                       ##Video editor (crop)
   #davinci-resolve               ##Video editor
   #shotcut                       ##Video editor
   #openshot-qt                   ##Video editor (qt/kde)
   #flowblade                     ##Video editor
   #pitivi                        ##Video editor
   #video2x                       ##Video upscaler

    letterpress                   ##ACSII creator
    ascii-draw                    ##ACSII creator
    calligraphy                   ##ACSII creator

   #zotero                        ##Research indexes
   #minder                        ##Create Plans
   #planify                       ##Create Plans

  ];

};
}
