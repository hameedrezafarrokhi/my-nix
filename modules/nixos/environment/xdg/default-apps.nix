{ config, pkgs, lib, ... }:

let

  cfg = config.my.default;

in

{

  options.my.default = {

    terminal = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    tui-editor = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    gui-editor = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    gui-editor-alt-name = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    file-manager = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    file-alt = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    browser = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    browser-alt-name = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    browser-package = lib.mkOption {
      type = lib.types.attrs;
      default = null;
    };

    image-viewer = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    image-alt = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    video-player = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    audio-player = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    audio-alt = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    pdf-viewer = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    pdf-alt = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    archive-manager = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    archive-alt = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

  };

}
