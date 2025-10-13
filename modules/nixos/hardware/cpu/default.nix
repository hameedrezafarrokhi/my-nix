{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.cpu;

in

{

  options.my.hardware.cpu = {

    brand = lib.mkOption {
       type = lib.types.nullOr (lib.types.enum [ "intel" "amd" ]);
       default = null;
    };

    scx.enable = lib.mkEnableOption "enable scx cpu scheduler";

    thermald.enable = lib.mkEnableOption "enable thermald thermal protection";

    opt = lib.mkOption {
       type = lib.types.nullOr (lib.types.enum [ "power-profiles-daemon" "tlp" "cpupower-gui" "powertop" "auto-cpufreq" ]);
       default = null;
    };

  };

  imports = [

    ./amd.nix
    ./intel.nix
    ./scx.nix
    ./thermald.nix
    ./opt/power-profiles-daemon.nix

  ];

}
