{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.apps.starship.enable) {

  programs.starship = {
    enable = true;
    enableInteractive = true;
    enableBashIntegration = false;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableTransience = true;
    settings = lib.mkDefault {
      scan_timeout = 500; # Default 30
      format = lib.concatStrings [
       "[](#3B4252)"
       "$python"
       "$username"
       "[](bg:#434C5E fg:#3B4252)"
       "$directory"
       "[](fg:#434C5E bg:#4C566A)"
       "$git_branch"
       "$git_status"
       "[](fg:#4C566A bg:#86BBD8)"
       "$c"
       "$elixir"
       "$elm"
       "$golang"
       "$haskell"
       "$java"
       "$julia"
       "$nodejs"
       "$nim"
       "$rust"
       "[](fg:#86BBD8 bg:#06969A)"
       "$docker_context"
       "[](fg:#06969A bg:#33658A)"
       "$time"
       "[ ](fg:#33658A)"
       ];
      command_timeout = 5000;
      username = {
       show_always = true;
       style_user = "bg:#3B4252";
       style_root = "bg:#3B4252";
       format = "[$user ]($style)";
      };
      directory = {
       style = "bg:#434C5E";
       format = "[ $path ]($style)";
       truncation_length = 3;
       truncation_symbol = "…/";
      };
      directory.substitutions = {
       "Documents" = "󰈙 ";
       "Downloads" = " ";
       "Music" = " ";
       "Pictures" = " ";
      };
      time = {
       disabled = false;
       time_format = "%R"; # Hour:Minute Format
       style = "bg:#33658A";
       format ="[ $time ]($style)";
      };

      c = {
       symbol = " ";
       style = "bg:#86BBD8";
       format = "[ $symbol ($version) ]($style)";
      };
      docker_context = {
       symbol = " ";
       style = "bg:#06969A";
       format = "[ $symbol $context ]($style)$path";
      };
      elixir = {
       symbol = " ";
       style = "bg:#86BBD8";
       format = "[ $symbol ($version) ]($style)";
      };
      elm = {
       symbol = " ";
       style = "bg:#86BBD8";
       format = "[ $symbol ($version) ]($style)";
      };
      git_branch = {
       symbol = "";
       style = "bg:#4C566A";
       format = "[ $symbol $branch ]($style)";
      };
      git_status = {
       style = "bg:#4C566A";
       format = "[$all_status$ahead_behind ]($style)";
      };
      golang = {
       symbol = " ";
       style = "bg:#86BBD8";
       format = "[ $symbol ($version) ]($style)";
      };
      haskell = {
       symbol = " ";
       style = "bg:#86BBD8";
       format = "[ $symbol ($version) ]($style)";
      };
      java = {
       symbol = " ";
       style = "bg:#86BBD8";
       format = "[ $symbol ($version) ]($style)";
      };
      julia = {
       symbol = " ";
       style = "bg:#86BBD8";
       format = "[ $symbol ($version) ]($style)";
      };
      nodejs = {
       symbol = "";
       style = "bg:#86BBD8";
       format = "[ $symbol ($version) ]($style)";
      };
      nim = {
       symbol = " ";
       style = "bg:#86BBD8";
       format = "[ $symbol ($version) ]($style)";
      };
      python = {
       style = "bg:#3B4252";
       format = "[(\($virtualenv\) )]($style)";
      };
      rust = {
       symbol = "";
       style = "bg:#86BBD8";
       format = "[ $symbol ($version) ]($style)";
      };
     #character = {
     #  format = lib.concatStrings [
     #    "[](bg:#3B4252 fg:#3B4252)"
     #    "[](bg:#3B4252 fg:#3B4252)"
     #    "[](bg:#3B4252 fg:#3B4252)"
     #  ];
     #};
      custom.character2 = {
        command = "";
        format = "[](fg:#33658A)";
        when = true;
        style = "fg:#33658A";
      };
      custom.character3 = {
        command = "";
        when = true;
        format = "[ ](fg:#33658A)";
        style = "fg:#33658A";
      };
      custom.character4 = {
        command = "";
        format = "[ ](fg:#434C5E)";
        when = true;
        style = "fg:#434C5E";
      };
      custom.character5 = {
        command = "";
        format = "[](fg:#434C5E)";
        when = true;
        style = "fg:#434C5E";
      };
    };

  };

};}
