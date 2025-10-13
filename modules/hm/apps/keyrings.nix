{ config, pkgs, lib, ... }:

{
config = lib.mkIf (config.my.apps.keyrings.enable) {

  services.gnome-keyring = {
    enable = true;
    package = pkgs.gnome-keyring;
    components = [ ]; # list of (one of "pkcs11", "secrets", "ssh")
  };

};
}
