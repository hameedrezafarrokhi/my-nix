{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (config.my.hardware.keyboard.xremap.enable) {

  environment.systemPackages = [
    pkgs.xremap
  ];

  services.xremap = {
    enable = true;
    package = pkgs.xremap;
    serviceMode = "user";
    userName = admin;
   #userId = 1000;
    watch = true;
    mouse = true;
   #deviceNames = [ ];
   #extraArgs = [ ];
   #debug = true;

   #withSway = true;
   #withWlroots = true;
   #withX11 = true;
   #withKDE = true;
   #withHypr = true;
   #withGnome = true;

    yamlConfig = ''

      keymap:
        - name: Browser
          remap:
            Super-b:
              remap:
                b:
                  launch: [ "${lib.getExe pkgs.brave}" ]
                f:
                  launch: [ "${lib.getExe pkgs.firefox}" ]
        - name: Terminal
          remap:
            Super-Enter:
              launch: [ "${lib.getExe pkgs.${config.my.default.terminal}}" ]
        - name: Terminal2
          remap:
            Super-Alt-Enter:
              remap:
                k:
                  launch: [ "konsole" ]
                t:
                  launch: [ "kitty" ]

    '';


   #config = {
   # #modemap = [ ]; # for single key remaping
   #  keymap = [
   #    {  name = "terminal";
   #      remap = {
   #        "alt-d" = {
   #          remap = {};
   #        };
   #      };
   #    }
   #
   #  ];
   #};

  };

};}
