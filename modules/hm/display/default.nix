{ config, pkgs, lib, ... }:

let

  cfg = config.my.display;

in

{

  options.my.display = {

    primary = {
      name = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      x = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      y = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      rate = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      dpi = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
    };

    second = {
      name = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      x = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      y = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      rate = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      dpi = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      position = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
    };

    third = {
      name = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      x = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      y = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      rate = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      dpi = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      position = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
    };

    external = {
      name = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      x = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      y = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      rate = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      dpi = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
      position = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
    };

  };

}
