{ config, pkgs, lib, ... }:

let

  cfg = config.my.kde;

in

{

  options.my.kde = {

    plasma.enable = lib.mkEnableOption "plasma";
    appletrc = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "nirvana" "blue" "red" ]);
      default = null;
    };
    kate.enable = lib.mkEnableOption "kate";
    konsole.enable = lib.mkEnableOption "konsole";
    elisa.enable = lib.mkEnableOption "elisa";
    ghostwriter.enable = lib.mkEnableOption "ghostwriter";
    okular.enable = lib.mkEnableOption "okular";
    wallpaper-engine.enable = lib.mkEnableOption "wallpaper-engine";

  };

  imports = [

    ./plasma.nix
    ./appletrc/nirvana/default.nix

    ./kate.nix
    ./konsole.nix
    ./elisa.nix
    ./ghostwriter.nix
    ./okular.nix
    ./wallpaper-engine.nix

  ];

}
