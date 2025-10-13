{ config, pkgs, lib, ... }:

let

  cfg = config.my.security.sudo;

in

{

  options.my.security.sudo.enable = lib.mkEnableOption "enable sudo";

  config = lib.mkIf cfg.enable {

    security = {
      sudo = {
        enable = true;
        package = pkgs.sudo;
        wheelNeedsPassword = false;
        execWheelOnly = false;
        keepTerminfo = true;

       #extraRules = [
       #  {
       #    groups = [ "wheel" ];
       #    commands = [
       #     { command = "ALL"; options = [ "NOPASSWD" ];}
       #    ];
       #  }
       #];

       #extraConfig = ''  '';
       #defaultOptions = [ "SETENV" ];
       #configFile = ''  '';
      };

     #sudo-rs = {                          # only one of "sudo" or "sudo-rs" must exist, not both
     #  enable = true;
     #  package = pkgs.sudo-rs;
     #  wheelNeedsPassword = false;
     #  execWheelOnly = false;
     # #extraRules = [  ];
     # #extraConfig = ''  '';
     # #defaultOptions = [ "SETENV" ];
     # #configFile = ''  '';
     #};

     #please = {                            # a sudo alternative to run commnads
     #  enable = true;
     #  wheelNeedsPassword = false;
     #  package = pkgs.please;
     # #settings = {                        # this is an example
     # #  jim_edit_etc_hosts_as_root = {
     # #    editmode = 644;
     # #    name = "jim";
     # #    require_pass = true;
     # #    rule = "/etc/hosts";
     # #    target = "root";
     # #    type = "edit";
     # #  };
     # #  jim_run_any_as_root = {
     # #    name = "jim";
     # #    require_pass = false;
     # #    rule = ".*";
     # #    target = "root";
     # #    type = "run";
     # #  };
     # #};
     #};

    };

  };

}
