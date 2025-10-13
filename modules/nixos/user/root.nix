{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "root" config.my.user.users) {

  users = {

    users = {

      root = {
       #hashedPassword = ;
      };

    };

  };

};}
