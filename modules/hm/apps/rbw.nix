{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.rbw.enable) {

  programs.rbw = {
    enable = true;
    package = pkgs.rbw;
    settings = {
      pinentry = pkgs.pinentry-qt;
      lock_timeout = 3600;
      email = config.programs.git.settings.user.email;
     #email = "hameedrezafarrokhi@gmail.com";
     #base_url = "https://vault.bitwarden.com/#/vault";
     #identity_url = "https://vault.bitwarden.com/#/vault";
    };
  };

};}
