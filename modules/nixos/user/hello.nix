{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "test" config.my.user.users) {

  users = {

    users = {

      hello = {
       #password  initialPassword  hashedPassword  initialHashedPassword hashedPasswordFile
        isNormalUser = true;
        description = "hello";
        extraGroups = [ "networkmanager" "wheel" ];
      };

    };

  };

};}
