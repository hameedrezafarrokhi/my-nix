{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "miriway" config.my.window-managers) {

  programs.miriway = {
    enable = true;
    config = ''
      x11-window-title=Miriway (Mir-on-X)
      idle-timeout=600
      ctrl-alt=t:miriway-terminal # Default "terminal emulator finder"

      shell-component=dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY

      meta=Left:@dock-left
      meta=Right:@dock-right
      meta=Space:@toggle-maximized
      meta=Home:@workspace-begin
      meta=End:@workspace-end
      meta=Page_Up:@workspace-up
      meta=Page_Down:@workspace-down
      ctrl-alt=BackSpace:@exit
    '';
  };

};}


# Example

#''
#  idle-timeout=300
#  ctrl-alt=t:weston-terminal
#  add-wayland-extensions=all
#
#  shell-components=dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY
#
#  shell-component=waybar
#  shell-component=wbg Pictures/wallpaper
#
#  shell-meta=a:synapse
#
#  meta=Left:@dock-left
#  meta=Right:@dock-right
#  meta=Space:@toggle-maximized
#  meta=Home:@workspace-begin
#  meta=End:@workspace-end
#  meta=Page_Up:@workspace-up
#  meta=Page_Down:@workspace-down
#  ctrl-alt=BackSpace:@exit
#''
