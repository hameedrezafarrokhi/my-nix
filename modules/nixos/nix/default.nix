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

     #settings = {
     #
     #  system = system;
     #  cores = 0;
     #  download-attempts = 10;
     #  download-speed = 0;
     #  timeout = 0;
     #  stalled-download-timeout = 300;
     #  http-connections = 25;
     #  http2 = true;
     # #fallback = true;
     #  sandbox = true;
     # #extra-sandbox-paths = [ "" "" ];
     #  max-jobs = "auto";
     #  max-substitution-jobs = 20;
     #  auto-optimise-store = false;
     #  allow-dirty = true;
     #  warn-dirty = true;
     #
     #  keep-derivations = true;
     #  keep-failed = false;
     #  keep-going = false;
     #  keep-outputs = false;
     # #keep-env-derivations = false;
     #
     #  require-sigs = false;
     #  trusted-users = [ "root" "@wheel" admin ];
     #  allowed-users = [ "*" ];
     #
     #  substituters = lib.mkForce [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ]; #WARNING CHANGE AFTER INTERNET
     #
     # #substituters = [
     # #  "https://cache.nixos.org/"
     # # #"https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
     # # #"https://catppuccin.cachix.org/"
     # # #"https://nix-community.cachix.org/"
     # #];
     # #extra-substituters = [
     # #  "https://cache.nixos.org/"
     # # #"https://catppuccin.cachix.org/"
     # # #"https://nix-community.cachix.org/"
     # #];
     # #trusted-substituters = [
     # #  "https://cache.nixos.org/"
     # # #"https://catppuccin.cachix.org/"
     # # #"https://nix-community.cachix.org/"
     # #];
     # #extra-trusted-substituters = [
     # #  "https://cache.nixos.org/"
     # # #"https://catppuccin.cachix.org/"
     # # #"https://nix-community.cachix.org/"
     # #];
     # #trusted-public-keys = [
     # #  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
     # # #"catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
     # # #"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
     # #];
     # #extra-trusted-public-keys = [
     # #  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
     # # #"catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
     # # #"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
     # #];
     #
     #
     # #system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-<arch>" ];
     #  experimental-features = [ "nix-command" "flakes" ];
     #
     #};

     #sshServe.trusted = true;

     #extraOptions = ''
     #  extra-substituters = https://catppuccin.cachix.org/
     #  extra-trusted-substituters = https://catppuccin.cachix.org/
     #  extra-trusted-public-keys = catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU=
     #'';

      optimise = {
        automatic = false;
       #dates = [ "weekly" "03:45" ];
       #persistent = true;
       #randomizedDelaySec = "1800";
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

      nix-prefetch-git

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
