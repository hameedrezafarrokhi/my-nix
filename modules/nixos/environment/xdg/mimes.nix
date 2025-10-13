{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (config.my.xdg.enable) {

  # To Show App ID:
  # ls /run/current-system/sw/share/applications | grep -i gwenview
  # To Find Mime Type"
  # , file --mime-type .bashrc

############################################################   TERMINAL

  environment.sessionVariables = {

                     TERMINAL = config.my.default.terminal;
                       EDITOR = config.my.default.tui-editor;
                       VISUAL = config.my.default.tui-editor;
  };

  xdg.terminal-exec = config.home-manager.users.${admin}.xdg.terminal-exec;

  xdg.mime = {
    enable = true;
    addedAssociations = config.home-manager.users.${admin}.xdg.mimeApps.associations.added;
    removedAssociations = config.home-manager.users.${admin}.xdg.mimeApps.associations.removed;
    defaultApplications = config.home-manager.users.${admin}.xdg.mimeApps.defaultApplications;
  };

};}
