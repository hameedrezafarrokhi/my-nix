{ config, lib, pkgs, ... }:

  # https://github.com/fastfetch-cli/fastfetch/tree/dev/presets
  # https://github.com/LierB/fastfetch/tree/master/presets
  # https://github.com/harilvfs/fastfetch/blob/old-days/fastfetch/config.jsonc

{ config = lib.mkIf (config.my.apps.fastfetch.enable) {

  xdg.configFile."./fastfetch/config.jsonc".text = ''

{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "type": "builtin",
    },
    "modules": [
        "break",
        {
            "type": "host",
            "key": "PC",
            "keyColor": "white"
        },
        {
           "type": "display",
           "key": "├󰹑",
           "keyColor": "blue"
        },
        {
            "type": "cpu",
            "key": "├",
            "keyColor": "blue"
        },
        {
            "type": "gpu",
            "key": "├󰍛",
            "keyColor": "blue"
        },
        {
            "type": "memory",
            "key": "├󰍛",
            "keyColor": "blue"
        },
        {
            "type": "disk",
            "key": "└",
            "keyColor": "blue",
            "folders": "/"
        },
        "break",
        {
            "type": "os",
            "key": "OS",
            "keyColor": "blue"
        },
        {
            "type": "kernel",
            "key": "├",
            "keyColor": "white"
        },
        {
            "type": "packages",
            "key": "├󰏖",
            "keyColor": "white"
        },
        {
            "type": "shell",
            "key": "└",
            "keyColor": "white"
        },
        "break",
        {
            "type": "de",
            "key": "DE",
            "keyColor": "white"
        },
        {
            "type": "wm",
            "key": "├",
            "keyColor": "blue"
        },
        {
            "type": "wmtheme",
            "key": "├󰉼",
            "keyColor": "blue"
        },
        {
            "type": "terminalfont",
            "key": "├󰛖",
            "keyColor": "blue"
        },
        {
            "type": "terminal",
            "key": "└",
            "keyColor": "blue"
        },
        "break",
        {
            "type": "datetime",
            "key": "  󰅐 Time ",
            "keyColor": "cyan"
        },
        "break",
        {
            "type": "colors",
            "paddingLeft": 2,
            "symbol": "circle"
        },
        "break",
        "break"

    ]
}
  '';


};}
