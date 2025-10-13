{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.boot.bootloader == "limine") {

  environment.systemPackages = [
   pkgs.efibootmgr                    #Necessary for Modify EFI Bootloader/Order
  ];

  boot = {
    consoleLogLevel = 1; # default is 4; anything lower would be displayed
    initrd = {
      verbose = false;
      allowMissingModules = true;
    };

    loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";

      limine = {
        enable = true;
        package = pkgs.limine;
        maxGenerations = 6;
       #efiSupport = pkgs.stdenv.hostPlatform.isEfi;
        efiSupport = true;
       #biosSupport = !config.boot.loader.limine.efiSupport && pkgs.stdenv.hostPlatform.isx86;
        biosSupport = false;
        forceMbr = false;
        biosDevice = "nodev";
       #partitionIndex = null;
        enableEditor = true;
        validateChecksums = true;
        panicOnChecksumMismatch = true;
        enrollConfig = config.boot.loader.limine.panicOnChecksumMismatch;
       #extraConfig = '' '';
       #efiInstallAsRemovable = !config.boot.loader.efi.canTouchEfiVariables;
        efiInstallAsRemovable = false;
        secureBoot = {
          enable = false;           #WARNING Needs Some Other Stuff (check option)
          sbctl = pkgs.sbctl;
        };
       #extraEntries = ''
       #  /memtest86
       #  protocol: chainload
       #  path: boot():///efi/memtest86/memtest86.efi
       #'';
       #style = {
       #  wallpapers
       #  wallpaperStyle = "centered", "streched", "tiled";
       #  interface = {
       #    resolution
       #    brandingColor
       #    branding
       #  };
       #  graphicalTerminal = {
       #    palette
       #    marginGradient
       #    margin
       #    foreground
       #    font.spacing
       #    font.scale
       #    brightPalette
       #    brightForeground
       #    brightBackground
       #    background
       #  };
       #  backdrop
       #};
      };
    };
  };
                                     #########################  WARNING  #########################

  # AFTER BOOTLOADER CHANGE RUN THESE COMMANDS
    # tldr efibootmgr

    # efibootmgr (Aquire Previous Nixos EFI Boot Number to Delete)
    # sudo efibootmgr -b 0000 --delete-bootnum (WARNING Change 0000 to Boot Number Aquired)
    # sudo nixos-rebuild --install-bootloader boot
    # sudo nixos-rebuild switch

};}
