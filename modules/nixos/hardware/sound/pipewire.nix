{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.hardware.sound == "pipewire") {

  # pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    raopOpenFirewall = true;
   #systemWide = false;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
   #media-session.enable = true;  # use the example session manager (no others are packaged yet so this is enabled by default
                                  #no need to redefine it in your config for now)
  };

  # pulseaudio
  services.pulseaudio = {
    enable = false;
    support32Bit = false;
  };

};}
