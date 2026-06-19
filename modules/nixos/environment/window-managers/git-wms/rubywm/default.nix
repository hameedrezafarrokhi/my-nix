{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.rubywm;
  rubywm = pkgs.callPackage ./rubywm.nix {
    conf = ''

# Default layout is tiled.
# Desktops are numbered from 1, matching user-visible labelling rather than
# the internal array.

desktops:
  number: 10 # Default

  2:
    nodes:
    - iclass: "todo-todo"
    - dir: tb
      nodes:
      - iclass: "todo-done"
      - iclass: "todo-note"
  10:
    layout: floating
    '';
  };

in

{

  options = {
    services.xserver.windowManager.rubywm = {
      enable = mkEnableOption "rubywm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before rubywm is started.
        '';
      };
      package = mkPackageOption pkgs "rubywm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "rubywm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "rubywm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${rubywm}/bin/rubywm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.rubywm = {
      enable = true;
      extraSessionCommands = '' '';
      package = rubywm;
    };

  };

}
