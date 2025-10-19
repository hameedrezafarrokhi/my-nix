{ config, pkgs, lib, inputs, system, ... }:

let

  waybar-bluetooth-control = pkgs.writeShellScriptBin "waybar-bluetooth-control" ''
  if bluetoothctl show | grep -q "Powered: yes"; then
      bluetoothctl power off
  else
      bluetoothctl power on
  fi
  '';

in

{ config = lib.mkIf (builtins.elem "waybar" config.my.bar-shell.shells) {

  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    systemd = {
      enable = true;
      target = config.wayland.systemd.target;
      enableInspect = false;
      enableDebug = false;
    };

    settings = {

      mainBar = {
        layer = "top";
        position = "top";
        height = 24;
        margin = "0px 0px 0px 0px";
       #output = [
       #  "eDP-1"
       #  "HDMI-A-1"
       #];
        modules-left = ["ext/workspaces" "hyprland/workspaces" "sway/workspaces" "niri/window" "hyprland/window" "sway/window" "dwl/window"]; #  "wlr/taskbar" "dwl/tags" "sway/mode" "niri/workspaces"
       #modules-center = [ "sway/window" "custom/hello-from-waybar" ];
        modules-right = ["custom/tempicon" "temperature" "custom/diskicon" "disk" "custom/cpuicon" "cpu" "custom/memoryicon" "memory" "pulseaudio" "tray" "custom/notification" "idle_inhibitor" "custom/clockicon" "clock"]; # "bluetooth"

        "ext/workspaces" = {
          format = "{icon}";
          active-only = false;
          sort-by-number = true;
          on-click = "activate";
          all-outputs = false;
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
          };
        };

        "niri/workspaces" = {
          format = "{icon}";
          active-only = false;
          sort-by-number = false;
          on-click = "activate";
          all-outputs = false;
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            "11" = "11";
            "12" = "12";
          };
        };
        "hyprland/workspaces" = {
          format = "{icon}";
          active-only = false;
          sort-by-number = false;
          on-click = "activate";
          all-outputs = false;
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            "11" = "11";
            "12" = "12";
          };
        };
        "sway/workspaces" = {
          format = "{icon}";
          active-only = false;
          sort-by-number = false;
          on-click = "activate";
          all-outputs = false;
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            "11" = "11";
            "12" = "12";
          };
        };
       #"ext/workspaces" = {
       #  format = "{icon}";
       #  ignore-hidden = true;
       #  on-click = "activate";
       #  on-click-right = "deactivate";
       #  sort-by-id = true;
       #};
        "dwl/tags" = {
          "num-tags" = 9;
        };
        "dwl/window" = {
          format = "{title}";
          max-length = 333;
          seperate-outputs = true;
        };
       #"sway/workspaces" = {
       #  disable-scroll = true;
       #  all-outputs = true;
       #};
        "niri/window" = {
          format = "{title}";
          max-length = 333;
          seperate-outputs = true;
        };
        "sway/window" = {
          format = "{title}";
          max-length = 333;
          seperate-outputs = true;
        };
        "hyprland/window" = {
          format = "{title}";
          max-length = 333;
          seperate-outputs = true;
        };
        "wlr/taskbar" = {
          format = "{name}";
          icon-size = 14;
          icon-theme = "Numix-Circle";
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-middle = "close";
          ignore-list = [ "Alacritty" ];
          app_ids-mapping = {
            firefoxdeveloperedition = "firefox-developer-edition";
          };
          rewrite = {
            "Firefox Web Browser" = "Firefox";
            "Foot Server" = "Terminal";
          };
        };
        "custom/clockicon" = {
          format = "";
          markup = "pango";
        };
        "clock" = {
          format = "{:%I:%M %a %d}";
          tooltip-format = "{calendar}";
          calendar = {
            mode  = "month";
            mode-mon-col = 3;
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>{%W}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b>{}</b></span>";
            };
          };
          actions = {
            on-click-middle = "mode";
            on-click-right = "shift_up";
            on-click = "shift_down";
          };
        /*"format-alt": "<span foreground='#89dceb'> </span><span>{:%H:%M}</span>"*/
        };
        "custom/cpuicon" = {
          format = "";
          markup = "pango";
        };
        "cpu" = {
          format = "{usage}%";
        };
        "custom/memoryicon" = {
          format = "󰍛";
          markup = "pango";
        };
        "memory" = {
          format = "{}%";
          interval = 1;
        };
        "custom/gpu-util" = {
          exec = "./scripts/gpu-util";
          format = "<span foreground='#67b0e8'>󰯿</span> {}";
          interval = 1;
        };
        "custom/gpu-temp" = {
          exec = "./scripts/gpu-temp";
          format = "<span foreground='#e57474'></span> {}";
          interval = 1;
        };
        "custom/tempicon" = {
          format = "";
          markup = "pango";
        };
        "temperature" = {
          hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
          critical-threshold = 80;
          format = "{temperatureC}°C";
          interval = 1;
        };
        "network" = {
          format = "󰤭 Off";
          format-wifi = "{essid} ({signalStrength}%)";
          format-ethernet = "<span foreground='#b48ead'>󰈀</span>";
          format-disconnected = "󰤭 Disconnected";
          tooltip-format = "{ifname} via {gwaddr} ";
          tooltip-format-wifi = "{essid}({signalStrength}%)  ";
          tooltip-format-ethernet = "󰈀 {ifname}";
          tooltip-format-disconnected = "Disconnected";
        };
        "pulseaudio" = {
          format = "{icon} {volume}%  {format_source}";
          format-bluetooth = "{icon} {volume}%  {format_source}";
          format-bluetooth-muted = "<span foreground='#D699B6'>󰖁</span>  {format_source}";
          format-muted = "<span foreground='#7A8478'>󰖁</span>  {format_source}";
          format-source = " {volume}%";
          format-source-muted = "<span foreground='#F38BA8'></span>";
          format-icons = {
            headphone = "";
            phone = "";
            portable = "";
            default = ["" "" ""];
          };
          on-click-left = "pavucontrol";
          input = true;
        };
        "custom/playerctl" = {
          format = "{icon}  <span>{}</span>";
          return-type = "json";
          max-length = 333;
          exec = ''playerctl -a metadata --format '{\"text\": \"{{artist}} ~ {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          on-click-middle = "playerctl play-pause'';
          on-click = "playerctl previous";
          on-click-right = "playerctl next";
          format-icons = {
            Playing = "<span foreground='#98BB6C'></span>";
            Paused = "<span foreground='#E46876'></span>";
          };
        };
        "tray" = {
          format = "<span foreground='#D3C6AA'>{icon}</span>";
          icon-size = 14;
          spacing = 5;
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "󰅶";
            deactivated = "󰛊";
          };
        };
        "custom/diskicon" = {
          format = "";
          markup = "pango";
        };
        "disk" = {
          interval = 30;
          format = "{percentage_free}% ";
          path = "/";
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };
        "bluetooth" = {
          on-click = "./scripts/bluetooth-control";
          on-click-right = "./scripts/rofi-bluetooth";
          on-click-middle = "./scripts/rofi-bluetooth";
          format = "{icon}";
          interval = 15;
          format-icons = {
            on = "<span foreground='#43242B'></span>";
            off = "<span foreground='#76946A'>󰂲</span>";
            disabled = "󰂲";
            connected = "";
          };
          tooltip-format = "{device_alias} {status}";
        };
      };

    };

    style = lib.mkAfter ''
      tooltip {
        background: @crust;
        border: 2px solid @subtext0;
      }

      #window {
      	margin: 0px 5px 0px 5px;
      	padding-left: 10px;
      	padding-right: 7px;
      	background-color: @base;
      	color: @subtext1;
      }

      window#waybar.empty #window {
      	background-color: transparent;
      	border-bottom: none;
      	border-right: none;
      }

      window#waybar {
        background-color:@base;
        color: @flamingo;
      }

      /* Workspaces */

      #workspaces {
        margin: 0px 0px 0px 0px;
        padding: 0px;
        background-color: @base;
        color: @rosewater;

      }

      #workspaces button {
        margin: 0px 0px 0px 0px;
        padding-left: 3px;
        padding-right: 9px;
        background-color: @base;
        color: @text;
      }

      #workspaces button.active {
      	padding: 0 2px 0 1px;
          color: @sapphire;
      }

      #workspaces button.urgent {
      	color: @red;
      }

      #custom-gpu-util {
        margin: 0px 5px 0px 5px;
        padding-left: 10px;
        padding-right: 10px;
        background-color: @base;
        color: @text;
      }

      #tray {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 10px;
        background-color: @base;
        color: @text;
      }

      #idle_inhibitor {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 12px;
        background-color: @base;
        color: @text;
      }

      #idle_inhibitor.activated {
        color: @mauve;
      }

      #network {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 12px;
        background-color: @base;
        color: @rosewater;
      }

      #network.linked {
        color: @green;
      }
      #network.disconnected,
      #network.disabled {
        color: @red;
      }

      #custom-cliphist {
      	color: @rosewater;
      	margin: 0px 5px 0px 5px;
          padding-left: 10px;
          padding-right: 12px;
          background-color: @base;

      }

      #custom-gpu-temp,
      #custom-clipboard {
        margin: 0px 5px 0px 5px;
        padding-left: 10px;
        padding-right: 10px;
        color: @text;
        background-color: @base;
      }

      #cpu {
        margin: 0px 0px 0px 0px;
        padding-left: 6px;
        padding-right: 6px;
        color: @text;
        background-color: @base;
      }

      #custom-cpuicon {
        margin: 0px 0px 0px 0px;
        padding: 0px 10px 0px 10px;
        color: @sapphire;
        background-color: @base;
      }

      #custom-diskicon {
        margin: 0px 0px 0px 0px;
        padding: 0 10px 0 10px;
        color: @flamingo;
        background-color: @base;
      }

      #disk {
        margin: 0px 0px 0px 0;
        padding-left: 0px;
        padding-right: 0px;
        color: @test;
        background-color: @base;
      }

      #custom-notification {
      background-color: @base;
      color: @overlay2;
      padding: 0 12px;
      margin-right: 0px;
      font-size: 14px;
      font-family: "JetBrainsMono Nerd Font";
      }

      #custom-memoryicon {
        margin: 0px 0px 0px 0px;
        color: @mauve;
        padding: 0 11px 0 7px;
        background-color: @base;
      }

      #memory {
        margin: 0px 0px 0px 0px;
        padding-left: 5px;
        padding-right: 10px;
        color: @text;
        background-color: @base;
      }

      #custom-tempicon {
        margin: 0px 0px 0px 0px;
        color: @peach;
        padding: 0 11px 0 8px;
        background-color: @base;
      }

      #temperature {
        margin: 0px 0px 0px 0px;
        padding-left: 5px;
        padding-right: 10px;
        color: @lavender;
        background-color: @base;
      }


      #custom-playerctl {
        margin: 0px 5px 0px 5px;
        padding-left: 10px;
        padding-right: 10px;
        color: @text;
        background-color: @base;
      }

      #battery,
      #backlight,
      #bluetooth,
      #pulseaudio {
        margin-top: 0px;
        margin-bottom: 0px;
        color: @blue;
        background-color: @base;
      }

      #pulseaudio {
        margin-top: 0px;
        margin-bottom: 0px;
        color: @blue;
        background-color: @base;
      }

      #battery,
      #bluetooth {
      	margin-left: 0px;
      	margin-right: 0px;
      	padding-left: 0px;
      	padding-right: 2px;
      }

      #backlight,
      #pulseaudio {
      	margin-right: 0px;
      	margin-left: 0px;
      	padding-left: 10px;
        	padding-right: 7.5px;
            color: @blue;
            background-color: @base;
      }

      #clock {
        margin: 0px 0px 0px 0px;
        padding-left: 10px;
        padding-right: 10px;
        color: @maroon;
        background-color: @base;
      }

      #custom-clockicon {
        margin: 0px 0 0px 0px;
        color: @maroon;
        padding: 0 5px 0 10px;
        background-color: @base;
        color: @maroon;
      }

      #taskbar {
          padding: 0 3px;
          margin: 0 0px;
          color: @subtext1;
          background-color: rgba(120,118,117,0.3);
      }
      #taskbar button {
          padding: 0 0 0 3px;
          margin: 0px 0px;
          color: @subtext0;
          background-color: rgba(120,118,117,0.1);
      }
      #taskbar button.active {
          background-color: rgba(120,118,117,0.8);
      }

      #mode {
        margin: 0px 5px 0px 5px;
        padding-left: 10px;
        padding-right: 10px;
        background-color: @base;
        color: @green;
      }

    '';

  };

  systemd.user.services.waybar.Unit.ConditionEnvironment = lib.mkForce "DESKTOP_SESSION=niri";

 #systemd.user.services.waybar-niri = {
 #  Unit = {
 #    Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
 #    Documentation = "https://github.com/Alexays/Waybar/wiki";
 #    PartOf = [
 #      config.programs.waybar.systemd.target
 #      "tray.target"
 #    ];
 #    After = [ config.programs.waybar.systemd.target ];
 #    ConditionEnvironment = "DESKTOP_SESSION=niri";
 #    X-Reload-Triggers =
 #      lib.optional (config.programs.waybar.settings != [ ]) "${config.xdg.configFile."waybar/config".source}"
 #      ++ lib.optional (config.programs.waybar.style != null) "${config.xdg.configFile."waybar/style.css".source}";
 #  };
 #
 #  Service = {
 #    Environment = lib.optional config.programs.waybar.systemd.enableInspect "GTK_DEBUG=interactive";
 #    ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
 #    ExecStart = "${config.programs.waybar.package}/bin/waybar${lib.optionalString config.programs.waybar.systemd.enableDebug " -l debug"}";
 #    KillMode = "mixed";
 #    Restart = "on-failure";
 #  };
 #
 #  Install.WantedBy = [
 #    config.programs.waybar.systemd.target
 #    "tray.target"
 #  ];
 #};

 #systemd.user.services.waybar-sway = {
 #  Unit = {
 #    Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
 #    Documentation = "https://github.com/Alexays/Waybar/wiki";
 #    PartOf = [
 #      config.programs.waybar.systemd.target
 #      "tray.target"
 #    ];
 #    After = [ config.programs.waybar.systemd.target ];
 #    ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";
 #    X-Reload-Triggers =
 #      lib.optional (config.programs.waybar.settings != [ ]) "${config.xdg.configFile."waybar/config".source}"
 #      ++ lib.optional (config.programs.waybar.style != null) "${config.xdg.configFile."waybar/style.css".source}";
 #  };
 #
 #  Service = {
 #    Environment = lib.optional config.programs.waybar.systemd.enableInspect "GTK_DEBUG=interactive";
 #    ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
 #    ExecStart = "${config.programs.waybar.package}/bin/waybar${lib.optionalString config.programs.waybar.systemd.enableDebug " -l debug"}";
 #    KillMode = "mixed";
 #    Restart = "on-failure";
 #  };
 #
 #  Install.WantedBy = [
 #    config.programs.waybar.systemd.target
 #    "tray.target"
 #  ];
 #};

 #systemd.user.services.waybar-mango = {
 #  Unit = {
 #    Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
 #    Documentation = "https://github.com/Alexays/Waybar/wiki";
 #    PartOf = [
 #      config.programs.waybar.systemd.target
 #      "tray.target"
 #    ];
 #    After = [ config.programs.waybar.systemd.target ];
 #    ConditionEnvironment = "XDG_CURRENT_DESKTOP=mango";
 #    X-Reload-Triggers =
 #      lib.optional (config.programs.waybar.settings != [ ]) "${config.xdg.configFile."waybar/config".source}"
 #      ++ lib.optional (config.programs.waybar.style != null) "${config.xdg.configFile."waybar/style.css".source}";
 #  };
 #
 #  Service = {
 #    Environment = lib.optional config.programs.waybar.systemd.enableInspect "GTK_DEBUG=interactive";
 #    ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
 #    ExecStart = "${config.programs.waybar.package}/bin/waybar${lib.optionalString config.programs.waybar.systemd.enableDebug " -l debug"}";
 #    KillMode = "mixed";
 #    Restart = "on-failure";
 #  };
 #
 #  Install.WantedBy = [
 #    config.programs.waybar.systemd.target
 #    "tray.target"
 #  ];
 #};


};}
