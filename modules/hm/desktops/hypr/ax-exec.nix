{ config, pkgs, lib, nix-path, ... }:

with lib;

let
  cfg = config.programs.ax-shell;
  matugenTOMLFormat = pkgs.formats.toml { };

  paths = {
    configDir = "${config.xdg.configHome}/ax-shell";
    wallpaperFile = "${paths.configDir}/current.wall";
    faceIconFile = "${paths.configDir}/face.icon";
    hyprlandColorsConf = "${paths.configDir}/config/hypr/colors.conf";
    axShellColorsCss = "${paths.configDir}/styles/colors.css";
    defaultWallpaper = "${cfg.package}/share/ax-shell/assets/wallpapers_example/example-1.jpg";
    matugenConfig = "${config.xdg.configHome}/matugen/config.toml";
  };

  binaries = {
    axSend = "${pkgs.ax-send}/bin/ax-send";
    matugen = "${pkgs.matugen}/bin/matugen";
    uwsm = "${pkgs.uwsm}/bin/uwsm-app";
  };

  configs = {
    matugenDefault = {
      config = {
        reload_apps = true;
        wallpaper = {
          command = "swww";
          arguments = [ "img" "-t" "fade" "--transition-duration" "0.5" "--transition-step" "255" "--transition-fps" "60" "-f" "Nearest" ];
          set = true;
        };
        custom_colors = {
          red = { color = "#FF0000"; blend = true; };
          green = { color = "#00FF00"; blend = true; };
          yellow = { color = "#FFFF00"; blend = true; };
          blue = { color = "#0000FF"; blend = true; };
          magenta = { color = "#FF00FF"; blend = true; };
          cyan = { color = "#00FFFF"; blend = true; };
          white = { color = "#FFFFFF"; blend = true; };
        };
      };
      templates = {
        hyprland = {
          input_path = "${cfg.package}/share/ax-shell/config/matugen/templates/hyprland-colors.conf";
          output_path = paths.hyprlandColorsConf;
        };
        "ax-shell" = {
          input_path = "${cfg.package}/share/ax-shell/config/matugen/templates/ax-shell.css";
          output_path = paths.axShellColorsCss;
          post_hook = "${binaries.axSend} reload_css &";
        };
      };
    };
    axShellJson = settings:
      pkgs.writeText "ax-shell-config.json"
        (builtins.toJSON (
          {
            wallpapers_dir = settings.wallpapersDir;
            terminal_command = settings.terminalCommand;
            datetime_12h_format = settings.datetime12hFormat;
            bar_position = settings.bar.position;
            centered_bar = settings.bar.centered;
            bar_theme = settings.bar.theme;
            bar_workspace_show_number = settings.bar.workspace.showNumber;
            bar_workspace_use_chinese_numerals = settings.bar.workspace.useChineseNumerals;
            bar_hide_special_workspace = settings.bar.workspace.hideSpecial;
            bar_metrics_disks = settings.bar.metrics.disks;
            bar_button_apps_visible = settings.bar.components.button_apps;
            bar_systray_visible = settings.bar.components.systray;
            bar_control_visible = settings.bar.components.control;
            bar_network_visible = settings.bar.components.network;
            bar_button_tools_visible = settings.bar.components.button_tools;
            bar_sysprofiles_visible = settings.bar.components.sysprofiles;
            bar_button_overview_visible = settings.bar.components.button_overview;
            bar_ws_container_visible = settings.bar.components.ws_container;
            bar_battery_visible = settings.bar.components.battery;
            bar_metrics_visible = settings.bar.components.metrics;
            bar_language_visible = settings.bar.components.language;
            bar_date_time_visible = settings.bar.components.date_time;
            bar_button_power_visible = settings.bar.components.button_power;
            dock_enabled = settings.dock.enable;
            dock_always_occluded = settings.dock.alwaysOccluded;
            dock_icon_size = settings.dock.iconSize;
            dock_theme = settings.dock.theme;
            panel_theme = settings.panel.theme;
            panel_position = settings.panel.position;
            corners_visible = settings.cornersVisible;
            notif_pos = settings.notifications.position;
            limited_apps_history = settings.notifications.limitedAppsHistory;
            history_ignored_apps = settings.notifications.historyIgnoredApps;
            metrics_visible = settings.metrics.main;
            metrics_small_visible = settings.metrics.small;
            dashboard_components_visibility = {
              widgets = settings.dashboard.components.widgets;
              pins = settings.dashboard.components.pins;
              kanban = settings.dashboard.components.kanban;
              wallpapers = settings.dashboard.components.wallpapers;
              mixer = settings.dashboard.components.mixer;
            };
          }
          // (
            let
              prefixes = mapAttrs' (n: v: nameValuePair "prefix_${n}" v.prefix) settings.keybindings;
              suffixes = mapAttrs' (n: v: nameValuePair "suffix_${n}" v.suffix) settings.keybindings;
            in
            prefixes // suffixes
          )
        ));
  };

  wrappedPackage =
    let
      generatedMainCss = pkgs.writeTextFile {
        name = "main-generated.css";
        text =
          let
            originalContent = builtins.readFile "${cfg.package}/share/ax-shell/main.css";
            packageStylesPath = "${cfg.package}/share/ax-shell/styles";
            absoluteColorsImport = ''@import url("${paths.axShellColorsCss}");'';
            contentWithAbsolutePaths =
              lib.replaceStrings (lib.mapAttrsToList (n: _: ''./styles/${n}'') (builtins.readDir packageStylesPath))
                (lib.mapAttrsToList (n: _: ''${packageStylesPath}/${n}'') (builtins.readDir packageStylesPath))
                originalContent;
          in
          "${absoluteColorsImport}\n${contentWithAbsolutePaths}";
      };
    in
    pkgs.symlinkJoin {
      name = "ax-shell-with-declarative-config";
      paths = [ cfg.package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/ax-shell \
          --set AX_SHELL_CONFIG_FILE "${configs.axShellJson cfg.settings}" \
          --set AX_SHELL_STYLESHEET_FILE "${generatedMainCss}" \
          --set AX_SHELL_MATUGEN_BIN "${binaries.matugen}" \
          --set XCURSOR_THEME "${cfg.settings.cursor.theme}" \
          --set XCURSOR_SIZE "${toString cfg.settings.cursor.size}" \
          --prefix XCURSOR_PATH : "${cfg.settings.cursor.package}/share/icons"
      '';
    };

  scripts = {
   #runner = pkgs.writeShellScriptBin "ax-shell-run" ''
   #  #!${pkgs.bash}/bin/bash
   #  mkdir -p "$(dirname "${cfg.autostart.logPath}")"
   #  exec ${wrappedPackage}/bin/ax-shell &> "${cfg.autostart.logPath}"
   #'';

    runner = pkgs.writeShellScriptBin "ax-shell-run" ''
      #!${pkgs.bash}/bin/bash
      exec ${wrappedPackage}/bin/ax-shell
    '';

    reload = pkgs.writeShellApplication {
      name = "ax-shell-reload";
      runtimeInputs = [ pkgs.procps pkgs.psmisc ];
      text = ''
        #!${pkgs.stdenv.shell}
        killall ax-shell
        while pgrep -x ax-shell >/dev/null; do
            sleep 0.1
        done
        ${binaries.uwsm} -- ${scripts.runner}/bin/ax-shell-run
      '';
    };

    themeInit = pkgs.writeShellScript "matugen-initial-gen" ''
      HYPR_COLORS_PATH="${paths.hyprlandColorsConf}"
      CSS_COLORS_PATH="${paths.axShellColorsCss}"
      CURRENT_WALL_PATH="${paths.wallpaperFile}"
      DEFAULT_WALLPAPER="${paths.defaultWallpaper}"

      if [ ! -L "$CURRENT_WALL_PATH" ] || [ ! -e "$CURRENT_WALL_PATH" ]; then
        echo "Ax-Shell: current.wall is missing or broke. Re-linking and setting default wallpaper."
        mkdir -p "$(dirname "$CURRENT_WALL_PATH")"
        rm -f "$CURRENT_WALL_PATH"
        ln -s "$DEFAULT_WALLPAPER" "$CURRENT_WALL_PATH"
        ${binaries.matugen} image "$CURRENT_WALL_PATH"
      fi

      if [ ! -f "$HYPR_COLORS_PATH" ] || [ ! -f "$CSS_COLORS_PATH" ]; then
        echo "Ax-Shell: Color scheme not found. Generating from wallpaper."
        mkdir -p "$(dirname "$HYPR_COLORS_PATH")" "$(dirname "$CSS_COLORS_PATH")"
        ${binaries.matugen} image "$CURRENT_WALL_PATH"
      fi
    '';
  };

  my-ax-run = pkgs.writeShellScriptBin "my-ax-run" ''
    ${scripts.themeInit}
    ${binaries.uwsm} -- ${scripts.runner}/bin/ax-shell-run
    wl-paste --type text --watch cliphist store
    wl-paste --type image --watch cliphist store
  '';

in
{

  home.packages = [ my-ax-run ];

  xdg.configFile = {

    ax-conf = {
      target = "hypr/hyprland-ax.conf";
      text = ''
        source = ${nix-path}/modules/hm/desktops/hypr/hyprland.conf
        exec-once = ${binaries.uwsm} -- ${scripts.runner}/bin/ax-shell-run
        exec-once = ${scripts.themeInit}
      '';
    };

  };

}
