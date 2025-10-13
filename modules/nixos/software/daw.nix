{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.software.daw.enable) {

  environment.systemPackages = with pkgs; [

    solfege                       ##Learn music
    timidity
   #tuxguitar                     ##Tableture app
   #gmetronome                    ##Metronome app
   #fretboard                     ##Learn the frets
   #hydrogen                      ##Drum machine
   #drum-machine                  ##Drum machine simple

   #reaper                        ##BEST Linux DAW
   #ardour                        ##Another DAW
   #bitwig-studio                 ##DAW (not-free)
    audacity                      ##Sound editing
    soundconverter                ##Audio converter

   #guitarix
   #gxplugins-lv2
   #rakarrack
   #yoshimi
   #musescore
   #muse-sounds-manager
   #sooperlooper
   #calf

  ];

};
}
