{ config, pkgs, lib, nix-path, nix-path-alt, admin, ... }:

let

  cfg = config.my.backup;

in

{

  options.my.backup = {

    borg.enable = lib.mkEnableOption "enable borg backup";

  };

  config = lib.mkIf (cfg.borg.enable) {

    environment.systemPackages = with pkgs; [

      borgbackup                    ##Backend of Pika
      borgmatic                     ##Borg Frontend for CLI
      vorta                         ##Borg Frontend with BorgBase
     #pika-backup                   ##Home files backup with borg

    ];

    services.borgmatic.enable = true;
    services.borgmatic.settings.source_directories = config.home-manager.users.${admin}.programs.borgmatic.backups.nix.location.sourceDirectories;
    services.borgmatic.settings.repositories = config.home-manager.users.${admin}.programs.borgmatic.backups.nix.location.repositories;


  # services.borgmatic.configurations = {
  #     # List of source directories to backup.
  #   source_directories:
  #     # - /home
  #       - ${nix-path}
  #
  #   # Paths of local or remote repositories to backup to.
  #   repositories:
  #       - path: ssh://yewk4an5@yewk4an5.repo.borgbase.com/./repo
  #         label: labtop
  #       - path: ssh://y5jg5ew1@y5jg5ew1.repo.borgbase.com/./repo
  #         label: pc
  #
  #   # Retention policy for how many backups to keep.
  #   keep_daily: 7
  #   keep_weekly: 4
  #   keep_monthly: 6
  #
  #   # List of checks to run to validate your backups.
  #   checks:
  #       - name: repository
  #       - name: archives
  #         frequency: 2 weeks
  #
  #   # Custom preparation scripts to run.
  #   commands:
  #       - before: action
  #         when: [create]
  #         run: [prepare-for-backup.sh]
  #
  #   # Databases to dump and include in backups.
  #   postgresql_databases:
  #       - name: users
  #
  #   # Third-party services to notify you if backups aren't happening.
  #   healthchecks:
  #       ping_url: https://hc-ping.com/be067061-cf96-4412-8eae-62b0c50d6a8c
  #
  #     };

    };


}
