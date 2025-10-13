{ config, pkgs, lib, inputs, ... }:

let

  ax-shell = pkgs.fetchFromGitHub {
    owner = "Axenide";
    repo = "Ax-Shell";
    rev = "d03c90516e6acac09e9edc424f8792fe3c250b4b";
    hash = "sha256-Lq9xZl/MNk2amr5T8od99OpoIE7eLJwAi1R8dYSuaGs=";
  };

  fabric = pkgs.callPackage "${inputs.fabric}/default.nix" { };
 #run-widget =

in

{

  environment.systemPackages = with pkgs; [

    # ax shell
    gnome-bluetooth
    grimblast
   #nvtopPackages.full
    nvtopPackages.amd
   #nvtopPackages.nvidia
    tmux                     # add options later WARNING
    wlinhibit
    psutils
    gobject-introspection
    imagemagick
    libnotify
    playerctl
    swappy
    tesseract
    upower
    vte
    webp-pixbuf-loader

    (python3.withPackages (ps: with ps; [
       pygobject3
       numpy
       ijson
       pillow
       pywayland
       requests
       setproctitle
       toml
       watchdog
       fabric
       glib.dev
       glib.out
       gobject-introspection
       python-uinput
    ]))
    python313Packages.pygobject3
    python313Packages.numpy
    python313Packages.ijson
    python313Packages.pillow
    python313Packages.pywayland
    python313Packages.requests
    python313Packages.setproctitle
    python313Packages.toml
    python313Packages.watchdog
    (glib.override { withIntrospection = true; })

    (nur.repos.HeyImKyu.run-widget.override {
      extraPythonPackages = with python3Packages; [
        ijson
        pillow
        psutil
        requests
        setproctitle
        toml
        watchdog
        thefuzz
        numpy
        chardet
      ];
      extraBuildInputs = [
        nur.repos.HeyImKyu.fabric-gray
        networkmanager
        networkmanager.dev
        playerctl
        vte
      ];
    })

    nur.repos.HeyImKyu.fabric-cli

  ]
 #++ [ fabric ]
  ++ [ inputs.gray.packages.${system}.default ]
  ;

  home-manager.users.user.hrf = {

    home.file.".local/share/fonts/tabler-icons.ttf" = {
      source = "${ax-shell}/assets/fonts/tabler-icons/tabler-icons.ttf";
    };

    xdg.configFile = {
      ax-shell = {
        recursive = true;
        source = "${ax-shell}/";
        target = "Ax-Shell";
      };

    };

  };

}
