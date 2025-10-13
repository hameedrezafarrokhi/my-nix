{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.boot.bootloader == "grub") {

  environment.systemPackages = with pkgs; [
   pkgs.efibootmgr               ##Necessary for Modify EFI Bootloader/Order
   os-prober                     ##detect OSes for GRUB
   catppuccin-grub
  #grub2                         ##GRUB bootlader
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

      grub = {
        enable = true;
        device = "nodev";
       #device = "/dev/sdc1";
       #devices = ""; # for grub installation on multiple disks
        efiSupport = true;
        efiInstallAsRemovable = false;
        useOSProber = true;
        timeoutStyle = "menu"; # one of "menu", "countdown", "hidden"
        configurationLimit = 6;
       #configurationName = "";
        entryOptions = "--class nixos --unrestricted";
        subEntryOptions = "--class nixos";
       #copyKernels = false;
        default = "saved"; # 0
        storePath = "/nix/store";
        fsIdentifier = "uuid"; # one of "uuid", "label", "provided"
        zfsSupport = false;

        forcei686 = false;
        forceInstall = false;
        enableCryptodisk = false;
       #extraGrubInstallArgs = [ ];
       #extraInstallCommands = '' '';
       #extraPrepareConfig = '' '';
       #ipxe = { };

       #extraConfig = '' '';
       #extraPerEntryConfig = " ";

        gfxmodeEfi= "auto"; # text , 1024x768 , auto ...
        gfxpayloadEfi = "keep"; # keep , text ...

       #gfxmodeBios= "auto"; # same for bios mbr
       #gfxpayloadBios = "text";

       #extraEntries = '' '';
        extraEntriesBeforeNixOS = false;
       #extraFiles = { "memtest.bin" = "${pkgs.memtest86plus}/memtest.bin"; };
        memtest86 = {
          enable = true;
         #params = [ ];
        };
       #mirroredBoots = [ ]; # list of Submodules

       #theme = "${pkgs.kdePackages.breeze-grub}/grub/themes/breeze";
       #theme = lib.mkForce "${pkgs.catppuccin-grub}/share/grub/themes/catppuccin-​macchiato-​grub-​theme";
        theme = lib.mkForce "${pkgs.catppuccin-grub}/theme.txt";
       #backgroundColor = null;
       #splashImage = ./my-background.png;
       #splashMode = "normal"; # one of "normal", "stretch"
       #font = "${pkgs.grub2}/share/grub/unicode.pf2";
       #fontSize = 16;

       #users = { }; # Submodules

      };

    };
  };

 #boot.loader.grub.theme = pkgs.catppuccin-grub;

                                     #########################  WARNING  #########################

  # AFTER BOOTLOADER CHANGE RUN THESE COMMANDS
    # tldr efibootmgr

    # efibootmgr (Aquire Previous Nixos EFI Boot Number to Delete)
    # sudo efibootmgr -b 0000 --delete-bootnum (WARNING Change 0000 to Boot Number Aquired)
    # sudo nixos-rebuild --install-bootloader boot
    # sudo nixos-rebuild switch

};}
