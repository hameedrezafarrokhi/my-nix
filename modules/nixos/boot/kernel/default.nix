{ config, pkgs, lib, mypkgs, ... }:

{

  options.my.boot.kernel = lib.mkOption {

     type = lib.types.attrs;
     default = pkgs.linuxPackages;

  };

  config = {

    boot.kernelParams = [
      "quiet"
      "udev.log_level=3" "udev.log_priority=3" "rd.udev.log_level" "rd.systemd.show_status=false"
      "vga=current"
     #"splash"
    ];

    # Kernels

    boot.kernelPackages = config.my.boot.kernel;
   #boot.kernelPackages = pkgs."linuxPackages_${myStuff.myKernel}";
   #boot.kernelPackages = pkgs.linuxPackages;                             #Currently 6.12
   #boot.kernelPackages = pkgs.linuxPackages_latest;                      #Currently 6.15
   #boot.kernelPackages = pkgs.linuxPackages_testing;                     #Currently 6.16-rc

   # _testing_hardened; _6_15; _6_14; _6_13; _6_12; _6_12_hardened; _6_6; _6_6_hardened; _6_1; _6_1_hardened; _5_15; _5_15_hardened; _lqx; _xanmod; _xanmod_latest; _xanmod_stable; _custom; _zen; -libre; _latest-libre; -rt; -rt_latest; _custom_tinyconfig_kernel; _hardened; _latest_hardened; _xen_dom0; _latest_xen_dom0; _xen_dom0_hardened; _latest_xen_dom0_hardened;
   # _cachyos-hardened; _cachyos-lto; _cachyos-rc; _cachyos-server;

  ######################################################   FINDING_KERNELS

    # Search Term For Kernels:
     # linuxKernel.kernels.linux_<name>
     #                     OR
     # linuxKernel.kernels.linux-<name>

    # nix repl
     # (in the shell run below to add database)
     # :l <nixpkgs>
     # (press tab instead of enter after typing below)

    # pkgs.linuxPackages
    # pkgs.linuxPackages_
    # pkgs.linuxPackages-

    # Example:
     # pkgs.linuxKernel.kernels.linux_6_12   ---->   pkgs.linuxPackages_6_12
     # pkgs.linuxKernel.kernels.linux_lqx    ---->   pkgs.linuxPackages_lqx

};}
