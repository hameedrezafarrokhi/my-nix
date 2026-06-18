{ description = "NixOS_BTW";

  inputs = {

  # NIXPKGS
         nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#         master.url = "github:NixOS/nixpkgs/master";
        unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
          stable.url = "github:NixOS/nixpkgs/nixos-26.05";
      old-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
#         _25-05.url = "github:NixOS/nixpkgs/nixos-25.05";
#       fallback.url = "github:NixOS/nixpkgs/a82ccc39b39b621151d6732718e3e250109076fa";

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
  nix-index-database = { url = "github:nix-community/nix-index-database";
                                inputs.nixpkgs.follows = "nixpkgs"; };
#                nur = { url = "github:nix-community/NUR";
#                               inputs.nixpkgs.follows = "nixpkgs"; };

  # 3rd_PARTY
#     xlibre-overlay = { url = "git+https://codeberg.org/takagemacoed/xlibre-overlay?ref=dev-for-26.05"; };

           nix-alien = { url = "github:thiagokokada/nix-alien"; };

         nix-flatpak = { url = "github:gmodena/nix-flatpak/?ref=latest"; };
        xremap-flake = { url = "github:xremap/nix-flake";
                                inputs.nixpkgs.follows = "nixpkgs"; };
#     cosmic-manager = { url = "github:HeitorAugustoLN/cosmic-manager";
#                               inputs.nixpkgs.follows = "nixpkgs";
#                               inputs.home-manager.follows = "home-manager"; };

             lazyvim = { url = "github:pfassina/lazyvim-nix";
                                inputs.nixpkgs.follows = "nixpkgs"; };

          catppuccin = { url = "github:catppuccin/nix";};
              stylix = { url = "github:danth/stylix";
                                inputs.nixpkgs.follows = "nixpkgs"; };

#    caelestia-shell = { url = "github:caelestia-dots/shell";
#                               inputs.nixpkgs.follows = "nixpkgs";
#                               inputs.caelestia-cli.follows = "caelestia-cli"; };
#      caelestia-cli = { url = "github:caelestia-dots/cli";
#                               inputs.nixpkgs.follows = "nixpkgs";
#                               inputs.caelestia-shell.follows = "caelestia-shell"; };
#     noctalia-shell = { url = "github:noctalia-dev/noctalia-shell";
#                               inputs.nixpkgs.follows = "nixpkgs"; };
#  dankMaterialShell = { url = "github:AvengeMedia/DankMaterialShell";
#                               inputs.nixpkgs.follows = "nixpkgs"; };
#             ambxst = { url = "github:Axenide/Ambxst";
#                               inputs.nixpkgs.follows = "nixpkgs"; };
#              ignis = { url = "github:ignis-sh/ignis";
#                               inputs.nixpkgs.follows = "nixpkgs"; };

#              mango = { url = "github:DreamMaoMao/mango";
#                               inputs.nixpkgs.follows = "nixpkgs"; };
#               oxwm = { url = "github:tonybanters/oxwm";
#                               inputs.nixpkgs.follows = "nixpkgs"; };

#          dwm-titus = { url = "github:ChrisTitusTech/dwm-titus";
#                               flake = false; };
#             chadwm = { url = "github:siduck/chadwm";
#                               flake = false; };
#            drew-wm = { url = "github:drewgrif/dwm-setup";
#                               flake = false; };

  # My_Stuff
              assets = { url = "github:hameedrezafarrokhi/assets";
                                flake = false; };
#     unpatched-bins = { url = "github:hameedrezafarrokhi/unpatched-bins";
#                               flake = false; };
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
       #"pulsar-1.130.1"
      ];
    };
    myPKGS =  system: {
       #master = import inputs.master     {system=system;config=pkgsConf;};
      unstable = import inputs.unstable   {system=system;config=pkgsConf;};
        stable = import inputs.stable     {system=system;config=pkgsConf;};
    old-stable = import inputs.old-stable {system=system;config=pkgsConf;};
#       _25-05 = import inputs."_25-05"   {system=system;config=pkgsConf;};
#     fallback = import inputs.fallback   {system=system;config=pkgsConf;};
    };
    myOverlays = [
     #inputs.nur.overlays.default
      (final: prev: {
        plasma-panel-colorizer = prev.plasma-panel-colorizer.overrideAttrs {
          postInstall = "chmod 755 $out/share/plasma/plasmoids/luisbocanegra.panel.colorizer/contents/ui/tools/list_presets.sh";
        };
      })
    ];


  # NIXOS
    mkSystem = pkg: state: system: hostname: admin: type: nix-path: nix-path-alt:
    pkg.lib.nixosSystem {
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
             #inputs.cosmic-manager.homeManagerModules.cosmic-manager
              inputs.nix-index-database.homeModules.nix-index
              inputs.xremap-flake.homeManagerModules.default
              inputs.lazyvim.homeManagerModules.default
              inputs.catppuccin.homeModules.catppuccin
             #inputs.mango.hmModules.mango
             #inputs.ignis.homeManagerModules.default
             #inputs.dankMaterialShell.homeModules.dank-material-shell
             #inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
             #(import "${inputs.caelestia-shell}/nix/hm-module.nix" { })
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
            inputs.stylix.nixosModules.stylix
            inputs.catppuccin.nixosModules.catppuccin
           #inputs.mango.nixosModules.mango
           #inputs.ambxst.nixosModules.default
           #inputs.xremap-flake.nixosModules.default
           #inputs.nur.modules.nixos.default
           #inputs.nur.legacyPackages."${system}".repos.iopq.modules.xraya  # example

            #It breaks some packages that were deeply integrated with Xorg. For example tigervnc, the way it was packaged included some hardcoded xorg paths. It assumed the source of xorg.xorgserver is a tarball, so fetchFromGitHub cannot be used. It failed to build against xlibre-xserver without modification.
#           inputs.xlibre-overlay.nixosModules.overlay-xlibre-xserver
#
#           #Drivers
#          #inputs.xlibre-overlay.nixosModules.overlay-all-xlibre-drivers
#           inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-input-libinput
#           inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-input-evdev
#           inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-input-joystick
#           inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-input-keyboard
#           inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-input-mouse
#           inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-input-synaptics
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-input-vmmouse = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-input-void = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-input-wacom = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-amdgpu = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-ati = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-dummy = true; Anything pull xpra as dependences (e.g. x11docker) will also be failed to build when xlibre-xf86-video-dummy is used.
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-fbdev = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-geode = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-intel = true; # old tag failed to build against xlibre-xserver.
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-mga = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-nouveau = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-nv = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-r128 = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-vesa = true;
#          #inputs.xlibre-overlay.nixosModules.overlay-xlibre-xf86-video-vmware = true;

      ];
    };

  # HOME_MANAGER
    mkHome = pkg: state: system: admin: type: nix-path: nix-path-alt:
    inputs.home-manager.lib.homeManagerConfiguration {
      extraSpecialArgs = { inputs = inputs; self = self; admin = admin;
                           nix-path = nix-path; nix-path-alt = nix-path-alt;
                           system = system; mypkgs = myPKGS system; };
      modules = [
            { home.stateVersion = state;             }
            { home.enableNixpkgsReleaseCheck = true; }
            { nixpkgs.hostPlatform = system;         }
            { nixpkgs.overlays = myOverlays;         }
            ./homes/${admin}/home.nix
            ./modules/${type}.nix
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
            inputs.plasma-manager.homeModules.plasma-manager
           #inputs.cosmic-manager.homeManagerModules.cosmic-manager
            inputs.nix-index-database.homeModules.nix-index
            inputs.xremap-flake.homeManagerModules.default
            inputs.catppuccin.homeModules.catppuccin
           #inputs.mango.hmModules.mango
           #inputs.ignis.homeManagerModules.default
           #inputs.dankMaterialShell.homeModules.dank-material-shell
           #inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
           #(import "${inputs.caelestia-shell}/nix/hm-module.nix" { })
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
              inputs.nix-index-database.homeModules.nix-index
              inputs.xremap-flake.homeManagerModules.default
            ];
          };
        }
        { system.stateVersion = droid-state; }
        ./hosts/${hostname}/nix-on-droid.nix
        ./modules/${type}.nix
      ];
      home-manager-path = inputs.home-manager.outPath;
      pkgs = import pkg {
        system = "aarch64-linux";
        overlays = [
          inputs.nix-on-droid.overlays.default
        ];
      };
    };

  in {

    nixosConfigurations = {
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
