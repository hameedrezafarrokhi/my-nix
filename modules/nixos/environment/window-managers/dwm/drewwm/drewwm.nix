{ config, pkgs, lib, inputs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.drew-wm;
  drew-slstatus = pkgs.callPackage ./drew-slstatus.nix { inputs = inputs; };
  drew-wm = pkgs.callPackage ./drew-wm.nix { inputs = inputs; };

in

{

  options = {
    services.xserver.windowManager.drew-wm = {
      enable = mkEnableOption "drew-wm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before dwm is started.
        '';
      };
      package = mkPackageOption pkgs "dwm" {
        example = ''
          pkgs.dwm.overrideAttrs (oldAttrs: rec {
            patches = [
              (super.fetchpatch {
                url = "https://dwm.suckless.org/patches/steam/dwm-steam-6.2.diff";
                sha256 = "sha256-f3lffBjz7+0Khyn9c9orzReoLTqBb/9gVGshYARGdVc=";
              })
            ];
          })
        '';
      };
    };
  };

  ###### implementation

  config = lib.mkIf (builtins.elem "drew-wm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "drew-wm";
      start = ''
        systemctl --user stop dwm-status.service

        ${drew-slstatus}/bin/slstatus &

        if hash sxhkd >/dev/null 2>&1; then
        	pkill sxhkd
        	sleep 0.5
        	${pkgs.sxhkd}/bin/sxhkd -c "${inputs.drew-wm}/suckless/sxhkd/sxhkdrc" &
        fi

        ${pkgs.dunst}/bin/dunst -config ${inputs.drew-wm}/suckless/dunst/dunstrc &
        ${pkgs.picom}/bin/picom --config ${inputs.drew-wm}/suckless/picom/picom.conf --animations -b &

        systemctl --user stop dwm-status.service

        xsetroot -cursor_name left_ptr &

        export _JAVA_AWT_WM_NONREPARENTING=1
        ${drew-wm}/bin/dwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
      drew-wm
      pkgs.xorg.xsetroot
      drew-slstatus
    ];

    services.xserver.windowManager.drew-wm = {

      enable = true;
     #extraSessionCommands = '' '';
      package = drew-wm;

    };

  };

}
