{ config, pkgs, lib, inputs, ... }:

let

  cfg = config.my.inputs-readme-files;

in

{

  options.my.inputs-readme-files.enable = lib.mkEnableOption "readme files from inputs to avoid re-downlading";

  config = lib.mkIf cfg.enable {

        xdg.stateFile = {
          "nixpkgs-readme".source = "${inputs.nixpkgs}/README.md";
           "stable-readme".source = "${inputs.stable}/README.md";
         "unstable-readme".source = "${inputs.unstable}/README.md";
           "master-readme".source = "${inputs.master}/README.md";
       "old-stable-readme".source = "${inputs.old-stable}/README.md";
  #        "kernel-readme".source = "${inputs.kernel}/README.md";
  #      "fallback-readme".source = "${inputs.fallback}/README.md";
     "home-manager-readme".source = "${inputs.home-manager}/README.md";
   "plasma-manager-readme".source = "${inputs.plasma-manager}/README.md";
     "nix-on-droid-readme".source = "${inputs.nix-on-droid}/README.md";
              "nur-readme".source = "${inputs.nur}/README.md";
        "nix-index-readme".source = "${inputs.nix-index-database}/README.md";
           "stylix-readme".source = "${inputs.stylix}/README.md";
  "caelestia-shell-readme".source = "${inputs.caelestia-shell}/README.md";
    "caelestia-cli-readme".source = "${inputs.caelestia-cli}/README.md";
          "noctalia-shell".source = "${inputs.noctalia-shell}/README.md";
#     "nix-artwork-readme".source = "${inputs.nix-artwork}/README.md";
       "catppuccin-readme".source = "${inputs.catppuccin}/README.md";
      "nix-flatpak-readme".source = "${inputs.nix-flatpak}/README.md";
          "chaotic-readme".source = "${inputs.chaotic}/README.md";
 #    "flake-utils-readme".source = "${inputs.flake-utils}/README.md";
     "xremap-flake-readme".source = "${inputs.xremap-flake}/README.md";
 #         "fabric-readme".source = "${inputs.fabric}/README.md";
 #                  "gray".source = "${inputs.gray}/README.md";
 #       "ax-shell-readme".source = "${inputs.ax-shell}/README.md";
        };

  };

}
