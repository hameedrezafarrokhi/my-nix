{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.software.social.enable) {

  environment.systemPackages = with pkgs; [

    telegram-desktop              ##Telegram client (unofficial)

  ];

};
}
