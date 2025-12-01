{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.boot.bootloader == "refind") {

  boot = {

    consoleLogLevel = 1; # default is 4; anything lower would be displayed
    initrd = {
      verbose = false;
      allowMissingModules = true;
    };

    loader = {

      efi.canTouchEfiVariables = true;

      refind = {

        enable = true;
        package = pkgs.refind;
        maxGenerations = 6;
        efiInstallAsRemovable = !config.boot.loader.efi.canTouchEfiVariables;

        additionalFiles = {

          "efi/memtest86/memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi";

        };

       #extraConfig = '' '';

      };

    };

  };

  environment.systemPackages = with pkgs; [
   pkgs.efibootmgr               ##Necessary for Modify EFI Bootloader/Order
  #refind                        ##rEFInd bootloader
  ];

 # https://nixos.wiki/wiki/REFInd

  # sudo nix-shell -p refind efibootmgr
  # refind-install

                                     #########################  WARNING  #########################

  # AFTER BOOTLOADER CHANGE RUN THESE COMMANDS
    # tldr efibootmgr

    # efibootmgr (Aquire Previous Nixos EFI Boot Number to Delete)
    # sudo efibootmgr -b 0000 --delete-bootnum (WARNING Change 0000 to Boot Number Aquired)
    # sudo nixos-rebuild --install-bootloader boot
    # sudo nixos-rebuild switch

};}
