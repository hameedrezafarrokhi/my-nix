{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.boot.bootloader == "refind") {

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
