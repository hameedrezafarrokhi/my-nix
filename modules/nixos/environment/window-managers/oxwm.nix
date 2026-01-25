{ config, pkgs, lib, inputs, ... }:

{ config = lib.mkIf (builtins.elem "oxwm" config.my.window-managers) {

  services.xserver.windowManager.oxwm = {
   #enable = false;
    package = inputs.oxwm.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  services.xserver.windowManager.session = lib.singleton {
    name = "oxwm";
    start = ''
      export _JAVA_AWT_WM_NONREPARENTING=1
      ${config.services.xserver.windowManager.oxwm.package}/bin/oxwm &
      waitPID=$!
    '';
  };

  environment.systemPackages = [
    (inputs.oxwm.packages.${pkgs.stdenv.hostPlatform.system}.default)
  ];

  environment.pathsToLink = [
    "/share/oxwm"
    "/share/xsessions"
  ];

};}
