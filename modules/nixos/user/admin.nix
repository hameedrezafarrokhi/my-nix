{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (builtins.elem "${admin}" config.my.user.users) {

  users = {

    users = {

      ${admin} = {
       #password  initialPassword  hashedPassword  initialHashedPassword hashedPasswordFile
        isNormalUser = true;
        description = admin;
        shell = pkgs.${config.my.shell.default};
       #defaultUserShell = pkgs.${config.my.shell.default}; # will be set to users.defaultUserShell
        extraGroups = [
          # Default
          "networkmanager" "wheel"

          # Titus
          "flatpak" #"root"              #makes "run as root" unable to create files in dolphin (but not nemo!). use only if nessecary
          "disk" "sshd" "audio" "video"
          "qemu" "kvm" "libvirtd"

          # GLF
          "input" "render"

          # My Stuff
          "wireshark" "scanner" "lp" "pipewire" "samba" "deluge" "transmission"
          "tty"
          "podman"
          config.security.tpm2.tssGroup
          "uinput" "input"
          "mail"
          "fwupd-refresh"
          "cdrom"
        ];
      };

    };

  };

};}
