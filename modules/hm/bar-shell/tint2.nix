{ config, pkgs, lib, mypkgs, ... }:

{ config = lib.mkIf (builtins.elem "tint2" config.my.bar-shell.shells) {


  programs.tint2 = {
    enable = true;
    package = mypkgs.stable.tint2;
   #extraConfig = '' '';
  };

 #systemd.user.services.polybar = {
 # #enable = {
 # # enable = false;
 # #};
 #  Unit = {
 #   #Description = "tint2 status bar";
 #   #PartOf = [ "tray.target" ];
 #   #X-Restart-Triggers = mkIf (configFile != null) "${configFile}";
 #   #ConditionEnvironment = "XDG_CURRENT_DESKTOP=none";
 #  };
 # #Service = {
 # #  Type = "forking";
 # #  Environment = [ "PATH=${cfg.package}/bin:/run/wrappers/bin" ];
 # #  ExecStart =
 # #    let
 # #      scriptPkg = pkgs.writeShellScriptBin "polybar-start" cfg.script;
 # #    in
 # #    "${scriptPkg}/bin/polybar-start";
 # #  Restart = "on-failure";
 # #};
 # #
 # #Install = {
 # #  WantedBy = [ "tray.target" ];
 # #};
 #};

};}
