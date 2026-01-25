{ config, pkgs, lib, admin, mypkgs, ... }:

{ config = lib.mkIf (config.my.gaming.steam.enable) {

  environment.systemPackages = with pkgs; [
   #proton-ge-bin
  ];

 #nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem [
 #  "steam"
 #  "steam-original"
 #  "steam-unwrapped"
 #  "steam-run"
 #];

  programs.steam = {
    enable = true;
    package = mypkgs.fallback.steam;
    remotePlay.openFirewall = true;                       # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true;                  # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true;        # Open ports in the firewall for Steam Local Network Game Transfers

    extraCompatPackages = with pkgs; [
   #  proton-ge-bin   # WARNING Removed?
   #  proton-cachyos  # WARNING Removed?
     #proton-ge-custom
    ];
    protontricks = {
      enable = true;
     #package = pkgs.protontricks;
    };

    extest.enable = true;                                 # Translate X11 input (e.g. for using Steam Input on Wayland)

    gamescopeSession = {
      enable = true;
     #args = [  ];
     #steamArgs = [  ];
     #env = {  };
    };

    extraPackages = with pkgs; [
     #gamescope
    ];

   #fontPackages = with pkgs; [ source-han-sans ];
  };

  programs.gamescope = {
    enable = lib.mkDefault true;
   #capSysNice = true;
    env = {
     #XDG_RUNTIME_DIR = "/run/user/1001";
     #WAYLAND_DISPLAY = "wayland-1";
     #DISPLAY = ":0";
     #__NV_PRIME_RENDER_OFFLOAD = "1";
     #__VK_LAYER_NV_optimus = "NVIDIA_only";
     #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
   #args = [  ];
  };
 #security.wrappers.gamescope.capabilities = lib.mkForce "cap_sys_nice,cap_sys_admin+ep"; # cap_sys_nice,cap_sys_admin+ep # cap_sys_nice+pie # cap_sys_nice,cap_sys_admin+pie

  programs.gamemode = {          # Command For Gamemode In Steam: gamemoderun %command%
    enable = true;               # OR Run This In Terminal; gamemoderun steam
    enableRenice = true;
   #settings = {
   #  general = {
   #    renice = 10;
   #  };
   #};
  };

 #programs.opengamepadui = {
 #
 #
 #};

  hardware.steam-hardware.enable = true;

  environment.sessionVariables = {
   #STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/steam/compatibilitytools.d";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.local/share/Steam/compatibilitytools.d";
  };

 #home-manager.users.${admin} = {
 #  home.activation = {
 #    CachyLink = lib.hm.dag.entryAfter ["writeBoundary"] ''
 #      rm -rf "$HOME/.steam/steam/compatibilitytools.d/proton-cachy-ln"
 #      mkdir -p "$HOME/.steam/steam/compatibilitytools.d/proton-cachy-ln"
 #      ln -sf ${pkgs.proton-cachyos}/bin/* "$HOME/.steam/steam/compatibilitytools.d/proton-cachy-ln"
 #    '';
 #    GE-CustomLink = lib.hm.dag.entryAfter ["writeBoundary"] ''
 #      rm -rf "$HOME/.steam/steam/compatibilitytools.d/proton-ge-custom-ln"
 #      mkdir -p "$HOME/.steam/steam/compatibilitytools.d/proton-ge-custom-ln"
 #      ln -sf ${pkgs.proton-ge-custom}/bin/* "$HOME/.steam/steam/compatibilitytools.d/proton-ge-custom-ln"
 #    '';
 #  };
 #};

  # Below Is An Example; DO NOT USE Without Changing It First
  # (Not Recommended Using At All)
  # (Use Steam Commands Inside Steam Itself Instead)
# pkgs.steam.override {
#   extraEnv = {
#     MANGOHUD = true;
#     OBS_VKCAPTURE = true;
#     RADV_TEX_ANISO = 16;
#   };
#   extraLibraries = p: with p; [
#     atk
#   ];
# };

};}
