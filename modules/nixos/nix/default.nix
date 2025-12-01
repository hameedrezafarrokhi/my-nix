{ config, pkgs, lib, admin, system, nix-path, mypkgs, inputs, ... }:

let

  cfg = config.my.nix;
  flake-update = pkgs.writeShellScriptBin "update-input" ''
    input=$(                                           \
      nix flake metadata --json                        \
      | ${pkgs.jq}/bin/jq -r ".locks.nodes.root.inputs | keys[]" \
      | ${pkgs.fzf}/bin/fzf --multi --marker='x ')
    nix flake update $input
  '';

  trim-gen = pkgs.writeShellScriptBin "trim-gen" (builtins.readFile ./trim-generations.sh);


in

{

  options.my.nix.enable = lib.mkEnableOption "enable nix";

  config = lib.mkIf (config.my.nix.enable) {

   #nixpkgs.config = {
   #  allowUnfree = true;
   #  allowUnsupportedSystem = false;
   #  allowBroken = true;
   #  permittedInsecurePackages = [
   #   #"intel-media-sdk-23.2.2"
   #   #"libsoup-2.74.3"
   #  ];
   #};

    nix = {
      enable = true;
      package = pkgs.nix;
      checkConfig = true;
      checkAllErrors = true;

     #nix.registry = {};           #For flake stuff
      channel.enable = true;
     #nixPath = ''
     #  if nix.channel.enable
     #  then [
     #    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
     #    "nixos-config=${nix-path}/configuration.nix"
     #    "/nix/var/nix/profiles/per-user/root/channels"
     #  ]
     #  else [];
     #''

      settings = config.home-manager.users.${admin}.nix.settings;

     #sshServe.trusted = true;

     #extraOptions = ''
     #  extra-substituters = https://catppuccin.cachix.org/
     #  extra-trusted-substituters = https://catppuccin.cachix.org/
     #  extra-trusted-public-keys = catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU=
     #'';

      optimise = {
        automatic = true;
        dates = [ "weekly" "03:45" ];
        persistent = true;
        randomizedDelaySec = "1800";
      };

     #gc = {                                  # turn off if nh.clean is enabled
     #  automatic = true;
     #  dates = [ "weekly" "03:15" ];
     #  persistent = true;
     #  randomizedDelaySec = "0";
     #  options = "--delete-older-than 10d";
     #};
    };

   #system.autoUpgrade =
   # enable = true;
   # dates = "weekly";

    environment.systemPackages = with pkgs; [
      nh nvd nix-output-monitor
     #nix-fast-build
     #nurl
     #nix-init nix-info nix-inspect
     #nix-du
     #nix-web # after running nix-web: http://localhost:8649/
     #nix-top nix-doc
     #nix-tree
      nix-melt nix-diff
      nix-search nix-health
     #nix-weather nix-plugins
     #nix-janitor nix-template
     #nix-visualize
      nix-search-tv
     #nix-converter nix-search-cli
     #nix-playground nix-check-deps
     #nix-forecast
     #nix-query-tree-viewer
      nil nixd
     #comma
    ] ++
    [
      flake-update
      trim-gen
    ]
    ;

   #environment.sessionVariables = {
   #  NH_FLAKE = "${nix-path}";
   #};

    programs = {

      nh = {
        enable = config.home-manager.users.${admin}.programs.nh.enable;
        flake = config.home-manager.users.${admin}.programs.nh.flake;
        clean = {
          enable = config.home-manager.users.${admin}.programs.nh.clean.enable;
          extraArgs = config.home-manager.users.${admin}.programs.nh.clean.extraArgs;
          dates = config.home-manager.users.${admin}.programs.nh.clean.dates;
        };
      };

     #command-not-found = {
     #  enable = true;
     # #dbPath = "/nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite";
     #};

      nix-index-database.comma.enable = true;
      nix-index = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
      };

      nix-ld = {
        enable = true;
        package= pkgs.nix-ld;
       #libraries = [ ];      # baseLibraries derived from systemd and nix dependencies;
      };

    };

    services = {  # Enables a FSH Compliant at /bin and /usr/bin
      envfs = {
        enable = true;
        package = pkgs.envfs;
        extraFallbackPathCommands = "ln -s $''{pkgs.bash}/bin/bash $out/bash";
      };
    };

  };

}
