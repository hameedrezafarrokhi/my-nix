{ config, pkgs, lib, inputs, nix-path, ... }:

{ config = lib.mkIf (builtins.elem "yambar" config.my.bar-shell.shells) {

  home.packages = [ ];

  programs.yambar = {
    enable = true;
    package = pkgs.yambar;

    systemd = {
      enable = false;
     #target = config.wayland.systemd.target;
    };

    settings = {
      bar = {
        location = "top";
        height = 26;
        background = "00000066";
        right = [
          {
            clock.content = [
              {
                string.text = "{time}";
              }
            ];
          }
        ];
      };
    };

  };

 #systemd.user.services.yambar = {
 #  Unit = {
 #    ConditionEnvironment = "XDG_CURRENT_DESKTOP=none";
 #  };
 #};

};}
