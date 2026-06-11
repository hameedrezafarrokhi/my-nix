{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf (config.my.apps.neovim.enable) {

    home.packages = [

      (pkgs.writeShellScriptBin "lvim" ''
        nvim -u $HOME/.config/lazyvim/init.lua
      '')

    ];

    programs.neovim = {
      enable = true;

      #package = pkgs.neovim-unwrapped;  # Conflicts with Lazyvim or Other Distro modules. this is the default package
      #extraPackages = [ ];
       extraLuaPackages = luaPkgs: with luaPkgs; [
         tree-sitter-cli
       ];
       plugins = with pkgs.vimPlugins; [
        #catppuccin-nvim
         nvim-treesitter
       ];

      #withNodeJs = false;  # Conflicts with Lazyvim or Other Distro modules
      #withPython3 = true;  # Conflicts with Lazyvim or Other Distro modules
      #withRuby = false;    # Conflicts with Lazyvim or Other Distro modules
      #withPerl = false;    # Conflicts with Lazyvim or Other Distro modules

      #extraWrapperArgs = [ ];
      #finalPackage = ;
      defaultEditor = true;
      #extraConfig = '' '';
      #settings = { };
      #generatedConfigs = { };
      #generatedConfigViml = '' '';
      #coc = {};
      viAlias = false;
      vimAlias = false;
      vimdiffAlias = false;
    };

    programs.lazyvim = {
      enable = true;

      # Custom config directory (optional, defaults to "nvim")
      appName = "lazyvim"; # Creates config in ~/.config/lazyvim/

      # Plugin source strategy
      pluginSource = "latest";

      # Option 1: Use a configuration directory (choose either this OR inline config below)
      # configFiles = ./lazyvim-config;

      # LazyVim extras
      extras = {
        lang = {
          nix.enable = true;
          python = {
            enable = true;
            installDependencies = true; # Install ruff (formatter/linter)
            installRuntimeDependencies = true; # Install python3, pip
            config = ''
              return {
                "neovim/nvim-lspconfig",
                opts = {
                  servers = {
                    pyright = {
                      settings = {
                        python = {
                          analysis = {
                            typeCheckingMode = "basic",
                          },
                        },
                      },
                    },
                  },
                },
              }
            '';
          };
        };
        editor.telescope.enable = true;
      };

      # Tools and LSP servers
      extraPackages = with pkgs; [
        nixd
        pyright
        alejandra
        black
        ripgrep
        fd
        gcc
        #luajitPackages.tree-sitter-cli # WARNING ADD AFTER UPDATE
        zig
      ];

      # Optional: Only needed for non-LazyVim languages
      treesitterParsers = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
        wgsl # WebGPU Shading Language
        templ # Go templ files
        c
        nix
        python
        lua
        bash
        zsh
        fish
        yaml
        toml
        json
        hjson
        css
        scss
        ini
        kconfig
        kdl
        xml
        cpp
        yuck
        glsl
        xresources
        zig
      ];

      # Option 2: Inline LazyVim configuration (choose either this OR configFiles above)
      config = {
        #options = ''
        #  vim.opt.relativenumber = false
        #  vim.opt.wrap = true
        #  vim.opt.conceallevel = 0
        #'';

        keymaps = ''
          vim.keymap.set("n", "<C-s>", "<cmd>w<cr>", { desc = "Save" })
          vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
        '';

        autocmds = ''
          vim.api.nvim_create_autocmd("FocusLost", {
            command = "silent! wa",
            desc = "Auto-save on focus loss",
          })
        '';
      };

      # Plugin configurations
      plugins = {
        #colorscheme = ''
        #  return {
        #    "folke/tokyonight.nvim",
        #    opts = {
        #      style = "night",
        #      transparent = true,
        #    },
        #  }
        #'';

        lsp-config = ''
          return {
            "neovim/nvim-lspconfig",
            opts = function(_, opts)
              -- Add additional LSP configuration here
              return opts
            end,
          }
        '';
      };
    };

  };
}
