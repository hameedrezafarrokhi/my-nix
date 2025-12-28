{ config, pkgs, lib,  ... }:

{ config = lib.mkIf (config.my.apps.mangohud.enable) {

  programs.mangohud = {
    enable = true;
    package = pkgs.mangohud;
    settings = {
     #legacy_layout=false;
      gpu_text = "GPU";
      gpu_stats = true;
      gpu_temp = true;
      gpu_load_change = true;
      cpu_text = "CPU";
      cpu_stats = true;
      cpu_temp = true;
      cpu_load_change = true;
      ram = true;
      fps = true;
      wine = true;
      winesync = true;
      frame_timing = true;
      arch = true;
      fps_limit_method = "early";
      toggle_fps_limit = "Shift_L+F1";
    };
   #enableSessionWide = true;
   #settingsPerApplication = {};
  };

};}
