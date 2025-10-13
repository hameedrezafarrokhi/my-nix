{ config, pkgs, lib, nix-path, ... }:

{ config = lib.mkIf (builtins.elem "bash" config.my.shells) {

  home.packages = [ pkgs.bash-preexec pkgs.blesh ];

  programs.bash = {
    enable = true;
    shellAliases = {

      nvdiff = "nvd diff /nix/var/nix/profiles/system-{1,2}-link";

      nhi = "nh os info";
      nhr = "nh os rollback --ask -t";
      nhc = "nh clean all --ask";
      pkgs = "nh search";

      borg-list = "borgmatic list --repository";
      borg-push = "borgmatic create --repository";
      borg-nix = "borgmatic create --repository nix";
      borg-pc = "borgmatic create --repository nixos-pc";

      plasma-restart = "pkill plasmashell && kstart5 plasmashell";

      bye = "wayland-logout";

      btw = "tokei ${nix-path}";

      nixos-btw = ''echo I Use NixOS BTW ":)"'';

    };
   #initExtra = ''
   #  source "${pkgs.bash-preexec}/share/bash/bash-preexec.sh"
   #'';
   #bashrcExtra = ''
   #  if [[ $- == *i* ]]; then
   #    if [[ -f "$(blesh-share 2>/dev/null)/ble.sh" ]]; then
   #      if [[ -z "$BLE_VERSION" ]]; then
   #        source "$(blesh-share)"/ble.sh --noattach
   #          if [[ -t 0 ]] && [[ -t 1 ]]; then
   #            ble-attach
   #        fi
   #      fi
   #    fi
   #  fi
   #'';
  };

};}

#  source "${pkgs.bash-preexec}/share/bash/bash-preexec.sh"

#  source -- "${pkgs.blesh}/share/blesh/ble.sh"
