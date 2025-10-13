{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "test" config.my.user.users) {

  users = {

    users = {

      test = {
       #password  initialPassword  hashedPassword  initialHashedPassword hashedPasswordFile
        isNormalUser = true;
        description = "test-user";
        extraGroups = [ "networkmanager" "wheel" ];
      };

    };

  };

};}
