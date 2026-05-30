{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.broot.enable) {

  home.packages = [
    pkgs.broot
  ];

  programs.broot = {
    enable = true;
    package = pkgs.broot;

    enableZshIntegration = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

    settings = {
      #default_flags = ;
      #terminal_title = "[broot] {git-name}"
      terminal_title = "{file} 🐄";
      #terminal_title = "-= {file-name} =-"
      reset_terminal_title_on_exit = true;
      date_time_format = "%Y/%m/%d %R";
      modal = false;
      initial_mode = "command";
      show_selection_mark = true;
      #cols_order = [
      #    "mark"
      #    "git"
      #    "size"
      #    "permission"
      #    "date"
      #    "count"
      #    "branch"
      #    "name"
      #];
      true_colors = false;
      icon_theme = "Papirus-Dark";
      special_paths = {
          "/media" = {
              list = "never";
              sum = "never";
          };
          "~/.config" = { "show" = "always"; };
          "trav" = {
              show = "always";
              list = "always";
              sum = "never";
          };
          # "~/useless": { "show": "never" }
          # "~/my-link-I-want-to-explore": { "list": "always" }
      };
      quit_on_last_cancel = true;
      # search_modes: {
      #     <empty>: fuzzy name
      #     /: regex name
      # }
      # ext_colors: {
      #     png: rgb(255, 128, 75)
      #     rs: yellow
      # }
      content_search_max_file_size = "10MB";
      max_panels_count = 2;
      update_work_dir = true;
      enable_kitty_keyboard = true;
      lines_before_match_in_preview = 1;
      lines_after_match_in_preview = 1;
      preview_transformers = [
         #{
         #    input_extensions = [ "pdf" ];
         #    output_extension = "png";
         #    mode = "image";
         #    command = [ "mutool" "draw" "-w" "1000" "-o" "{output-path}" "{input-path}" ];
         #}
         #{
         #    input_extensions = [ "xls" "xlsx" "doc" "docx" "ppt" "pptx" "ods" "odt" "odp" ];
         #    output_extension = "png";
         #    mode = "image";
         #    command = [
         #        "libreoffice" "--headless"
         #        "--convert-to" "png"
         #        "--outdir" "{output-dir}"
         #        "{input-path}"
         #    ];
         #}
         #{
         #    input_extensions = [ "json" ];
         #    output_extension = "json";
         #    mode = "text";
         #    command = [ "jq" ];
         #}
      ];
     #imports = [
     #    "verbs.hjson"
     #    {
     #        luma = [
     #            "dark"
     #            "unknown"
     #        ];
     #        file = "skins/hm-theme.hjson";
     #    }
     #    {
     #        luma = "light";
     #        file = "skins/hm-theme.hjson";
     #    }
     #];
    };

  };

};}
