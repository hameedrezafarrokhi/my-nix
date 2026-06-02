{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.zed.enable) {

  programs.zed-editor = {

    enable = true;
    package = pkgs.zed-editor; #pkgs.zed-editor-fhs

   #defaultEditor = false;
    installRemoteServer = false;
   #enableMcpIntegration = false;

    extraPackages = [
      pkgs.nixd
    ];

    extensions = [
      "nix"
    ];

    mutableUserTasks = true;
    mutableUserSettings = true;
    mutableUserKeymaps = true;
    mutableUserDebug = true;

    userTasks = [ ];

    userSettings = {

      features = {
        copilot = false;
      };

      telemetry = {
        metrics = false;
      };

     #vim_mode = false;
     #ui_font_size = 16;
     #buffer_font_size = 16;

    };

    userKeymaps = [

      {
        context = "Workspace";
        bindings = {
          ctrl-shift-t = "workspace::NewTerminal";
        };
      }

    ];

   #userDebug = [ ];

   #themes = { };

  };

};}
