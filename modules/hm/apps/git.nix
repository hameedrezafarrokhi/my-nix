{ config, pkgs, lib, nix-path, ... }:

{ config = lib.mkIf (config.my.apps.git.enable) {



  programs.git = {

    enable = true;
    package = pkgs.gitFull;
    userName = "hameedrezafarrokhi";
    userEmail = "hameedrezafarrokhi@gmail.com";

    ignores = [

      "${nix-path}/modules/hm/secrets/secrets"
      "${nix-path}/modules/nixos/secrets/secrets"

    ];

   #signing.signer
   #signing.signByDefault
   #signing.key
   #signing.format
   #riff.package
   #riff.enable
   #riff.commandLineOptions
   #patdiff.package
   #patdiff.enable
   #
   #maintenance.timers
   #maintenance.repositories
   #maintenance.enable
   #lfs.skipSmudge
   #lfs.enable
   #includes.*.path
   #includes.*.contents
   #includes.*.contentSuffix
   #includes.*.condition
   #includes
   #
   #hooks
   #extraConfig
   #
   #difftastic.package
   #difftastic.options
   #difftastic.enableAsDifftool
   #difftastic.enable
   #diff-so-fancy.useUnicodeRuler
   #diff-so-fancy.stripLeadingSymbols
   #diff-so-fancy.rulerWidth
   #diff-so-fancy.pagerOpts
   #diff-so-fancy.markEmptyLines
   #diff-so-fancy.enable
   #diff-so-fancy.changeHunkIndicators
   #diff-highlight.pagerOpts
   #diff-highlight.enable
   #delta.package
   #delta.options
   #delta.enable
   #attributes
   #aliases

  };

};}
