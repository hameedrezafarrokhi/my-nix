{ config, pkgs, lib, admin, system, nix-path, inputs, ... }:

let

  lock-up = pkgs.writeShellScriptBin "lock-up" ''
    timestamp=$(date +"%Y-%m-%d-%H-%M")
    nix flake update --flake ${nix-path} --output-lock-file ${nix-path}/lock/$timestamp.lock --refresh
  '';

  lock-backup = pkgs.writeShellScriptBin "lock-backup" ''
    timestamp=$(date +"%Y-%m-%d-%H-%M")
    cp ${nix-path}/flake.lock ${nix-path}/lock/$timestamp.lock
  '';

  flake-update = pkgs.writeShellScriptBin "update-input" ''
    input=$(                                           \
      nix flake metadata --json                        \
      | ${pkgs.jq}/bin/jq -r ".locks.nodes.root.inputs | keys[]" \
      | ${pkgs.fzf}/bin/fzf --multi --marker='x ')
    nix flake update $input
  '';

  trim-gen = pkgs.writeShellScriptBin "trim-gen" (builtins.readFile ./trim-generations.sh);

  full-nix-backup = pkgs.writeShellScriptBin "full-nix-backup" ''
    mkdir -p $HOME/nix-backup/folder
    mkdir -p $HOME/nix-backup/tar
    cp -r ${nix-path} $HOME/nix-backup/folder/nix-"$(date +%F_%H-%M-%S)" &&
    tar -czf $HOME/nix-backup/tar/nix-"$(date +%F_%H-%M-%S)".tar.gz ${nix-path} &&
    borgmatic create --repository nix &&
    cd ${nix-path} &&
    git add . &&
    git commit -m "$(date +%F_%H-%M-%S)" &&
    git branch -M main &&
    git push -u origin main &&
    builtin cd
  '';

in

{

  options.my.nix.enable = lib.mkEnableOption "enable nix";

  config = lib.mkIf (config.my.nix.enable) {

   #nixpkgs.config = {
   #  allowUnfree = true;
   #  allowUnsupportedSystem = false;
   # #allowBroken = true;
   #  permittedInsecurePackages = [
   #   #"intel-media-sdk-23.2.2"
   #   #"libsoup-2.74.3"
   #  ];
   #};

    nix = {
     #package = pkgs.nix;
      checkConfig = true;

     #nix.registry = {};           #For flake stuff
     #channels = {};
     #nixPath = ''
     #  if nix.channel.enable
     #  then [
     #    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
     #    "nixos-config=${nix-path}/configuration.nix"
     #    "/nix/var/nix/profiles/per-user/root/channels"
     #  ]
     #  else [];
     #''

      settings = {

        system = system;
        cores = 0;
        download-attempts = 10;
        download-speed = 0;
        timeout = 0;
        stalled-download-timeout = 300;
        http-connections = 25;
        http2 = true;
       #fallback = true;
        sandbox = true;
       #extra-sandbox-paths = [ "" "" ];
        max-jobs = "auto";
        max-substitution-jobs = 20;
        auto-optimise-store = true;
        allow-dirty = true;
        warn-dirty = true;

        keep-derivations = false;
        keep-failed = false;
        keep-going = false;
        keep-outputs = false;

        require-sigs = false;
        trusted-users = [ "root" "@wheel" admin ];
        allowed-users = [ "*" ];
        substituters = [
          "https://cache.nixos.org/"
          "https://catppuccin.cachix.org/"
          "https://nix-community.cachix.org/"
          "https://chaotic-nyx.cachix.org/"
        ];
        extra-substituters = [
          "https://cache.nixos.org/"
          "https://catppuccin.cachix.org/"
          "https://nix-community.cachix.org/"
          "https://chaotic-nyx.cachix.org/"
        ];
        trusted-substituters = [
          "https://cache.nixos.org/"
          "https://catppuccin.cachix.org/"
          "https://nix-community.cachix.org/"
          "https://chaotic-nyx.cachix.org/"
        ];
        extra-trusted-substituters = [
          "https://cache.nixos.org/"
          "https://catppuccin.cachix.org/"
          "https://nix-community.cachix.org/"
          "https://chaotic-nyx.cachix.org/"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        ];
        extra-trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        ];


       #system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-<arch>" ];
        experimental-features = [ "nix-command" "flakes" ];

      };

     #extraOptions = ''
     #  extra-substituters = https://catppuccin.cachix.org/
     #  extra-trusted-substituters = https://catppuccin.cachix.org/
     #  extra-trusted-public-keys = catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU=
     #'';

     #gc = {                                  # turn off if nh.clean is enabled
     #  automatic = true;
     #  dates = [ "weekly" "03:15" ];
     #  persistent = true;
     #  randomizedDelaySec = "0";
     #  options = "--delete-older-than 10d";
     #};

     #keepOldNixPath = true;

    };

    home.packages = with pkgs; [

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
      lock-up lock-backup
      full-nix-backup

    ]
    ;

    programs = {

      nh = {
        enable = true;
        flake = "${nix-path}";
        clean = {
          enable = true;
          extraArgs = "--keep-since 10d --keep 10";
          dates = "weekly";
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

      nix-init = {
        enable = true;
        package = pkgs.nix-init;
       #settings = {};
      };

      nix-search-tv = {
        enable = true;
        package = pkgs.nix-search-tv;
        enableTelevisionIntegration = true;
        settings = {
          indexes = [ "nixpkgs" "home-manager" "nixos" "nur" ];
          update_interval = "168h";
         #cache_dir = "path/to/cache/dir";
          enable_waiting_message = true;
          experimental = {
            render_docs_indexes = {
             plasma = "https://nix-community.github.io/plasma-manager/options.xhtml";
            #stylix = "https://nix-community.github.io/stylix/print.html";
            #stylix-nixos = "https://nix-community.github.io/stylix/options/platforms/nixos.html";
            #nvf = "https://notashelf.github.io/nvf/options.html";
            };
            options_file = {
              cat-nixos = "${inputs.catppuccin}/docs/data/main-nixos-options.json";
              cat-hm = "${inputs.catppuccin}/docs/data/main-home-options.json";
             #stylix = "${inputs.stylix}/doc/book.toml";
             #agenix = "<path to options.json>";
            };
          };
        };
      };

      nix-your-shell = {
        enable = true;
        package = pkgs.nix-your-shell ;
        nix-output-monitor = {
          package = pkgs.nix-output-monitor;
          enable = true;
        };
        enableZshIntegration = true;
        enableNushellIntegration = true;
        enableFishIntegration = true;
      };

    };

    systemd.user.services = {

      lock-up = {
        Unit = {
          Description = "flake lock update";
          PartOf = [ "multi-user.target" ];
          After = [ "multi-user.target" ];
        };
        Service = {
          ExecStart = "${lock-up}/bin/lock-up";
          Type = "oneshot";
         #Restart = "on-failure";
         #KillMode = "mixed";
        };
        Install = {
          WantedBy = [ "multi-user.target" ];
        };
      };

    };

    systemd.user.timers = {

      lock-up = {
        Unit = {
          Description = "flake lock update";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
        Timer = {
          OnCalendar = "daily";
	    Persistent = true;
        };
      };

    };

  };

}
