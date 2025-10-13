{ config, pkgs, lib, admin, ... }:

let

  cfg = config.my.user;

in

{

  options.my.user = {

    enable = lib.mkEnableOption "enable users";

    users = lib.mkOption {

      type = lib.types.listOf (lib.types.enum [

        admin
        "test"
        "root"
        "hello"
        "omarchy"

      ]);
      default = [ ];

    };

  };

  imports = [

    ./user.nix
    ./root.nix
    ./admin.nix
    ./test.nix
    ./hello.nix
    ./omarchy.nix

  ];

}
