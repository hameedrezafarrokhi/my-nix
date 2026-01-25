{ config, pkgs, lib, ... }:

let

  cfg = config.my.default;

in

{

  options.my.default = {

    terminal = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    tui-editor = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    gui-editor = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    gui-editor-alt-name = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    file-manager = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    browser = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    browser-alt-name = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    browser-package = lib.mkOption {
      type = lib.types.attrs;
      default = null;
    };

    image-viewer = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    image-viewer-alt-name = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    video-player = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    audio-player = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    pdf-viewer = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

    archive-manager = lib.mkOption {
      type = lib.types.nullOr (lib.types.str);
      default = null;
    };

  };

  config = lib.mkIf config.my.xdg.enable {

    xdg = {

      mime = {
        enable = true;
        desktopFileUtilsPackage = pkgs.desktop-file-utils;
        sharedMimeInfoPackage = pkgs.shared-mime-info;
      };

      terminal-exec = {
        enable = true;
        package = pkgs.xdg-terminal-exec; # pkgs.xdg-terminal-exec-mkhl (Rust Based)
        settings = {
         default = [ "${config.my.default.tui-editor}.desktop" ];
        #KDE = [  ];
        #GNOME = [ "com.raggesilver.BlackBox.desktop" "org.gnome.Terminal.desktop" ];
        };
      };

      mimeApps = {

        enable = true;
        associations = {
          added = { "application/vnd.microsoft.portable-executable" = "wine.desktop"; };
          removed = {
            "text/*" = [ "peazip-add-to-archive.desktop" "peazip.desktop" "peazip-extract.desktop" ];
            "application/*" = [ "peazip-add-to-archive.desktop" "peazip.desktop" "peazip-extract.desktop" ];
          };
        };

        defaultApplications  = {

            ################################################################   TEXT

                                 "text/*" = "${config.my.default.gui-editor}.desktop";
                             "text/plain" = "${config.my.default.gui-editor}.desktop";
                          "text/markdown" = "${config.my.default.gui-editor}.desktop";
                     "text/x-shellscript" = "${config.my.default.gui-editor}.desktop";

                       "application/json" = "${config.my.default.gui-editor}.desktop";
                        "application/xml" = "${config.my.default.gui-editor}.desktop";

                        "application/pdf" = "${config.my.default.gui-editor}.desktop";

            ###############################################################   IMAGE

                                "image/*" = "${config.my.default.image-viewer}.desktop";
                              "image/png" = "${config.my.default.image-viewer}.desktop";
                             "image/jpeg" = "${config.my.default.image-viewer}.desktop";
                              "image/gif" = "${config.my.default.image-viewer}.desktop";
                             "image/webp" = "${config.my.default.image-viewer}.desktop";
                              "image/bmp" = "${config.my.default.image-viewer}.desktop";
                             "image/tiff" = "${config.my.default.image-viewer}.desktop";

            ###############################################################   AUDIO

                                "audio/*" = "${config.my.default.audio-player}.desktop";
                             "audio/mpeg" = "${config.my.default.audio-player}.desktop";
                              "audio/mp3" = "${config.my.default.audio-player}.desktop";
                              "audio/aac" = "${config.my.default.audio-player}.desktop";
                              "audio/ogg" = "${config.my.default.audio-player}.desktop";
                             "audio/flac" = "${config.my.default.audio-player}.desktop";
                            "audio/x-m4a" = "${config.my.default.audio-player}.desktop";
                              "audio/wav" = "${config.my.default.audio-player}.desktop";

            ###############################################################   VIDEO

                                "video/*" = "${config.my.default.video-player}.desktop";
                              "video/mp4" = "${config.my.default.video-player}.desktop";
                       "video/x-matroska" = "${config.my.default.video-player}.desktop";
                            "video/x-flv" = "${config.my.default.video-player}.desktop";
                             "video/webm" = "${config.my.default.video-player}.desktop";
                        "video/x-msvideo" = "${config.my.default.video-player}.desktop";
                        "video/quicktime" = "${config.my.default.video-player}.desktop";
                         "video/x-ms-wmv" = "${config.my.default.video-player}.desktop";
                             "video/mpeg" = "${config.my.default.video-player}.desktop";
                             "video/3gpp" = "${config.my.default.video-player}.desktop";

            #############################################################   ARCHIVE

                        "application/zip" = "${config.my.default.archive-manager}.desktop";
            "application/x-7z-compressed" = "${config.my.default.archive-manager}.desktop";
                    "application/vnd.rar" = "${config.my.default.archive-manager}.desktop";
                      "application/x-tar" = "${config.my.default.archive-manager}.desktop";

            #############################################################   BROWSER

                 "x-scheme-handler/https" = "${config.my.default.browser}.desktop";
                  "x-scheme-handler/http" = "${config.my.default.browser}.desktop";
                 "x-scheme-handler/about" = "${config.my.default.browser}.desktop";
               "x-scheme-handler/unknown" = "${config.my.default.browser}.desktop";
                              "text/html" = "${config.my.default.browser}.desktop";

            ########################################################   FILE_MANAGER

                        "inode/directory" = "${config.my.default.file-manager}.desktop";

            #############################################################   WINDOWS

            "application/vnd.microsoft.portable-executable" = "wine.desktop";

        };

      };

    };

    home.sessionVariables = {

              TERMINAL = config.my.default.terminal;
                EDITOR = config.my.default.tui-editor;
                VISUAL = config.my.default.tui-editor;

    };

  };

}
