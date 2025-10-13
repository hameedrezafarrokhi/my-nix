{ config, pkgs, lib, ... }:

let

  cfg = config.my.security.polkit;

in

{

  options.my.security.polkit.enable = lib.mkEnableOption "enable polkit";

  config = lib.mkIf cfg.enable {

    security = {
      polkit = {
        enable = true;
        package = pkgs.polkit;
        adminIdentities = [ "unix-group:wheel" ];
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (
              subject.isInGroup("wheel")
              )
            { return polkit.Result.YES; }
          });
        '';
      };

      soteria = {
        enable = false;
        package = pkgs.soteria;
      };

    };

   #systemd = {
   #  user.services.${myStuff.myPolkitAgent} = {
   #    description = myStuff.myPolkitAgent;
   #    wantedBy = ["graphical-session.target"];
   #    wants = ["graphical-session.target"];
   #    after = ["graphical-session.target"];
   #    serviceConfig = {
   #      Type = "simple";
   #      ExecStart = "${pkgs.${myStuff.myPolkitPackage}}/libexec/${myStuff.myPolkitAgent}";
   #      Restart = "on-failure";
   #      RestartSec = 1;
   #      TimeoutStopSec = 10;
   #    };
   #  };
   #};

    environment.systemPackages = [
      #pkgs.soteria
      #pkgs.polkit_gnome
      #pkgs.hyprpolkitagent
      #pkgs.kdePackages.polkit-kde-agent-1
    ];

    # Replace "soteria" With These:
     # polkit-gnome-authentication-agent-1; kdePackages.polkit-qt-1;
     # "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";

  };

}
