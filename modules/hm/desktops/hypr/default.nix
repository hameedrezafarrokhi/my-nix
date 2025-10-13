{ config, pkgs, lib, inputs, ... }:

let

  cfg = config.my.hypr;
  confPath = toString ./hyprland.conf;

 #ax-shell = pkgs.fetchFromGitHub {
 #  owner = "Axenide";
 #  repo = "Ax-Shell";
 #  rev = "d03c90516e6acac09e9edc424f8792fe3c250b4b";
 #  hash = "sha256-Lq9xZl/MNk2amr5T8od99OpoIE7eLJwAi1R8dYSuaGs=";
 #};

in

{

  options.my.hypr = {

    hyprland.enable = lib.mkEnableOption "hyprland";

  };

  config = lib.mkIf cfg.hyprland.enable {

    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
     #finalPackage = [object Object];
     #finalPortalPackage = [object Object];
      plugins = with pkgs.hyprlandPlugins; [
        hy3
       #hycov       # insecure
        hyprexpo
        hyprbars
       #hyprsplit   # WARNING BROKEN
       #hyprspace   # WARNING BROKEN
       #hyprgrass   # WARNING BROKEN
        hyprfocus
        hyprtrails
        hyprwinwrap
        hyprscrolling
       #csgo-vulkan-fix
        xtra-dispatchers
        borders-plus-plus
        hypr-dynamic-cursors
      ];
      xwayland.enable = true;
      systemd = {
        enable = true;
        enableXdgAutostart = true;
        extraCommands = [
          "systemctl --user stop hyprland-session.target"
          "systemctl --user start hyprland-session.target"
        ];
        variables = [ "--all" ];
      };
      sourceFirst = true;
      importantPrefixes = [
        "$"
        "bezier"
        "name"
        "source"
      ];
      settings = {
        source = [
          confPath
        ];
        bind = [
          "$mainMod, space, exec, $menu"
        ];
      };
     #extraConfig = '' '';
    };

    services = {

      hyprpolkitagent = {
        enable = true;
        package = pkgs.hyprpolkitagent;

      };

      hypridle = {
        enable = true;
        package = pkgs.hypridle;
        importantPrefixes = [
          "$"
          "bezier"
          "monitor"
          "size"
          "source"
        ];
       #settings = { };
      };

      hyprpaper = {
        enable = false;
        package = pkgs.hyprpaper;
        importantPrefixes = [
          "$"
          "bezier"
          "monitor"
          "size"
          "source"
        ];
       #settings = { };
      };

      hyprsunset = {
        enable = false;
        package = pkgs.hyprsunset;
        extraArgs = [ ];
        transitions = {
          sunrise = {
            calendar = "*-*-* 06:00:00";
            requests = [
              [ "temperature" "6500" ]
              [ "gamma 100" ]
            ];
          };
          sunset = {
            calendar = "*-*-* 19:00:00";
            requests = [
              [ "temperature" "3500" ]
            ];
          };
        };
      };

    };

    programs = {

      hyprlock = {
        enable = true;
        package = pkgs.hyprlock;
        sourceFirst = true;
        importantPrefixes = [
          "$"
          "bezier"
          "monitor"
          "size"
          "source"
        ];
       #settings = { };
       #extraConfig = '' '';
      };

      hyprpanel = {
        enable = true;
        package = pkgs.hyprpanel;
        systemd.enable = false;
        dontAssertNotificationDaemons = true;
       #settings = { };
      };

    };

    systemd.user.services = {

      hyprpanel-hyprland-hm = {
        Unit = {
          Description = "Bar/Panel for Hyprland with extensive customizability";
          Documentation = "https://hyprpanel.com/getting_started/hyprpanel.html";
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
          ConditionEnvironment = "DESKTOP_SESSION=hyprland";
          X-Restart-Triggers = lib.optional (config.programs.hyprpanel.settings != { }) "${config.xdg.configFile.hyprpanel.source}";
        };
        Service = {
          ExecStart = "${pkgs.hyprpanel}/bin/hyprpanel";
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
          Restart = "on-failure";
          KillMode = "mixed";
        };
        Install = {
          WantedBy = [ config.wayland.systemd.target ];
        };
      };

      hypridle = lib.mkForce {
        Unit = {
          ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=Hyprland";
          Description = "hypridle";
          After = [ config.wayland.systemd.target ];
          PartOf = [ config.wayland.systemd.target ];
          X-Restart-Triggers = lib.optional (config.services.hypridle.settings != { }) "${config.xdg.configFile."hypr/hypridle.conf".source}";
        };
        Service = {
          ExecStart = "${lib.getExe pkgs.hypridle}";
          Restart = "on-failure";
          RestartSec = "10";
        };
        Install = {
          WantedBy = [ config.wayland.systemd.target ];
        };
      };
    };

   #home.file.".local/share/fonts/tabler-icons.ttf" = {
   #  source = "${ax-shell}/assets/fonts/tabler-icons/tabler-icons.ttf";
   #};
   #
   #xdg.configFile = {
   #  ax-shell = {
   #    recursive = true;
   #    source = "${ax-shell}/";
   #    target = "Ax-Shell";
   #  };
   #
   #};

  };

  imports = [

    ./hyprland-noctalia.nix
    ./hyprland-caelestia.nix
    ./hyprland-uwsm.nix
    ./hyprland-dms.nix
    ./hyprland-ax.nix

  ];

}
