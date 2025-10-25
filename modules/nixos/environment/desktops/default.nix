{ config, pkgs, lib, ... }:

let

  cfg = config.my.desktops;

  cinnamon-gsettings-overrides = pkgs.cinnamon-gsettings-overrides.override {
    extraGSettingsOverridePackages = config.services.xserver.desktopManager.cinnamon.extraGSettingsOverridePackages;
    extraGSettingsOverrides = config.services.xserver.desktopManager.cinnamon.extraGSettingsOverrides;
  };

  budgie-gsettings-overrides = pkgs.budgie-gsettings-overrides.override {
    inherit (config.services.xserver.desktopManager.budgie) extraGSettingsOverrides extraGSettingsOverridePackages;
    inherit nixos-background-dark nixos-background-light;
  };
  nixos-background-light = pkgs.nixos-artwork.wallpapers.nineish;
  nixos-background-dark = pkgs.nixos-artwork.wallpapers.nineish-dark-gray;

  pantheon-gsettings-overrides = pkgs.pantheon.elementary-gsettings-schemas.override {
    extraGSettingsOverridePackages = config.services.desktopManager.pantheon.extraGSettingsOverridePackages;
    extraGSettingsOverrides = config.services.desktopManager.pantheon.extraGSettingsOverrides;
  };

in

{

  options.my.desktops = lib.mkOption {

     type = lib.types.listOf (lib.types.enum [

       "plasma"
       "cosmic"
       "lxqt"
       "xfce"
       "cinnamon"
       "mate"
       "budgie"
       "lumina"
       "enlightenment"
       "retroarch"
       "gnome"
       "pantheon"
       "cde"
       "retroarch"

     ]);
     default = [ ];
  };

  options.my.default-gnome-based-de = lib.mkOption {

     type = lib.types.nullOr (lib.types.enum [

       "cinnamon"
       "mate"
       "budgie"
       "gnome"
       "pantheon"

     ]);
     default = null;
  };

  imports = [

    ./plasma.nix
    ./cosmic.nix
    ./lxqt.nix
    ./xfce.nix
    ./cinnamon.nix
    ./mate.nix
    ./lumina.nix
    ./budgie.nix
    ./retroarch.nix
    ./gnome.nix
    ./enlightenment.nix
    ./pantheon.nix
    ./cde.nix

  ];

  config =

    (lib.mkIf (config.my.default-gnome-based-de != null) { environment.sessionVariables = lib.mkMerge [

      # For Gnome Based DEs to Co-Exist, they have the same freakin line
      # gnome.nixos-gsettings-overrides, mate.mate-gsettings-overrides, cinnamon-gsettings-overrides, budgie-gsettings-overrides

      # GNOME (breaks Budgie, Cinnamon OK, MATE bad borders)
      (lib.mkIf (config.my.default-gnome-based-de == "gnome") { NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce "${pkgs.gnome.nixos-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";})

      # Budgie (i think budgie doesnt work properly with sddm, crashes (only works correct with lightdm and startx))
      (lib.mkIf (config.my.default-gnome-based-de == "budgie") { NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce "${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";})

      # Cinnamon (cinnamon(env) session works pretty fine with anything)
      (lib.mkIf (config.my.default-gnome-based-de == "cinnamon") { NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce "${cinnamon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";})

      # MATE (same problem as budgie (only works correct with lightdm and startx) but doesnt crash, bad borders )
      (lib.mkIf (config.my.default-gnome-based-de == "mate") { NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce "${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";})

      (lib.mkIf (config.my.default-gnome-based-de == "pantheon") { NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce "${pantheon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";})

    ];})

  ;

}

   # NOT WORKING

   #environment.loginShellInit = ''
   #  # Reset variable
   #  unset NIX_GSETTINGS_OVERRIDES_DIR
   #
   #  # Detect session
   #  if pgrep "cinnamon" >/dev/null 2>&1; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="/run/current-system/sw/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas/cinnamon"
   #  elif pgrep "mate" >/dev/null 2>&1; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="/run/current-system/sw/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas/mate"
   #  elif pgrep "budgie" >/dev/null 2>&1; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="/run/current-system/sw/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas/budgie"
   #  fi
   #
   #  # Optional: print result for debugging
   #  #echo "NIX_GSETTINGS_OVERRIDES_DIR=$NIX_GSETTINGS_OVERRIDES_DIR"
   #'';

   #environment.loginShellInit = ''
   #  # Detect session
   #  if [[ $XDG_CURRENT_DESKTOP == "X-Cinnamon" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${cinnamon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $CINNAMON_VERSION == "6.4.13" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${cinnamon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $XDG_CURRENT_DESKTOP == "MATE" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $MATE_PANEL_EXTRA_MODULES == "/nix/store/46h8bn62vn0y0ik7m6b6hyfsl10cxy1f-mate-panel-with-applets-1.28.6/lib/mate-panel/applets" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $XDG_CURRENT_DESKTOP == "Budgie:GNOME" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $XDG_CURRENT_DESKTOP == "Budgie" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $BUDGIE_PLUGIN_DATADIR == "/nix/store/g4fsbq7k1va8f0zqy0832gwynlhm2v3f-budgie-desktop-with-plugins-10.9.2/share/budgie-desktop/plugins" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  fi
   #'';

   #environment.shellInit = ''
   #  # Detect session
   #  if [[ $XDG_CURRENT_DESKTOP == "X-Cinnamon" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${cinnamon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $CINNAMON_VERSION == "6.4.13" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${cinnamon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $XDG_CURRENT_DESKTOP == "MATE" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $MATE_PANEL_EXTRA_MODULES == "/nix/store/46h8bn62vn0y0ik7m6b6hyfsl10cxy1f-mate-panel-with-applets-1.28.6/lib/mate-panel/applets" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $XDG_CURRENT_DESKTOP == "Budgie:GNOME" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $XDG_CURRENT_DESKTOP == "Budgie" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $BUDGIE_PLUGIN_DATADIR == "/nix/store/g4fsbq7k1va8f0zqy0832gwynlhm2v3f-budgie-desktop-with-plugins-10.9.2/share/budgie-desktop/plugins" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  fi
   #'';

   #environment.extraInit = ''
   #  # Detect session
   #  if [[ $XDG_CURRENT_DESKTOP == "X-Cinnamon" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${cinnamon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $CINNAMON_VERSION == "6.4.13" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${cinnamon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $XDG_CURRENT_DESKTOP == "MATE" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $MATE_PANEL_EXTRA_MODULES == "/nix/store/46h8bn62vn0y0ik7m6b6hyfsl10cxy1f-mate-panel-with-applets-1.28.6/lib/mate-panel/applets" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $XDG_CURRENT_DESKTOP == "Budgie:GNOME" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $XDG_CURRENT_DESKTOP == "Budgie" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  elif [[ $BUDGIE_PLUGIN_DATADIR == "/nix/store/g4fsbq7k1va8f0zqy0832gwynlhm2v3f-budgie-desktop-with-plugins-10.9.2/share/budgie-desktop/plugins" ]]; then
   #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
   #  fi
   #'';



