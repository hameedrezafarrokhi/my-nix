{ config, pkgs, lib, mypkgs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.hypr;

in

{#config = lib.mkIf (builtins.elem "hypr" config.my.window-managers) {
 #
 #services.xserver.windowManager.hypr.enable = true;

#};}

  ###### implementation
  config = mkIf (builtins.elem "hypr" config.my.window-managers) {
    services.xserver.windowManager.session = singleton {
      name = "hypr";
      start = ''
        ${mypkgs.stable.hypr}/bin/Hypr &
        waitPID=$!
      '';
    };
    environment.systemPackages = [ mypkgs.stable.hypr ];
  };

}
