{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.docs.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

   #libreoffice-qt6-fresh         ##Office (qt/kde unwrapped)
   #libreoffice-fresh             ##Office (rolling)
   #libreoffice                   ##Office (stable)          # lots of overrides
    libreoffice-still             ##Office (stable Another)
    onlyoffice-desktopeditors     ##Office only!
   #wpsoffice

   #evince                        ##PDF (Gnome)
    xreader                       ##PDF (Cinnamon)
    sioyek
    papers
    kdePackages.okular
   #calibre                       ##PDF/ebook (not that good)
   #pdfarranger                   ##PDF editor
   #karp                          ##KDEs pdfarranger Alternative

    foliate

    kdePackages.kate              ##text editor GUI (KDE)

   #notesnook                     ##Online notes
   #joplin-desktop                ##Online notes

    iotas                         ##Markdown
    kdePackages.marknote          ##Markdown (kde)
   #apostrophe                    ##Markdown
   #folio                         ##Markdown

    rnote                         ##Handwriting notes

    kdePackages.kompare           ##Compare Documents and Texts

    morphosis                     ##Convert docs
    gnome-frog                    ##PDF/img text extractor

  ] ) config.my.software.docs.exclude)

   ++

  config.my.software.docs.include;

};}
