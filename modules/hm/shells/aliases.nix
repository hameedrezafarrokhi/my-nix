{ config, pkgs, lib, nix-path, mypkgs, ... }:

let

 #nix-path = ../../../../.;

  myRM.myDelete = "sudo rm -f $HOME/.config/fontconfig/conf.d/10-hm-fonts.conf.backup $HOME/.config/mimeapps.list.backup";

in

{ config = lib.mkIf config.my.shellAliases {

  home.shellAliases = {

    gmail = "${config.my.default.browser-alt-name} gmail.com &";

    nixos = "cd ${nix-path}";
    store = "builtin cd /nix/store";
    flake = "${config.my.default.gui-editor-alt-name} ${nix-path}/flake.nix";
    flake-find = "${lib.getExe pkgs.bat} ${nix-path}/flake.nix | ${lib.getExe pkgs.bat-extras.batgrep}";
    flake-lock = "${lib.getExe pkgs.bat} ${nix-path}/flake.lock";
    flake-lock-find = "${lib.getExe pkgs.bat} ${nix-path}/flake.lock | ${lib.getExe pkgs.bat-extras.batgrep}";
    flake-inspect = "builtin cd ${nix-path} && nix-melt && builtin cd";

    nix-tldr = "${lib.getExe pkgs.bat} ${nix-path}/docs/nix-commands.txt";

    flu = "builtin cd ${nix-path} && sudo nix flake update && builtin cd
    ${myRM.myDelete}
    sudo nixos-rebuild switch --upgrade --flake ${nix-path}";
    shit = "${myRM.myDelete}
    sudo nixos-rebuild switch --flake ${nix-path}";
    cleanboy = "nh clean all
    sudo nix-collect-garbage -d
    sudo nix store optimise
    sudo nix store gc
    ${myRM.myDelete}
    nh os switch
    sudo nixos-rebuild switch --flake ${nix-path}";

    nhs = "${myRM.myDelete}
    nh os switch --ask";
    nhu = "${myRM.myDelete}
    nh os switch -u --ask";
    nht = "${myRM.myDelete}
    nh os test --ask";
    nhb = "${myRM.myDelete}
    nh os boot --ask";

    nhs-b = "${myRM.myDelete}
    ${lib.getExe pkgs.borgmatic} create --repository nix
    nh os switch --ask";
    nhu-b = "${myRM.myDelete}
    ${lib.getExe pkgs.borgmatic} create --repository nix
    nh os switch -u --ask";

    trim-gen = "sudo trim-gen";

    theme = "${myRM.myDelete}
    nh clean user -a
    sudo nix store gc --refresh -v
    nh os switch --ask";

    ns = "${lib.getExe mypkgs.fallback.nix-search-tv} print | fzf --preview 'nix-search-tv preview {}' --scheme history";

    now = ''date "+%Y-%m-%d %A %T %Z"'';

    cp = "cp -i";
    mv = "mv -i";
    rm = "rm -i";
    rmf = "rm -rfi";
    mkdir = "mkdir -p";
    psa = "ps auxf";

    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    bd = "cd $OLDPWD";

    ls-a = "ls -aFh --color=always";
    ls-x = "ls -lXBh";
    ls-k = "ls -lSrh";
    ls-c = "ls -ltcrh";
    ls-u = "ls -lturh";
    ls-r = "ls -lRh";
    ls-t = "ls -ltrh";
    ls-m = "ls -alh |more";
    ls-w = "ls -xAh";
    ls-f = "ls -l | egrep -v '^d'";
    ls-d = "ls -l | egrep '^d'";
    ls-A = "ls -Al";
    ls-s =  "ls -A";
    ls-l =  "ls -l";
    ls-abc = "ls -lap";
    ll-f = "ls -Fls";

    h = "history | grep ";
    p = "ps aux | grep ";
    topcpu = "ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10";
    f = "find . | grep ";
    file-count = "count (find . -maxdepth 1 -type f)";
    file-count-h = "count (find . -maxdepth 1)";

    openports = "netstat -nape --inet";

    diskspace = "du -S | sort -n -r |more";
    diskspace-f = "du -h --max-depth=1 | sort -n -r ";

    tree-s = "tree -CAhF --dirsfirst";
    tree-d = "tree -CAFd";

    var-logs = ''sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f'';

    docker-clean = ''
      docker container prune -f
      docker image prune -f
      docker network prune -f
      docker volume prune -f
    '';

  };

};}

