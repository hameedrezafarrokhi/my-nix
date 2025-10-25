{ config, pkgs, lib, mypkgs, nix-path, ... }:

{ config = lib.mkIf (builtins.elem "fish" config.my.shells) {

  home.shell.enableFishIntegration = true;

  programs.starship.enableTransience = true;
  programs.starship.enable = true;

  programs.fish = {
    enable = true;
    generateCompletions = true;
    package = pkgs.fish;
    preferAbbrs = true;

    plugins = [ ];

    loginShellInit = '' '';
    shellInitLast = '' '';
    shellInit = '' '';

    # ${lib.getExe mypkgs.stable.fastfetch} --gpu-hide-type Integrated --logo-height 5  --logo-color-1 blue --logo-color-2 white --logo-padding-top 2 --logo-padding-left 46

    interactiveShellInit = ''

      ${lib.getExe pkgs.microfetch}

      set -g fish_greeting

      function starship_transient_prompt_func
        echo
        starship module custom.character5; starship module directory; starship module custom.character4
      end

      function starship_transient_rprompt_func
        starship module custom.character3; starship module time; starship module custom.character2
      end

      bind \cF 'commandline -i "zi"; commandline -f execute'

    '';

    shellAliases = { };

    shellAbbrs = {

     #bin-store = "nix-store -r $(which )";
      nvdiff = "nvd diff /nix/var/nix/profiles/system-{1,2}-link";

      nhi = "nh os info";
      nhr = "nh os rollback --ask -t";
      nhc = "nh clean all --ask";
      pkgs = "nh search";

      borg-list = "borgmatic list --repository";
      borg-push = "borgmatic create --repository";
      borg-nix = "borgmatic create --repository nix";

      plasma-restart = "pkill plasmashell && kstart5 plasmashell";

      bye = "wayland-logout";

      btw = "tokei ${nix-path}";

    };

    functions = {
     #fish_greeting = ''
     #  echo "Hello"
     #'';
      gen-diff = ''nvd diff /nix/var/nix/profiles/system-$argv[1]-link /nix/var/nix/profiles/system-$argv[2]-link'';

      bin-store = "nix-store -r $(which $argv[1])";

      ftext = ''grep -iIHrn --color=always "$argv[1]" . | less -r'';

      cd = ''if count $argv > /dev/null
              builtin cd "$argv"; and ls
            else
              builtin cd ~; and ls
            end'';

      extract-me = ''
          for archive in $argv
            if test -f "$archive"
               switch "$archive"
                  case '*.tar.bz2'
                    tar xvjf "$archive"
                  case '*.tar.gz'
                    tar xvzf "$archive"
                  case '*.bz2'
                    bunzip2 "$archive"
                  case '*.rar'
                    rar x "$archive"
                  case '*.gz'
                    gunzip "$archive"
                  case '*.tar'
                    tar xvf "$archive"
                  case '*.tbz2'
                    tar xvjf "$archive"
                  case '*.tgz'
                    tar xvzf "$archive"
                  case '*.zip'
                    unzip "$archive"
                  case '*.Z'
                    uncompress "$archive"
                  case '*.7z'
                    7z x "$archive"
                  case '*'
                    echo "don't know how to extract '$archive'..."
                end
          else
                  echo "'$archive' is not a valid file!"
           end
       end
      '';

      cpp = ''
          if not set -q argv[2]
            echo "Usage: cpp <SOURCE> <DESTINATION>"
            return 1
          end
          if not test -f "$argv[1]"
            echo "Error: Source File '$argv[1]' not found"
            return 1
          end
          strace -q -ewrite cp -- "$argv[1]" "$argv[2]" 2>&1 | \
          awk '
          {
              count += $NF
              if (count % 10 == 0) {
                  percent = count / total_size * 100
                  printf "%3d%% [", percent
                  for (i=0;i<=percent;i++)
                      printf "="
                  printf ">"
                  for (i=percent;i<100;i++)
                      printf " "
                  printf "]\r"
              }
          }
          END { print "" }' total_size="$(stat -c '%s' "$argv[1]")" count=0
      '';

      cpg = ''
        if test -d "$argv[2]"
          cp "$argv[1]" "$argv[2]" && cd "$argv[2]"
        else
          cp "$argv[1]" "$argv[2]"
        end
      '';
      mvg = ''
        if test -d "$argv[2]"
          mv "$argv[1]" "$argv[2]" && cd "$argv[2]"
        else
          mv "$argv[1]" "$argv[2]"
        end
      '';
      mkdirg = ''
        mkdir -p "$argv[1]"
        cd "$argv[1]"
      '';
      goup = ''
        set -l d ""
        set -l limit $argv[1]
        for i in (seq $limit)
          set d "$d../"
        end
        set d (string replace -r "^/" "" -- "$d")
        if test -z "$d"
          set d ..
        end
        cd "$d"
      '';

     };

  };

};}
