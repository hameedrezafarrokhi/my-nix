{ config, pkgs, lib, mypkgs, ... }:

  with lib;

  let
    xcfg = config.services.xserver;
    cfg = xcfg.desktopManager.mycde;
  in

{

  options.services.xserver.desktopManager.mycde = {
    enable = mkEnableOption "Common Desktop Environment";

    extraPackages = mkOption {
      type = with types; listOf package;
      default = with mypkgs.stable.xorg; [
        xclock
        bitmap
        xlsfonts
        xfd
        xrefresh
        xload
        xwininfo
        xdpyinfo
        xwd
        xwud
      ];
      defaultText = literalExpression ''
        with mypkgs.stable.xorg; [
          xclock bitmap xlsfonts xfd xrefresh xload xwininfo xdpyinfo xwd xwud
        ]
      '';
      description = ''
        Extra packages to be installed system wide.
      '';
    };
  };


   config = lib.mkIf (builtins.elem "cde" config.my.desktops) {

   services.xserver.desktopManager.mycde = {
     enable = true;
     extraPackages = with mypkgs.stable.xorg; [
       xclock
       bitmap
       xlsfonts
       xfd xrefresh
       xload xwininfo
       xdpyinfo
       xwd
       xwud
     ];
   };

    environment.systemPackages = cfg.extraPackages;

    services.rpcbind.enable = true;

    services.xinetd.enable = true;
    services.xinetd.services = [
      {
        name = "cmsd";
        protocol = "udp";
        user = "root";
        server = "${mypkgs.stable.cdesktopenv}/bin/rpc.cmsd";
        extraConfig = ''
          type  = RPC UNLISTED
          rpc_number  = 100068
          rpc_version = 2-5
          only_from   = 127.0.0.1/0
        '';
      }
    ];

    users.groups.mail = { };
    security.wrappers = {
      dtmail = {
        setgid = true;
        owner = "root";
        group = "mail";
        source = "${mypkgs.stable.cdesktopenv}/bin/dtmail";
      };
    };

    system.activationScripts.setup-cde = ''
      mkdir -p /var/dt/{tmp,appconfig/appmanager}
      chmod a+w+t /var/dt/{tmp,appconfig/appmanager}
    '';

    services.xserver.desktopManager.session = [
      {
        name = "CDE";
        start = ''
          exec ${mypkgs.stable.cdesktopenv}/bin/Xsession
        '';
      }
    ];

 };}
