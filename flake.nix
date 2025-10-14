{ description = "NixOS_BTW";

  inputs = {

  # NIXPKGS

         nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          master.url = "github:NixOS/nixpkgs/master";
        unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
          stable.url = "github:NixOS/nixpkgs/nixos-25.05";
      old-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

          kernel.url = "github:NixOS/nixpkgs/7df7ff7d8e00218376575f0acdcc5d66741351ee";
        fallback.url = "github:NixOS/nixpkgs/fbcf476f790d8a217c3eab4e12033dc4a0f6d23c";

  # NIX_COMMUNITY

               disko = { url = "github:nix-community/disko/latest";
                                inputs.nixpkgs.follows = "nixpkgs"; };
        home-manager = { url = "github:nix-community/home-manager";
                                inputs.nixpkgs.follows = "nixpkgs"; };
      plasma-manager = { url = "github:nix-community/plasma-manager";
                                inputs.nixpkgs.follows = "nixpkgs";
                                inputs.home-manager.follows = "home-manager"; };
        nix-on-droid = { url = "github:nix-community/nix-on-droid/release-24.05";
                                inputs.nixpkgs.follows = "nixpkgs";
                                inputs.home-manager.follows = "home-manager"; };
                 nur = { url = "github:nix-community/NUR";
                                inputs.nixpkgs.follows = "nixpkgs"; };
  nix-index-database = { url = "github:nix-community/nix-index-database";
                                inputs.nixpkgs.follows = "nixpkgs"; };

  # 3rd_PARTY

        xremap-flake = { url = "github:xremap/nix-flake";
                                inputs.nixpkgs.follows = "nixpkgs"; };

              stylix = { url = "github:danth/stylix";
                                inputs.nixpkgs.follows = "nixpkgs"; };

          quickshell = { url = "github:outfoxxed/quickshell";
                                inputs.nixpkgs.follows = "nixpkgs"; };
     caelestia-shell = { url = "github:caelestia-dots/shell";
                                inputs.nixpkgs.follows = "nixpkgs";
                                inputs.quickshell.follows = "quickshell";
                                inputs.caelestia-cli.follows = "caelestia-cli"; };
       caelestia-cli = { url = "github:caelestia-dots/cli";
                                inputs.nixpkgs.follows = "nixpkgs";
                                inputs.caelestia-shell.follows = "caelestia-shell"; };
      noctalia-shell = { url = "github:noctalia-dev/noctalia-shell";
                                inputs.nixpkgs.follows = "nixpkgs";
                                inputs.quickshell.follows = "quickshell"; };
   dankMaterialShell = { url = "github:AvengeMedia/DankMaterialShell";
                                inputs.nixpkgs.follows = "nixpkgs";
                                inputs.quickshell.follows = "quickshell"; };

            ax-shell = { url = "github:poogas/Ax-Shell";
                                inputs.nixpkgs.follows = "nixpkgs"; };

          #   fabric = { url = "github:Fabric-Development/fabric";      # OLD STUFF
          #                     inputs.nixpkgs.follows = "nixpkgs"; };
          #     gray = { url = "github:Fabric-Development/gray";
          #                     inputs.nixpkgs.follows = "nixpkgs"; };
          # ax-shell = { url = "github:Axenide/Ax-Shell";
          #                     flake = false; };

      dot-collection = { url = "github:hameedrezafarrokhi/dot-collection";
                                flake = false; };
           dwm-titus = { url = "github:ChrisTitusTech/dwm-titus";
                                flake = false; };
              chadwm = { url = "github:siduck/chadwm";
                                flake = false; };
             drew-wm = { url = "github:drewgrif/dwm-setup";
                                flake = false; };
            bread-wm = { url = "github:BreadOnPenguins/dwm";
                                flake = false; };
             omarchy = { url = "github:basecamp/omarchy";
                                flake = false; };

         nix-artwork = { url = "github:NixOS/nixos-artwork";
                                flake = false; };
              assets = { url = "github:hameedrezafarrokhi/assets";
                                flake = false; };

          catppuccin = { url = "github:catppuccin/nix";};
  catppuccin-openbox = { url = "github:catppuccin/openbox";
                                flake = false; };

         nix-flatpak = { url = "github:gmodena/nix-flatpak/?ref=latest";};
             chaotic = { url = "github:chaotic-cx/nyx/nyxpkgs-unstable";};
         flake-utils = { url = "github:numtide/flake-utils";};
         #windscribe = { url = "github:ParkerrDev/nixpkgs-windscribe";};

  };

  outputs = { self, ... } @ inputs :

  let

  # PKGS

    pkgsConf = {allowUnfree=true;nvidia.acceptLicense=true;};
      myPKGS =  system: {
        master = import inputs.master     {system=system;config=pkgsConf;};
      unstable = import inputs.unstable   {system=system;config=pkgsConf;};
        stable = import inputs.stable     {system=system;config=pkgsConf;};
    old-stable = import inputs.old-stable {system=system;config=pkgsConf;};

        kernel = import inputs.kernel     {system=system;config=pkgsConf;};
      fallback = import inputs.fallback   {system=system;config=pkgsConf;};
      };

  # NIXOS

    mkSystem = pkgs: state: system: hostname: admin: type: nix-path: nix-path-alt:
    pkgs.lib.nixosSystem {
      system = system;
                               specialArgs = { inputs = inputs; self = self; admin = admin;
                                               nix-path = nix-path; nix-path-alt = nix-path-alt;
                                               system = system; mypkgs = myPKGS system; };

      modules = [

        {home-manager = { extraSpecialArgs = { inputs = inputs; self = self; admin = admin;
                                               nix-path = nix-path; nix-path-alt = nix-path-alt;
                                               system = system; mypkgs = myPKGS system; };

            sharedModules = [
              { home.stateVersion = state;             }
              { home.enableNixpkgsReleaseCheck = true; }
              inputs.chaotic.homeManagerModules.default
              inputs.nix-flatpak.homeManagerModules.nix-flatpak
              inputs.plasma-manager.homeModules.plasma-manager
              inputs.nix-index-database.homeModules.nix-index
              inputs.xremap-flake.homeManagerModules.default
              inputs.catppuccin.homeModules.catppuccin
              inputs.dankMaterialShell.homeModules.dankMaterialShell.default
             #inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
              inputs.ax-shell.homeManagerModules.default
              (import "${inputs.caelestia-shell}/nix/hm-module.nix" { })
            ];
          };
        }

            { networking.hostName  = hostname; }
            { nixpkgs.hostPlatform = system;   }
            { system.stateVersion  = state;    }

            ./hosts/${hostname}/configuration.nix
            ./hosts/${hostname}/hardware-configuration.nix
            ./hosts/${hostname}/disko.nix
            ./modules/${type}.nix

            inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-index-database.nixosModules.nix-index
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.nur.modules.nixos.default
           #inputs.nur.legacyPackages."${system}".repos.iopq.modules.xraya  # example
            inputs.chaotic.nixosModules.default
            inputs.stylix.nixosModules.stylix
            inputs.catppuccin.nixosModules.catppuccin
           #inputs.xremap-flake.nixosModules.default
           #(import "${inputs.windscribe}/windscribe/default.nix")

            {nixpkgs.overlays = [
              (final: prev:
                let
                  sys = prev.system;
                  axpkgs = inputs.ax-shell.packages.${sys} or {};
                in {
                  ax-shell = axpkgs.ax-shell or null;
                  fabric-cli = axpkgs.fabric-cli or null;
                  ax-send = axpkgs.ax-send or null;
                }
              )
            ]; }

      ];
    };

  # HOME_MANAGER

    mkHome = pkg: state: system: admin: type: nix-path: nix-path-alt:
    inputs.home-manager.lib.homeManagerConfiguration {

      extraSpecialArgs = { inputs = inputs; self = self; admin = admin;
                           nix-path = nix-path; nix-path-alt = nix-path-alt;
                           system = system; mypkgs = myPKGS system; };

      pkgs = import pkg {system=system;config=pkgsConf;};
      modules = [

            ./homes/${admin}/home.nix
            ./modules/${type}.nix

            { home.stateVersion = state;             }
            { home.enableNixpkgsReleaseCheck = true; }
            inputs.chaotic.homeManagerModules.default
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
            inputs.plasma-manager.homeModules.plasma-manager
            inputs.nix-index-database.homeModules.nix-index
            inputs.xremap-flake.homeManagerModules.default
            inputs.catppuccin.homeModules.catppuccin
            inputs.dankMaterialShell.homeModules.dankMaterialShell.default
           #inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
            inputs.ax-shell.homeManagerModules.default
            (import "${inputs.caelestia-shell}/nix/hm-module.nix" { })
      ];
    };

  # NIX_ON_DROID

    mkDroid = pkgs: droid-state: hm-state: system: hostname: admin: type: nix-path: nix-path-alt:
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {

                          extraSpecialArgs = { inputs = inputs; self = self; admin = admin;
                                               nix-path = nix-path; nix-path-alt = nix-path-alt;
                                               system = system; mypkgs = myPKGS system; };
      modules = [

        {home-manager = { extraSpecialArgs = { inputs = inputs; self = self; admin = admin;
                                               nix-path = nix-path; nix-path-alt = nix-path-alt;
                                               system = system; mypkgs = myPKGS system; };

            sharedModules = [
              { home.stateVersion = hm-state;          }
              { home.enableNixpkgsReleaseCheck = true; }
              inputs.nix-flatpak.homeManagerModules.nix-flatpak
              inputs.plasma-manager.homeModules.plasma-manager
              inputs.nix-index-database.homeModules.nix-index
              inputs.xremap-flake.homeManagerModules.default
              inputs.catppuccin.homeModules.catppuccin
              (import "${inputs.caelestia-shell}/nix/hm-module.nix" { })
            ];
          };
        }

        ./hosts/${hostname}/nix-on-droid.nix
        ./modules/${type}.nix

        { system.stateVersion = droid-state; }
      ];
      home-manager-path = inputs.home-manager.outPath;
      pkgs = import pkgs {
        system = "aarch64-linux";
        overlays = [
          inputs.nix-on-droid.overlays.default
        ];
      };
    };

  # VM

  # DARWIN


  in {

    nixosConfigurations = { #"/home/${admin}/nixos"

      nirvana = mkSystem inputs.nixpkgs "25.05" "x86_64-linux" "nirvana" "hrf" "personal" "$HOME/nixos" "~/nixos";
         blue = mkSystem inputs.nixpkgs "25.05" "x86_64-linux" "blue"    "hrf" "personal"  "/etc/nixos" "/etc/nixos";
          red = mkSystem inputs.nixpkgs "25.05" "x86_64-linux" "red"     "hrf" "personal"  "/etc/nixos" "/etc/nixos";
    };

    homeConfigurations = {

          hrf =   mkHome inputs.nixpkgs "25.05" "x86_64-linux"  "hrf"   "personal-home"   "$HOME/nixos" "~/nixos";
    };

    nixOnDroidConfigurations = {

        black = mkDroid inputs.nixpkgs "24.05" "25.05" "aarch64-linux" "black" "hrf" "phone" "/data/data/com.termux.nix/files/home/nixos" "~/nixos";
    };

  };
}
