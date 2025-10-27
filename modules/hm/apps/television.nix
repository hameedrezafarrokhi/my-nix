{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.television.enable) {

  programs = {
    television = {
      enable = true;
      package = pkgs.television;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      channels = {

        nix = {
          metadata = {
            name = "nix";
           #description = "";
            requirements = [ "nix-search-tv" ];
	    };
	    source = {
	      command = "nix-search-tv print";
	    };
	    preview = {
	      command = "nix-search-tv preview {}";
	    };
        };

        fish-history = {
          metadata = {
            name = "fish-history";
	    };
	    source = {
	      command = "fish -c 'history'";
	    };
        };

        my-dotfiles = {
          metadata = {
            name = "my-dotfiles";
            requirements = [ "fd" ];
	    };
	    source = {
	      command = "fd -t f . $HOME/.config";
	    };
	    preview = {
	      command = "ls -a";
	    };
        };

      };

      settings = {
        default_channel = "files";
        history_size = 200;
        global_history = false;
        tick_rate = 50;
        ui = {
          use_nerd_font_icons = true;
          ui_scale = 100;
          orientation = "landscape";

          help_panel_hidden = true;
          help_panel_show_categories = true;
         #show_help_bar = false;

         #show_preview_panel = true;
          preview_panel_size = 50;
          preview_panel_scrollbar = true;
          preview_panel_border_type = "rounded";
          preview_panel_hidden = false;

          input_bar_position = "top";
          input_bar_prompt = ">";
          input_bar_border_type = "rounded"; # https://docs.rs/ratatui/latest/ratatui/widgets/block/enum.BorderType.html#variants

         #theme = "default";

          status_bar_separator_open = "";
          status_bar_separator_close = "";
          status_bar_hidden = false;

          results_panel_border_type = "rounded";

          remote_control_show_channel_descriptions = true;
          remote_control_sort_alphabetically = true;
        };
       #previewers.file = {
       #  theme = "TwoDark";
       #};
        keybindings = {
          esc = "quit";
          ctrl-c = "quit";
          down = "select_next_entry";
          ctrl-n = "select_next_entry";
          ctrl-j = "select_next_entry";
          up = "select_prev_entry";
          ctrl-p = "select_prev_entry";
          ctrl-k = "select_prev_entry";
          ctrl-up = "select_prev_history";
          ctrl-down = "select_next_history";
          tab = "toggle_selection_down";
          backtab = "toggle_selection_up";
          enter = "confirm_selection";
          pagedown = "scroll_preview_half_page_down";
          pageup = "scroll_preview_half_page_up";
          ctrl-y = "copy_entry_to_clipboard";
          ctrl-r = "reload_source";
          ctrl-s = "cycle_sources";
          ctrl-t = "toggle_remote_control";
          ctrl-o = "toggle_preview";
          ctrl-h = "toggle_help";
          f12 = "toggle_status_bar";
          backspace = "delete_prev_char";
          ctrl-w = "delete_prev_word";
          ctrl-u = "delete_line";
          delete = "delete_next_char";
          left = "go_to_prev_char";
          right = "go_to_next_char";
          home = "go_to_input_start";
          ctrl-a = "go_to_input_start";
          end = "go_to_input_end";
          ctrl-e = "go_to_input_end";
        };
        events = {
          mouse-scroll-up = "scroll_preview_up";
          mouse-scroll-down = "scroll_preview_down";
        };
        shell_integration = {
          fallback_channel = "files";
        };
        shell_integration.channel_triggers = {
          "alias" = ["alias" "unalias"];
          "env" = ["export" "unset"];
          "dirs" = ["cd" "ls" "rmdir"];
          "files" = [
            "cat"
            "less"
            "head"
            "tail"
            "vim"
            "nano"
            "bat"
            "cp"
            "mv"
            "rm"
            "touch"
            "chmod"
            "chown"
            "ln"
            "tar"
            "zip"
            "unzip"
            "gzip"
            "gunzip"
            "xz"
          ];
          "git-diff" = ["git add" "git restore"];
          "git-branch" = [
            "git checkout"
            "git branch"
            "git merge"
            "git rebase"
            "git pull"
            "git push"
          ];
          "docker-images" = ["docker run"];
          "git-repos" = ["nvim" "code" "hx" "git clone"];
        };
        shell_integration.keybindings = {
          "smart_autocomplete" = "ctrl-t";
          "command_history" = "ctrl-r";
        };
      };
    };
  };

};}
