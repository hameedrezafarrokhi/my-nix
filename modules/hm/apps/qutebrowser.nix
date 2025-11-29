{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.qutebrowser.enable) {

  programs.qutebrowser = {

    enable = true;
    package = pkgs.qutebrowser;

    aliases = { };

    searchEngines = {

        "DEFAULT" = "https://www.google.com/?q={}";
        "aw" = "https://wiki.archlinux.org/?search={}";
        "gh" = "https://github.com/search?o=desc&q={}&s=stars";
        "y" = "https://www.youtube.com/results?search_query={}";

    };

    quickmarks = { };

    enableDefaultBindings = true;
    keyMappings = { };
    keyBindings = { };

   #greasemonkey = [ ];

    loadAutoconfig = false;

    settings = {

      auto_save = {
        session = true;
      };

      content = {
        blocking = {
          enabled = true;
        };
        webgl = false;
        canvas_reading = false;
        geolocation = false;
        webrtc_ip_handling_policy = "default-public-interface-only";
        cookies = {
          accept = "all";
          store = true;
        };
      };

      tabs = {
        show = "multiple";
        title = {
          format = "{audio}{current_title}";
        };
       #padding = {
       #  "top" = 5;
	 #  "bottom" = 5;
	 #  "left" = 9;
       #  "right" = 9;
	 #};
	  indicator = {
	    width = 0;
        };
        width = "7%";
      };

      fonts = {
        default_family = [ ];
        default_size = "11pt";
        web = {
          size = {
            default = 20;
	    };
	    family = {
	      fixed = "monospace";
	      sans_serif = "monospace";
	      serif = "monospace";
	      standard = "monospace";
	    };
	  };
      };

      completion = {
        open_categories = [ "searchengines" "quickmarks" "bookmarks" "history" "filesystem" ];
      };

      colors = {
        webpage = {
          darkmode = {
            enabled = true;
            algorithm = "lightness-cielab";
            policy = {
              images = "never";
            };
          };
        };
      };

    };

    perDomainSettings = { };

    extraConfig = ''

      # pylint: disable=C0111
      c = c  # noqa: F821 pylint: disable=E0602,C0103
      config = config  # noqa: F821 pylint: disable=E0602,C0103
      # pylint settings included to disable linting errors

      import subprocess
      def read_xresources(prefix):
          props = {}
          x = subprocess.run(['xrdb', '-query'], capture_output=True, check=True, text=True)
          lines = x.stdout.split('\n')
          for line in filter(lambda l : l.startswith(prefix), lines):
              prop, _, value = line.partition(':\t')
              props[prop] = value
          return props

      xresources = read_xresources("*")

      c.tabs.padding = {'top': 5, 'bottom': 5, 'left': 9, 'right': 9}

      config.set('colors.webpage.darkmode.enabled', False, 'file://*')

    '';

  };

};}
