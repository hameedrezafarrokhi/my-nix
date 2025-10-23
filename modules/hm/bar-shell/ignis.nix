{ pkgs, lib, config, inputs, ...}:

{ config = lib.mkIf (builtins.elem "ignis" config.my.bar-shell.shells) {

  programs.ignis = {

    enable = true;

    # Add Ignis to the Python environment (useful for LSP support)
    addToPythonEnv = true;

    # Put a config directory from your flake into ~/.config/ignis
    # NOTE: Home Manager will copy this directory to /nix/store
    # and create a symbolic link to the copy.

   #configDir = ./ignis;

    # Enable dependencies required by certain services.
    # NOTE: This won't affect your NixOS system configuration.
    # For example, to use NetworkService, you must also enable
    # NetworkManager in your NixOS configuration:
    #   networking.networkmanager.enable = true;
    services = {
      bluetooth.enable = true;
      recorder.enable = true;
      audio.enable = true;
      network.enable = true;
    };

    # Enable Sass support
    sass = {
      enable = true;
      useDartSass = true;
    };

    # Extra packages available at runtime
    # These can be regular packages or Python packages
    extraPackages = with pkgs; [
      hello
      python313Packages.jinja2
      python313Packages.materialyoucolor
      python313Packages.pillow
    ];
  };

  home.packages = [

  ];

};}
