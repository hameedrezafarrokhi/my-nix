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

  # Only git-nix-up alone Or git-nix-commit followed bye git-nix-push

  git-nix-up = pkgs.writeShellScriptBin "git-nix-up" ''
    cd ${nix-path} &&
    git add . &&
    git commit -m "$(date +%F_%H-%M-%S)" &&
    git branch -M main &&
    git push -u origin main
  '';

  git-nix-commit = pkgs.writeShellScriptBin "git-nix-commit" ''
    cd ${nix-path} &&
    git add . &&
    git commit -m "$(date +%F_%H-%M-%S)"
  '';

  git-nix-push = pkgs.writeShellScriptBin "git-nix-push" ''
    cd ${nix-path} &&
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

  home.packages = [ git-nix-up git-nix-init git-nix-pull git-nix-clone git-nix-push git-nix-commit  ];

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

   #hooks
   #extraConfig

   #difftastic.package
   #difftastic.options
   #difftastic.enableAsDifftool
   #difftastic.enable

    diff-so-fancy = {
      enable = true;
      useUnicodeRuler = true;
      stripLeadingSymbols = true;
     #rulerWidth = null;
      pagerOpts = [
        "--tabs=4"
        "-RFX"
      ];
      markEmptyLines = true;
      changeHunkIndicators = true;
    };

   #diff-highlight.pagerOpts
   #diff-highlight.enable

   #delta.package
   #delta.options
   #delta.enable
   #attributes

   #aliases

  };

  programs.gh = {
    enable = true;
    package = pkgs.gh;
    settings = {
      git_protocol = "ssh";
     #editor = "";
     #aliases = { };
    };
    hosts = {
      "github.com" = {
        user = "hameedrezafarrokhi";
      };
    };
    gitCredentialHelper = {
      enable = true;
      hosts = [ "https://github.com" "https://github.com/hameedrezafarrokhi" ];
    };
    extensions = with pkgs; [
      gh-s
      gh-i
      gh-f
      gh-poi
      gh-ost
      gh-gei
      gh-eco
      gh-cal
      gh-notify
      gh-skyline
      gh-signoff
     #gh-copilot
      gh-contribs
     #gh-classroom
      gh-screensaver
      gh-actions-cache
      gh-markdown-preview
      gh-dash
    ];

  };

  programs.gh-dash = {
    enable = true;
    package = pkgs.gh-dash;
   #settings = { };
  };

};}
