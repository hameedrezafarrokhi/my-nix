{ description = "NixOS_BTW";

  inputs = {

  # NIXPKGS

         nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  #      nixpkgs.url = "github:NixOS/nixpkgs/fbcf476f790d8a217c3eab4e12033dc4a0f6d23c";

  #       master.url = "github:NixOS/nixpkgs/master";
  #       master.url = "github:NixOS/nixpkgs/fbcf476f790d8a217c3eab4e12033dc4a0f6d23c";

        unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  #     unstable.url = "github:NixOS/nixpkgs/fbcf476f790d8a217c3eab4e12033dc4a0f6d23c";

          stable.url = "github:NixOS/nixpkgs/nixos-25.11";
  #       stable.url = "github:NixOS/nixpkgs/fbcf476f790d8a217c3eab4e12033dc4a0f6d23c";

      old-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
  #   old-stable.url = "github:NixOS/nixpkgs/fbcf476f790d8a217c3eab4e12033dc4a0f6d23c";

        fallback.url = "github:NixOS/nixpkgs/f61125a668a320878494449750330ca58b78c557";

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
#                nur = { url = "github:nix-community/NUR";
#                               inputs.nixpkgs.follows = "nixpkgs"; };
  nix-index-database = { url = "github:nix-community/nix-index-database";
                                inputs.nixpkgs.follows = "nixpkgs"; };

  # 3rd_PARTY

        xremap-flake = { url = "github:xremap/nix-flake";
                                inputs.nixpkgs.follows = "nixpkgs"; };

         nix-flatpak = { url = "github:gmodena/nix-flatpak/?ref=latest"; };

      cosmic-manager = { url = "github:HeitorAugustoLN/cosmic-manager";
                                inputs.nixpkgs.follows = "nixpkgs";
                                inputs.home-manager.follows = "home-manager"; };

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
                                inputs.nixpkgs.follows = "nixpkgs"; };
                               #inputs.quickshell.follows = "quickshell"; };
   dankMaterialShell = { url = "github:AvengeMedia/DankMaterialShell";
                                inputs.nixpkgs.follows = "nixpkgs"; };
                               #inputs.quickshell.follows = "quickshell"; };

#           ax-shell = { url = "github:poogas/Ax-Shell";
#                               inputs.nixpkgs.follows = "nixpkgs"; };

               ignis = { url = "github:ignis-sh/ignis";
                               inputs.nixpkgs.follows = "nixpkgs"; };

               mango = { url = "github:DreamMaoMao/mango";
                                inputs.nixpkgs.follows = "nixpkgs"; };

      dot-collection = { url = "github:hameedrezafarrokhi/dot-collection";
                                flake = false; };
           dwm-titus = { url = "github:ChrisTitusTech/dwm-titus";
                                flake = false; };
              chadwm = { url = "github:siduck/chadwm";
                                flake = false; };
             drew-wm = { url = "github:drewgrif/dwm-setup";
                                flake = false; };

                oxwm = { url = "github:tonybanters/oxwm";
                                inputs.nixpkgs.follows = "nixpkgs"; };

              assets = { url = "github:hameedrezafarrokhi/assets";
                                flake = false; };

              xfiles = { url = "github:hameedrezafarrokhi/xfiles-colors";
                                flake = false; };

          catppuccin = { url = "github:catppuccin/nix";};
  catppuccin-openbox = { url = "github:catppuccin/openbox";
                                flake = false; };

  };

  outputs = { self, ... } @ inputs :

  let

  # PKGS

    pkgsConf = {
      allowUnfree = true;
      nvidia.acceptLicense=true;
      allowBroken=true;
      permittedInsecurePackages=[
        "electron-36.9.5"
      ];
     #overlays = myOverlays;
    };
    myPKGS =  system: {
#       master = import inputs.master     {system=system;config=pkgsConf;};
      unstable = import inputs.unstable   {system=system;config=pkgsConf;};
        stable = import inputs.stable     {system=system;config=pkgsConf;};
    old-stable = import inputs.old-stable {system=system;config=pkgsConf;};
      fallback = import inputs.fallback   {system=system;config=pkgsConf;};
    };
    myOverlays = [
     #inputs.nur.overlays.default
     #inputs.chaotic.overlays.default
     #inputs.ax-shell.overlays.default

      (final: prev: {
        plasma-panel-colorizer = prev.plasma-panel-colorizer.overrideAttrs {
          postInstall = "chmod 755 $out/share/plasma/plasmoids/luisbocanegra.panel.colorizer/contents/ui/tools/list_presets.sh";
        };
      })

    ];


  # NIXOS

    mkSystem = pkg: state: system: hostname: admin: type: nix-path: nix-path-alt:
    pkg.lib.nixosSystem {
     #system = system; # Legacy (nixpkgs.hostPlatform instead)
     #pkgs = import pkg {system=system;config=pkgsConf;}; # Legacy (nixpkgs.config instead)

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
              inputs.nix-flatpak.homeManagerModules.nix-flatpak
              inputs.plasma-manager.homeModules.plasma-manager
              inputs.cosmic-manager.homeManagerModules.cosmic-manager
              inputs.nix-index-database.homeModules.nix-index
              inputs.xremap-flake.homeManagerModules.default
              inputs.catppuccin.homeModules.catppuccin
              inputs.dankMaterialShell.homeModules.dank-material-shell
             #inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
             #inputs.ax-shell.homeManagerModules.default
              inputs.mango.hmModules.mango
              inputs.ignis.homeManagerModules.default
              (import "${inputs.caelestia-shell}/nix/hm-module.nix" { })
            ];
          };
        }

            { networking.hostName  = hostname;   }
            { system.stateVersion  = state;      }
            { nixpkgs.hostPlatform = system;     }
            { nixpkgs.overlays     = myOverlays; }
            { nixpkgs.config       = pkgsConf;   }

            ./hosts/${hostname}/configuration.nix
            ./hosts/${hostname}/hardware-configuration.nix
            ./hosts/${hostname}/disko.nix
            ./modules/${type}.nix

            inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-index-database.nixosModules.nix-index
            inputs.nix-flatpak.nixosModules.nix-flatpak
           #inputs.nur.modules.nixos.default
           #inputs.nur.legacyPackages."${system}".repos.iopq.modules.xraya  # example
            inputs.stylix.nixosModules.stylix
            inputs.catppuccin.nixosModules.catppuccin
            inputs.mango.nixosModules.mango
           #inputs.oxwm.nixosModules.default
           #inputs.xremap-flake.nixosModules.default

      ];
    };

  # HOME_MANAGER

    mkHome = pkg: state: system: admin: type: nix-path: nix-path-alt:
    inputs.home-manager.lib.homeManagerConfiguration {

      extraSpecialArgs = { inputs = inputs; self = self; admin = admin;
                           nix-path = nix-path; nix-path-alt = nix-path-alt;
                           system = system; mypkgs = myPKGS system; };

     #pkgs = import pkg {system=system;config=pkgsConf;}; # Legacy (nixpkgs.hostPlatform instead)
      modules = [

            ./homes/${admin}/home.nix
            ./modules/${type}.nix

            { home.stateVersion = state;             }
            { home.enableNixpkgsReleaseCheck = true; }
            { nixpkgs.hostPlatform = system;         }
            { nixpkgs.overlays = myOverlays;         }
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
            inputs.plasma-manager.homeModules.plasma-manager
            inputs.cosmic-manager.homeManagerModules.cosmic-manager
            inputs.nix-index-database.homeModules.nix-index
            inputs.xremap-flake.homeManagerModules.default
            inputs.catppuccin.homeModules.catppuccin
            inputs.dankMaterialShell.homeModules.dank-material-shell
           #inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
           #inputs.ax-shell.homeManagerModules.default
            inputs.mango.hmModules.mango
            inputs.ignis.homeManagerModules.default
            (import "${inputs.caelestia-shell}/nix/hm-module.nix" { })
      ];
    };

  # NIX_ON_DROID

    mkDroid = pkg: droid-state: hm-state: hostname: admin: type:
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {

                          extraSpecialArgs = { inputs = inputs; self = self; admin = admin;
                                               nix-path = "/data/data/com.termux.nix/files/home/nixos";
                                               nix-path-alt = "~/nixos";
                                               system = "aarch64-linux"; mypkgs = myPKGS "aarch64-linux"; };
      modules = [

        {home-manager = { extraSpecialArgs = { inputs = inputs; self = self; admin = admin;
                                               nix-path = "/data/data/com.termux.nix/files/home/nixos";
                                               nix-path-alt = "~/nixos";
                                               system = "aarch64-linux"; mypkgs = myPKGS "aarch64-linux"; };

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
      pkgs = import pkg {
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

      nirvana = mkSystem inputs.nixpkgs "25.05" "x86_64-linux" "nirvana" "hrf" "personal"  "$HOME/nixos"    "~/nixos";
         blue = mkSystem inputs.nixpkgs "25.05" "x86_64-linux" "blue"    "hrf" "personal"  "/etc/nixos"  "/etc/nixos";
          red = mkSystem inputs.nixpkgs "25.05" "x86_64-linux" "red"     "hrf" "portable"  "$HOME/nixos"    "~/nixos";
    };

    nixOnDroidConfigurations = {

        black = mkDroid inputs.nixpkgs  "24.05" "25.05"        "black"   "hrf" "phone";
    };

    homeConfigurations = {

          hrf =   mkHome inputs.nixpkgs "25.05" "x86_64-linux" "hrf"     "personal-home"   "$HOME/nixos"    "~/nixos";
    };

  };

}
