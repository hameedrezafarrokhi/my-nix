{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.qtwm;
  qtwm = pkgs.callPackage ./qtwm.nix {
    conf = ''
#ifndef CONFIG_H
#define CONFIG_H

#include <xcb/xproto.h>

/* Comment these out if you don't want them */
#define DEBUG
#define MULTIHEAD

/* Look in xproto.h for these values */
#define MODIFIER_MASK XCB_MOD_MASK_1 | XCB_MOD_MASK_SHIFT

/* 1 == normal click, 2 == middle click(?), 3 == opposite click */
#define MOVE_MOUSE_BUTTON 1
#define RESIZE_MOUSE_BUTTON 3

/* Smallest that a window can be, in pixels */
#define MIN_WINDOW_SIZE 64

/* 0xRRGGBB format. No alpha */
#define BORDER_COLOR_UNFOCUSED 0xFF0000
#define BORDER_COLOR_FOCUSED 0x0000FF

/* Border size in pixels */
#define BORDER_WIDTH 2

/* Kinda just a lot unused. Edge-padding in pixels */
#define LEFT_PADDING 4
#define RIGHT_PADDING 4
#define TOP_PADDING 24
#define BOTTOM_PADDING 4

#endif /* CONFIG_H */
    '';
  };

in

{

  options = {
    services.xserver.windowManager.qtwm = {
      enable = mkEnableOption "qtwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before qtwm is started.
        '';
      };
      package = mkPackageOption pkgs "qtwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "qtwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "qtwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${qtwm}/bin/qtwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.qtwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = qtwm;
    };

  };

}
