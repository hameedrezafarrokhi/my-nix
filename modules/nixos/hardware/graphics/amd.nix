{ config, pkgs, lib, ... }:

{
config = lib.mkIf (config.my.hardware.gpu == "amd") {

  boot = {
    initrd = {
     #kernelModules = [ "amdgpu" ];  # NOT NEEDED NORMALLY
    };
  };

  hardware = {
    graphics = {
      enable = true;      # Enable OpenGL
     #package = ;
      extraPackages = with pkgs; [ # (Nothing Really Needed except OpenCL)
        # OpenCL: (Not Needed/Works with Mesa/ONLY_CHOOSE_ONE)
     # #rocmPackages.clr                     #Supporting 7000 series and up
     #  ocl-icd                              #StandAlone OpenCL For All!
     # #(OR) khronos-ocl-icd-loader          #Khronos StandAlone OpenCL For All!
     # #pocl                                 #LLVM Based/Hardware Indipendent

     #  libtorch-bin                         # PyTorch Machine Learning (REAL VIDEO ENHANCER NEEDS IT)
     #  amdvlk                               # AMD Proriotery(INFERIOR)
     #  libva                                # Vaapi/Vdpau libs(NOT NEEDED):
     #  libvdpau                             # Vaapi/Vdpau libs(NOT NEEDED):

     #  vulkan-loader                        # LunarG Vulkan loader
     #  vulkan-validation-layers             # Official Khronos Vulkan validation layers
      ];
      enable32Bit = true;
     #package32 = ;
     #extraPackages32 = with pkgs.pkgsi686Linux; [  ];
    };

    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
     #amdvlk = {
     #  enable = true;
     #  package = pkgs.amdvlk;
     #  support32Bit.enable = true;
     #  support32Bit.package = pkgs.driversi686Linux.amdvlk;
     #  settings = {};
     #  supportExperimental.enable = true;
     #};
      overdrive = {      # OverClocking
        enable = true;
       #ppfeaturemask = "0xfffd7fff";
      };
    };
  };

  services = {
    xserver = {
      videoDrivers = [ "amdgpu" ];    # Load AMD driver for Xorg and Wayland
    };
    lact = {                          # OverClocking GUI App
      enable = true;
      package = pkgs.lact;
    };
    ollama = {
     #rocmOverrideGfx = "";
      acceleration = "rocm";
    };
  };

  environment = {
    variables = {};           # this is for system wide early boot services stuff
    sessionVariables = {      # this is for the session of the logged in user
     #"GDK_BACKEND" = "x11";
     #GDK_BACKEND="x11";
     #LIBVA_DRIVER_NAME = "radeonsi";
     #VDPAU_DRIVER = "radeonsi";
     #VDPAU_DRIVER_NAME = "radeonsi";
    };
  };

};
}


