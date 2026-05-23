{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.moonwm;
  moonwm-helper = pkgs.writeShellScriptBin "moonwm-helper" ''
    ${builtins.readFile ./moonwm/scripts/moonwm-helper}
  '';
  moonwm-menu = pkgs.writeShellScriptBin "moonwm-menu" ''
    ${builtins.readFile ./moonwm/scripts/moonwm-menu}
  '';
  moonwm-status = pkgs.writeShellScriptBin "moonwm-status" ''
    ${builtins.readFile ./moonwm/scripts/moonwm-status}
  '';
  moonwm-utils = pkgs.writeShellScriptBin "moonwm-utils" ''
    ${builtins.readFile ./moonwm/scripts/moonwm-utils}
  '';
  swallow = pkgs.writeShellScriptBin "swallow" ''
    ${builtins.readFile ./moonwm/scripts/swallow}
  '';
  moonwm = pkgs.callPackage ./moonwm.nix {

   moonwm-helper = moonwm-helper;
   moonwm-menu = moonwm-menu;
   moonwm-utils = moonwm-utils;
   moonwm-status = moonwm-status;
   swallow = swallow;
   xmenu = (pkgs.xmenu.override {
     imlib2 = pkgs.imlib2Full;
   });

   #conf = '' '';

    rules = ''
static const Rule rules[] = {
    /* xprop(1):
     *    WM_CLASS(STRING) = instance, class
     *    WM_NAME(STRING) = title
     */
    /* class     instance  title           tags mask  isfloating  isterminal  noswallow  monitor */
    { .class = "firefox", .monitor = -1,  .props = M_NOSWALLOW },
    { .class = "polybar", .monitor = -1,  .props = M_NOSWALLOW },
    { .class = "mpv",  .monitor = -1,  .props = M_CENTER },
    /* Terminals */
    { .class = "Alacritty",         .monitor = -1,  .props = M_TERMINAL },
    { .class = "Uxterm",            .monitor = -1,  .props = M_TERMINAL },
    { .class = "URxvt",             .monitor = -1,  .props = M_TERMINAL },
    { .class = "Gnome-terminal",    .monitor = -1,  .props = M_TERMINAL },
    { .class = "Xfce4-terminal",    .monitor = -1,  .props = M_TERMINAL },
    { .class = "Buttermilk",        .monitor = -1,  .props = M_TERMINAL },
    /* Center */
    { .class = "discord",       .title = "Discord Updater", .monitor = -1, .props = M_CENTER|M_FLOATING },
    { .class = "jetbrains-idea", .title = "Welcome to",     .monitor = -1, .props = M_CENTER|M_FLOATING },
    { .title = "win0",      .monitor = -1, .props = M_CENTER|M_FLOATING },
    /* Floating */
    { .class = "XClock",                            .monitor = -1, .props = M_FLOATING|M_NOSWALLOW },
    { .class = "Pcmanfm", .title = "Execute File",  .monitor = -1, .props = M_FLOATING|M_NOSWALLOW },
    { .title = "Event Tester",                      .monitor = -1, .props = M_FLOATING|M_NOSWALLOW }, /* xev */
    { .title = "[debug]",                           .monitor = -1, .props = M_FLOATING|M_NOSWALLOW }, /* personal debugging */
    { .class = "Pademelon-settings",                .monitor = -1, .props = M_FLOATING|M_NOSWALLOW },
    { .class = "Arandr",                            .monitor = -1, .props = M_FLOATING|M_NOSWALLOW },
    { .class = "Lxappearance",                      .monitor = -1, .props = M_FLOATING|M_NOSWALLOW },
    { .class = "Pavucontrol",                       .monitor = -1, .props = M_FLOATING|M_NOSWALLOW },
    /* Non-Floating */
    { .class = "Gimp",  .monitor = -1,  .props = M_FLOATING },
    /* Games */
    { .class = "steam_app_",    .monitor = 0 },
    { .class = "steam_proton",  .monitor = 0 },
    { .gameid = -1,             .monitor = 0 },
    /* window types */
    { .wintype = "_NET_WM_WINDOW_TYPE_DIALOG",    .props = M_CENTER|M_FLOATING },
    { .wintype = "_NET_WM_WINDOW_TYPE_SPLASH",    .props = M_CENTER|M_FLOATING },
    { .wintype = "_NET_WM_WINDOW_TYPE_UTILITY",   .props = M_FLOATING },
    { .wintype = "_NET_WM_WINDOW_TYPE_TOOLBAR",   .props = M_FLOATING },
};

static const Rule tagrules[] = {
    { .class = "Spotify",       .monitor = -1,  .tags = 1 << 7 },
    { .class = "TeamSpeak 3",   .monitor = -1,  .tags = 1 << 6 },
    { .class = "Thunderbird",   .monitor = -1,  .tags = 1 << 8 },
    { .class = "discord",       .monitor = -1,  .tags = 1 << 6 },
    { .class = "jetbrains-idea", .monitor = -1, .tags = 1 << 4 },
    { .class = "discord",       .title = "Discord Updater", .monitor = -1,  .tags = 1 << 6 },
    { .class = "jetbrains-idea", .title = "Welcome to",     .monitor = -1,  .tags = 1 << 4 },
    { .title = "win0",          .monitor = -1, .tags = 1 << 4 },
    /* Games */
    { .class = "Lutris",        .monitor = -1,  .tags = 1 << 5 },
    { .class = "Steam",         .monitor = -1,  .tags = 1 << 5 },
    { .class = "steam_app_",    .monitor = 0,   .tags = 1 << 5 },
    { .class = "steam_proton",  .monitor = 0,   .tags = 1 << 5 },
    { .gameid = -1,             .monitor = 0,   .tags = 1 << 5 },
};


    '';
  };

in

{

  options = {
    services.xserver.windowManager.moonwm = {
      enable = mkEnableOption "moonwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before moonwm is started.
        '';
      };
      package = mkPackageOption pkgs "moonwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "moonwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "moonwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${moonwm}/bin/moonwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
      moonwm-helper
      moonwm-menu
      moonwm-utils
      moonwm-status
      swallow
    ];

    services.xserver.windowManager.moonwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = moonwm;
    };

  };

}
