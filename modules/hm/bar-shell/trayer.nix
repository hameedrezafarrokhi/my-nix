{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "trayer" config.my.bar-shell.shells) {


  services.trayer = {
    enable = true;
    package = pkgs.trayer;
   #settings = {  # Example
   #  edge = "top";
   #  padding = 6;
   #  SetDockType = true;
   #  tint = "0x282c34";
   #};
  };

  systemd.user.services.trayer.Unit.ConditionEnvironment = "XDG_CURRENT_DESKTOP=none";

};}
