{ config, lib, pkgs, ... }:

let

  cfg = config.my.hardware.power;

in

{

  options.my.hardware.power = {
    upower.enable = lib.mkEnableOption "upower lets apps control power draw with dbus";
  };




  config = lib.mkIf cfg.upower.enable {

    services.upower = {
      enable = true;
      package = pkgs.upower;

      ignoreLid = false;
      noPollBatteries = false;
      enableWattsUpPro = false;

      usePercentageForPolicy = true;

      timeLow = 1200;
      timeCritical = 300;
      timeAction = 120;

      percentageLow = 20;
      percentageCritical = 5;
      percentageAction = 2;

      criticalPowerAction = "HybridSleep";
      allowRiskyCriticalPowerAction = true;
    };

  };

}
