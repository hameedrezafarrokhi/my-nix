{ config, pkgs, lib, nix-path, nix-path-alt, admin, ... }:

{ config = lib.mkIf (config.my.apps.borg.enable) {

  programs.borgmatic = {
    enable = true;
    package = pkgs.borgmatic;
    backups = {
      nix = {
        location = {
          sourceDirectories = [
           #"/etc/nixos"
           #"~/nixos"
           #"/data/data/com.termux.nix/files/home/nixos"
            "${nix-path}"
            "${nix-path-alt}"
            "~/.local/share/fish"
            "~/Documents/bookmarks"
          ];
          repositories = [
             {
               label = "nix";
               path = "ssh://yewk4an5@yewk4an5.repo.borgbase.com/./repo";
             }
	    ];
        };
      };
    };
  };

  services.borgmatic = {
    enable = false;
    frequency = "weekly";
  };

  home.packages = with pkgs; [

    borgbackup                    ##Backend of Pika
    borgmatic                     ##Borg Frontend for CLI
    vorta                         ##Borg Frontend with BorgBase
   #pika-backup                   ##Home files backup with borg

  ];

};}
