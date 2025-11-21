{ config, pkgs, lib, nix-path, nix-path-alt, mypkgs, ... }:

let

  touchegg-bsp = pkgs.touchegg.overrideAttrs (old: {
    pname = "touchegg-bsp";
    patches = (old.patches or []) ++ [
      (pkgs.writeText "touchegg-bsp-configdir.patch" ''
        diff --git a/src/utils/paths.cpp b/src/utils/paths.cpp
        --- a/src/utils/paths.cpp
        +++ b/src/utils/paths.cpp
        @@ -38,17 +38,17 @@ std::filesystem::path Paths::getUserConfigDirPath() {
           return configPath / "touchegg";
        +  return configPath / "touchegg-bsp";
         }

         std::filesystem::path Paths::getUserConfigFilePath() {
           std::filesystem::path configPath = Paths::getUserConfigDirPath();
        -  return std::filesystem::path{configPath / "touchegg.conf"};
        +  return std::filesystem::path{configPath / "touchegg-bsp.conf"};
         }

         std::filesystem::path Paths::getUserLockFilePath(
             const std::string &lockInstance) {
           std::filesystem::path configPath = Paths::getUserConfigDirPath();
        -  const std::string fileName = ".touchegg" + lockInstance + ".lock";
        +  const std::string fileName = ".touchegg-bsp" + lockInstance + ".lock";
           return std::filesystem::path{configPath / fileName};
         }
      '')
    ];
  });

in

{

  config = lib.mkIf config.my.bspwm.enable {

    systemd.user.services.touchegg-bsp = {
      Unit = {
       Description = "Touchegg BSPWM Daemon";
      };
      Service = {
        Type = "simple";
        ExecStart = "${touchegg-bsp}/bin/touchegg --daemon";
        Restart = "on-failure";
	  ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -u $USER bspwm'";
      };
      Install = {
        wantedBy = [ "multi-user.target" ];
      };
    };

    environment.systemPackages = [ touchegg-bsp ];

    xdg.configFile = {

      touchegg-bsp = {
        target = "touchegg-bsp/touchegg-bsp.conf";
        source = ./touchegg-bsp.conf;
      };

    };

};}
