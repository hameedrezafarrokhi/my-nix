{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.gaming.emulators.enable) {

  environment.systemPackages = with pkgs; [

   #ppsspp                        ##Emulator for psp  # has overrides
   #ppsspp-sdl-wayland
   #ppsspp-sdl
   #ppsspp-qt
   #dolphin-emu                   ##Emulator for wii
   #dolphin-emu-primehack
   #mupen64plus                   ##Emulator for N64
   #rmg                           ##Rosalie's Mupen GUI
   #rmg-wayland

    # APPIMAGE Preferred
   #ryujinx                       ##Emulator for yuzu
   #shadps4                       ##Emulator for ps4
   #melonDS                       ##Emulator for ds
   #retroarch                     ##Emulator for RetroStuff
   #retroarch-full                 ##Emulator for RetroStuff full
   #flycast                       ##Emulator for dreamcast
   #ryubing
   #snes9x
   #snes9x-gtk
   #suyu
   #duckstation                   ##Emulator for ps1
   #pcsx2                         ##Emulator for ps2
   #rpcs3                         ##Emulator for ps3
   #cemu                          ##Emulator for wiiu
   #xemu                          ##Emulator for xbox1
   #lime3ds                       ##Emulator for 3ds
   #torzu

  ];

};}
