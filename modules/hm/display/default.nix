{ config, pkgs, lib, ... }:

let

  cfg = config.my.display;

in

{

  options.my.display = {

    enable = lib.mkEnableOption "display";

    primary = {
      name = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "DISPLAY";
      };
      x = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "1920";
      };
      y = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "1080";
      };
      rate = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "60.00";
      };
      dpi = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "";
      };
    };

    second = {
      name = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "DISPLAY2";
      };
      x = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "1920";
      };
      y = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "1080";
      };
      rate = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "60.00";
      };
      dpi = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "";
      };
      position = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
    };

    third = {
      name = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "DISPLAY3";
      };
      x = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "1920";
      };
      y = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "1080";
      };
      rate = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "60.00";
      };
      dpi = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "";
      };
      position = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
    };

    external = {
      name = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "DISPLAYX";
      };
      x = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "1920";
      };
      y = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "1080";
      };
      rate = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "60.00";
      };
      dpi = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = "";
      };
      position = lib.mkOption {
        type = lib.types.nullOr (lib.types.str);
        default = null;
      };
    };

  };

  config = lib.mkIf cfg.enable {

    home.packages = [

      (pkgs.writeShellScriptBin "brtctl" '' ${builtins.readFile ./brtctl} '')

    ];

  };

}
