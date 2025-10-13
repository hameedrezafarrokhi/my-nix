{ config, pkgs, lib, ... }:

let

  cfg = config.my.firefox;

in

{

  options.my.firefox.enable =  lib.mkEnableOption "firefox";

  config = lib.mkIf cfg.enable {

    programs = {
      firefox = {
        enable = false;
       #package = pkgs.firefox;
       #finalPackage = null;
       #enableGnomeExtensions = true;
        languagePacks = [ "en-US" "fa" ];
       #nativeMessagingHosts = [ ];
       #pkcs11Modules = [ ];
       #policies = { # example
       #  BlockAboutConfig = true;
       #  DefaultDownloadDirectory = "\${home}/Downloads";
       #  ExtensionSettings = {
       #    "uBlock0@raymondhill.net" = {
       #      default_area = "menupanel";
       #      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
       #      installation_mode = "force_installed";
       #      private_browsing = true;
       #    };
       #  };
       #}

        profiles = {

          me = {

           #name = "<name>";
           #path = "<name>"; # string to path of profile

            isDefault = true;
           #id = 0; # 0 becomes default

           #preConfig = "";
           #extraConfig = "";

           #userChrome = '' '';


            settings = { # exapmle
             #"browser.startup.homepage" = "https://nixos.org";
             #"browser.search.region" = "GB";
             #"browser.search.isUS" = false;
             #"distribution.searchplugins.defaultLocale" = "en-GB";
             #"general.useragent.locale" = "en-GB";
             #"browser.bookmarks.showMobileBookmarks" = true;
             #"browser.newtabpage.pinned" = [{
             #  title = "NixOS";
             #  url = "https://nixos.org";
             #}];
            };

            search = {
              force = false;
              order = [
                "google"
                "Nix Packages"
                "Nix Options"
                "NixOS Wiki"
              ];
              privateDefault = "ddg";
              engines = {
                nix-packages = {
                  name = "Nix Packages";
                  urls = [{
                    template = "https://search.nixos.org/packages";
                    params = [
                      { name = "type"; value = "packages"; }
                      { name = "query"; value = "{searchTerms}"; }
                    ];
                  }];

                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@np" ];
                };
                nix-options = {
                  name = "Nix Options";
                  urls = [{
                    template = "https://search.nixos.org/options";
                    params = [
                      { name = "type"; value = "options"; }
                      { name = "query"; value = "{searchTerms}"; }
                    ];
                  }];

                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@no" ];
                };
                nixos-wiki = {
                  name = "NixOS Wiki";
                  urls = [{ template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; }];
                  iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
                  definedAliases = [ "@nw" ];
                };

               #bing.metaData.hidden = true;
               #google.metaData.alias = "@g"; # builtin engines only support specifying one additional alias
              };
            };

            extensions = {
              force = false;
              packages = [
               #nurpkgs.repos.rycee.firefox-addons.ublock-origin
               #nurpkgs.repos.rycee.firefox-addons.ublock-origin-upstream
              ];
             #settings = {
             #  "uBlock0@raymondhill.net" = {
             #    force = false;
             #    permissions = [ "Any permissions" ]; # "activeTab"
             #    settings = {
             #      selectedFilterLists = [
             #        "ublock-filters"
             #        "ublock-badware"
             #        "ublock-privacy"
             #        "ublock-unbreak"
             #        "ublock-quick-fixes"
             #      ];
             #    };
             #};
            };

            bookmarks = {
              configFile = null;
              force = false;
              settings = [
                {
                  name = "wikipedia";
                  tags = [ "wiki" ];
                  keyword = "wiki";
                  url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
                }
                {
                  name = "kernel.org";
                  url = "https://www.kernel.org";
                }
                "separator"
                {
                  name = "Nix sites";
                  toolbar = true;
                  bookmarks = [
                    {
                      name = "homepage";
                      url = "https://nixos.org/";
                    }
                    {
                      name = "wiki";
                      tags = [ "wiki" "nix" ];
                      url = "https://wiki.nixos.org/";
                    }
                  ];
                }
              ];
            };

           #containers = { # example
           #  dangerous = {
           #    color = "red";
           #    icon = "fruit";
           #    id = 2;
           #  };
           #  shopping = {
           #    color = "blue";
           #    icon = "cart";
           #    id = 1;
           #  };
           #};

          };

        };

      };

      firefoxpwa = {
        enable = true;
        package = pkgs.firefoxpwa;

       #settings = { };

       #profiles = { # very confusing lol
       #
       #  "0123456789ABCDEFGHJKMNPQRSTVWXYZ".sites."ZYXWVTSRQPNMKJHGFEDCBA9876543210" = {
       #    name = "MDN Web Docs";
       #    url = "https://developer.mozilla.org/";
       #    manifestUrl = "https://developer.mozilla.org/manifest.f42880861b394dd4dc9b.json";
       #    desktopEntry.icon = pkgs.fetchurl {
       #      url = "https://developer.mozilla.org/favicon-192x192.png";
       #      sha256 = "0p8zgf2ba48l2pq1gjcffwzmd9kfmj9qc0v7zpwf2qd54fndifxr";
       #    };
       #  };
       #
       #};

      };

    };

  };

}
