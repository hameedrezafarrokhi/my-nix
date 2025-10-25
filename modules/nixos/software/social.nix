{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.social.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

    telegram-desktop              ##Telegram client (unofficial)

  ] ) config.my.software.social.exclude)

   ++

  config.my.software.social.include;

};}
