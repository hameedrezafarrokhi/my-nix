{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.boot.bootloader == "systemd-boot") {

  environment.systemPackages = [
   pkgs.efibootmgr
  ];

  boot = {
    consoleLogLevel = 1; # default is 4; anything lower would be displayed
    initrd = {
      verbose = false;
      allowMissingModules = true;
    };

    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        editor = true; # RECOMMENDED TO SET FALSE!
        configurationLimit = 6;
        consoleMode = "max";
       #editor = false;
        sortKey = "nixos";
       #windows = {
       #  "11-pc" = {
       #    title = "Windows 11 PC";
       #    efiDeviceHandle = "HD0b1";
       #    sortKey = "attribute name of this entry, prefixed with \"o_windows_\"";
       #  };
       #};
        edk2-uefi-shell = {
          enable = true;
          sortKey = "o_edk2-uefi-shell";
        };
        memtest86 = {
          enable = true;
          sortKey = "o_memtest86";
        };
       #extraEntries = {
       #  "memtest86.conf" = ''
       #     title Memtest86+
       #     efi /efi/memtest86/memtest.efi
       #     sort-key z_memtest
       #   '';
       #};

       #extraInstallCommands = "";
       #extraFiles = {
       #  "efi/memtest86/memtest.efi" = "${pkgs.memtest86plus}/memtest.efi";
       #};
      };
    };
  };

};}
                                     #########################  WARNING  #########################
  # AFTER BOOTLOADER CHANGE RUN THESE COMMANDS
    # tldr efibootmgr
    # efibootmgr (Aquire Previous Nixos EFI Boot Number to Delete)
    # sudo efibootmgr -b 0000 --delete-bootnum (WARNING Change 0000 to Boot Number Aquired)
    # sudo nixos-rebuild --install-bootloader boot
    # sudo nixos-rebuild switch

  # To Find Windows EFI Handle For Systemd-Boot
    # Enter edk2-uefi-shell
    # "map -c" To List EFI Handles
    # "ls HD0c1:\EFI" To Check If Windows Is In Directories
    # "HD0c1:\EFI\Microsoft\Boot\Bootmgfw.efi" If Windows Boots The Handle Is Correct
