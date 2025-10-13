{ config, pkgs, lib, ... }:

let

  cfg = config.my.locale;
  cfg2 = config.my.timeZone;

in

{

  options.my.locale = lib.mkOption {

    type = lib.types.str;
    default = "en_US.UTF-8";

  };

  options.my.timeZone = lib.mkOption {

    type = lib.types.str;
    default = "Asia/Tehran";

  };

  options.my.geoclue.enable = lib.mkEnableOption "geoclue service";

  imports = [ ./geoclue.nix ];

  config = {

    # time zone.
    time = {
      timeZone = config.my.timeZone;
      hardwareClockInLocalTime = true;
    };

    # locale.
    i18n = {
      defaultLocale = config.my.locale;
      extraLocales = "all";      # (list of string) or value "all" (singular enum)
     #extraLocaleSettings = { }; # example: { LC_MESSAGES = "en_US.UTF-8"; LC_TIME = "de_DE.UTF-8"; }
      defaultCharset = "UTF-8";  # example "ISO-8859-8"
     #localeCharsets = {};      # example: { LC_MESSAGES = "ISO-8859-15"; LC_TIME = "ISO-8859-1"; }

     #inputMethod = {           # THIS IS ONLY FOR X WMS (CLASHES WITH KDE)
     #  type = "ibus";          # one of "ibus", "fcitx5", "nabi", "uim", "hime", "kime"
     #  enable = true;
     #  enableGtk3 = true;
     #  enableGtk2 = false;
     #  ibus = {
     #    panel = null;        # Replace the IBus panel with another panel.
     #    engines = with pkgs.ibus-engines; [ uniemoji ];
     #  };
     #};

    };

  };

}
