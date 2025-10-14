{ config, pkgs, lib, nix-path, ... }:

let

  git-nix-init = pkgs.writeShellScriptBin "git-nix-init" ''
    git init &&
    git remote add origin git@github.com:hameedrezafarrokhi/my-nix.git &&
    git add . &&
    git commit -m "0.0.0.0..." &&
    git branch -M main &&
    git push -u origin main
  '';

  git-nix-up = pkgs.writeShellScriptBin "git-nix-up" ''
    cd ${nix-path} &&
    git add . &&
    git commit -m "$(date +%F_%H-%M-%S)" &&
    git branch -M main &&
    git push -u origin main
  '';

  git-nix-pull = pkgs.writeShellScriptBin "git-nix-pull" ''
    cd ${nix-path} &&
    git remote add origin git@github.com:hameedrezafarrokhi/my-nix.git &&
    git pull origin main
  '';

  git-nix-clone = pkgs.writeShellScriptBin "git-nix-clone" ''
    cd ${nix-path} &&
    git clone https://github.com/hameedrezafarrokhi/my-nix
  '';

in

{ config = lib.mkIf (config.my.apps.git.enable) {

  home.packages = [ git-nix-up git-nix-init git-nix-pull git-nix-clone ];

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
