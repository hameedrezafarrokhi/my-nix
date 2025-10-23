{ config, pkgs, lib, admin, mypkgs, ... }:

let

  proton-sarek-async = pkgs.callPackage ../../myPackages/sarek.nix { };

in

{ config = lib.mkIf (config.my.hardware.gpu == "nvidia-660m") {

  nixpkgs.config.nvidia.acceptLicense = true;

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;
   #extraModulePackages = [ config.boot.kernelPackages.nvidiaPackages.legacy_470 ];  # DOES NOTHING
    kernelModules = [   # HANDLED BY NIXOS AND NVIDIA OPTIONS
   #  "nvidia"
   #  "nvidia_modeset"
   # #"nvidia_uvm"
   #  "nvidia_drm"
   # #"nvidiafb"
   #  "i915"
    ];
    kernelParams = [   # HANDLED BY NIXOS AND NVIDIA OPTIONS
   #  "nvidia-drm.modeset=1"
     #"video=1366x768@60"
     #"fbcon=nodefer"
   #  "nvidia.NVreg_preserveVideoMemoryAllocations=1" # DO NOT USE UNLESS NEEDED (ONLY TRY TO USE IF FSYNC DOESNT WORK)
     #"module_blacklist=i915"                         # Causes Problem
    ];
    initrd.kernelModules = [
   #  "nvidia"           # WARNING CAUSES LONGER BOOT TIMES
      "i915"             # for Correct early resolution intel available: amdgpu, i915, nouveau, (nvidia nvidia_modeset nvidia_uvm nvidia_drm) all togheter for nvidia
   #  "nvidia_modeset"
   #  "nvidia_uvm"
   #  "nvidia_drm"
    ];
  };

  environment = {
   #variables = {};           # this is for system wide early boot services stuff

    sessionVariables = {      # this is for the session of the logged in user

     #GDK_BACKEND="x11";
      PROTON_DXVK_SAREK = 1;

      # WARNING WARNING WARNING UNSET ALL IF ISSUES SHOW UP ( MESA HAS DEFAULTS ANYWAYS )

      # VAAPI (nvidia is basically useless)
      LIBVA_DRIVER_NAME = "i965";     # "i965" "iHD" for intel, "nvidia" "nouveau" for nvidia, "radeonsi" for amd

      # VDPAU (nvidia is basically useless)
      VDPAU_DRIVER = "va_gl";          # "va_gl" fot intel, "radeonsi" for amd, "nouveau" "nvidia" for nvidia

      # VULKAN ( WARNING MAY BREAK APPS IN OLDER GPUs )
      ANV_DEBUG = "video-decode,video-encode";       # For intel
     #RADV_PERFTEST = "video_decode,video_encode";  # For AMD

      # VULKAN DEVICE FOR HYBRIDS ( to see available devices: MESA_VK_DEVICE_SELECT=list vulkaninfo )
      MESA_VK_DEVICE_SELECT = "10de:fd4";               # WARNING ONLY THIS DEVICE: 10de:fd4 for nvidia, 8086:166 for intel ( Using “vid:did!” will have the same effect as using the MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE variable )
     #MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE = 1;   # Forces the default

     #DRI_PRIME = 1;                    # For Prime Hybrid Laptops

    };
  };

  hardware = {

    nvidiaOptimus.disable = false;             # Completely disable and turn off nvidia GPU

    graphics = {
      enable = true;
     #package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
      extraPackages = with pkgs; [ # (Nvidia-utils handles vaapi/vdpau)

        # General Libs (not neede)
       #libva-vdpau-driver                    # Vdpau For Hybrid Nvidia
       #libva                                 # Vaapi/Vdpau libs
       #libvdpau                              # Vaapi/Vdpau libs

        # Nvidia VAAPI (useless)
       #nvidia-vaapi-driver                   # CUDA based Translation for VAAPI

        # Intel VAAPI
        (intel-vaapi-driver.override {        # Old intel
          enableHybridCodec = true; })
       #intel-media-driver                    # New intel

        # Intel VDPAU
        libvdpau-va-gl                        # VDPAU Driver with OpenGL/VAAPI Backend

        # Intel VPL
       #intel-compute-runtime
     #  libvpl
     #  vpl-gpu-rt
     #  intel-compute-runtime-legacy1
       #intel-media-sdk                       # WARNING BROKEN AND INSECURE AND LEGACY :)

        # Intel OCL
     #  intel-ocl                             # Intel OCL

        # General OCL # OpenCL:(Not Needed/Works with Nvidia-utils/CHOOSE_ONLY_ONE)
     #  ocl-icd                               #StandAlone OpenCL For All!
       #khronos-ocl-icd-loader                #Khronos StandAlone OpenCL For All!
       #pocl                                  #LLVM Based/Hardware Indipendent

       # Intel VULKAN ( NOT NEEDED, IN MESA )
       #vulkan-loader                        # LunarG Vulkan loader
       #vulkan-validation-layers             # Official Khronos Vulkan validation layers

      ] ++
      [
        mypkgs.stable.intel-media-sdk
      ];

      enable32Bit = true;
     #package32 = ;
      extraPackages32 = with pkgs.pkgsi686Linux; [
       #nvidia-vaapi-driver
       #libva-vdpau-driver
        intel-vaapi-driver                    # Intel CPU Graphics
        libvdpau-va-gl                        # Intel CPU Graphics
      ];
    };

    nvidia = {
     #enabled = lib.mkForce true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
      modesetting.enable = true;
      nvidiaPersistenced = true;            # ensures all GPUs stay awake even during headless mode
      open = false;                         # Turing and later, and driver 515.43.04+
      videoAcceleration = true;
      nvidiaSettings = true;
      dynamicBoost.enable = false;          # Balance CPU GPU powerManagement using nvidia-powerd daemon (>510)
      forceFullCompositionPipeline = false; # Not Usually Recommended (for screen tearing)
     #datacenter.enable = true;
      powerManagement = {
        enable = true;                     # Experimental,can cause sleep/suspend fail.Enable if graphical issues or crashes after sleep
        finegrained = false;                # Experimental,Turns off GPU when not in use. ONLY works on Turing or newer
      };

      prime = {                             # "sudo lshw -c display" to find PCI ID
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
       #amdgpuBusId = "PCI:54:0:0";         # For AMD GPU
        allowExternalGpu = true;            # Enable if using an external GPU

        sync.enable = false;                 # Sync is dGPU Always on and being used

        reverseSync = {
         enable = false;
         setupCommands.enable = true;       # Disable in order to configure the NVIDIA GPU outputs manually using xrandr
        };

        offload = {                         # Offload is iGPU default and dGPU usage with "offload" command
            enable = true;
            enableOffloadCmd = config.hardware.nvidia.prime.offload.enable;
            offloadCmdMainProgram = "nvidia-run";   # default: "nvidia-offload"
        };
      };
    };
    nvidia-container-toolkit = {
      enable = true;
      package = pkgs.nvidia-container-toolkit;
     #mounts = [ ]; # submodules
     #extraArgs = [ ];
     #csv-files = [ ];
      discovery-mode = "auto"; # one of "auto", "csv", "nvml", "wsl"
      suppressNvidiaDriverAssertion = false; # for wsl
      mount-nvidia-docker-1-directories = true;
      device-name-strategy = "index"; # one of "index", "uuid", "type-index"
    };
  };

 #specialisation.nvidia-offload.configuration = {
 # #system.nixos.label = "nvidia-offload";
 # #system.nixos.tags = [ "nvidia-offload" ];
 #  hardware.nvidia.prime = {
 #    nvidiaBusId = myStuff.mydGPUBusId;
 #    intelBusId = myStuff.myiGPUBusId;
 #    sync.enable = lib.mkForce false;
 #    offload = {
 #       enable = lib.mkForce true;
 #       enableOffloadCmd = true;
 #       offloadCmdMainProgram = "nvidia-offload";
 #    };
 #  };
 #};

  services = {

    xserver = {
      videoDrivers = [

        "nvidia"         # WARNING NVIDIA SHOULD PREFERABLY BE THE ONLY ONE
       #"i915"           # Adding i915 for intel wont break anything but not doing anything either!


       #"modesetting"    # WARNING DO NOT USE MODSETTING AND FBDEV WITH NVIDIA
       #"fbdev"

      ];  # Load NVIDIA driver for Xorg and Wayland
    };

    lact = {                        # OverClocking GUI App
      enable = true;
      package = pkgs.lact;
    };
    ollama = {
      acceleration = false;
    };
    switcherooControl = {
      package = pkgs.switcheroo-control;
      enable = true;
    };
  };

 #programs.steam.extraCompatPackages = [ proton-sarek-async ];
 #home-manager.users.${admin} = {
 #  programs.lutris.protonPackages = [ proton-sarek-async ];
 #  home.activation = {
 #    SarekLink = lib.hm.dag.entryAfter ["writeBoundary"] ''
 #      ln -sf ${proton-sarek-async.steamcompattool} "$HOME/.steam/steam/compatibilitytools.d"
 #    '';
 #  };
 #};

  environment.systemPackages = [

    (pkgs.writeShellScriptBin "no" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '')

  ];

};}

/*
  config.boot.kernelPackages.nvidiaPackages.stable;
  config.boot.kernelPackages.nvidiaPackages.latest;
  config.boot.kernelPackages.nvidiaPackages.beta;
  config.boot.kernelPackages.nvidiaPackages.production;  # (installs 550)
  config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
  config.boot.kernelPackages.nvidiaPackages.legacy_535;
  config.boot.kernelPackages.nvidiaPackages.legacy_470;
  config.boot.kernelPackages.nvidiaPackages.legacy_390;
  config.boot.kernelPackages.nvidiaPackages.legacy_340;

  # OR; Pair Nvidia Driver With Correct Package Kernel name
  pkgs-stable.linuxKernel.packages.linux_6_6.nvidia_x11_legacy470;
  pkgs.linuxKernel.packages.linux_6_14.nvidia_x11_legacy470;
  pkgs.linuxKernel.packages.linux_6_13.nvidia_x11_legacy470;
  pkgs.linuxKernel.packages.linux_6_12.nvidia_x11_legacy390;
  pkgs.linuxKernel.packages.linux_6_6.nvidia_x11_legacy535;
*/
