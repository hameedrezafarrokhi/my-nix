{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.hana;
  hana = pkgs.callPackage ./hana.nix {
    zig = pkgs.stdenv.mkDerivation {
      pname = "zig-git";

     #version = "0.17.0-dev.389+f5a1968f6";
     #version = "0.17.0-dev.813+2153f8143";
      version = "0.17.0-dev.956+2dca73595";

      src = pkgs.fetchurl {

       #url = "https://ziglang.org/builds/zig-x86_64-linux-0.17.0-dev.389+f5a1968f6.tar.xz";
       #sha256 = "9cvkpe6BmlERdvbqNSyeo1XXurtNx0yxcXI4ZHMCVoM=";
       #url = "https://ziglang.org/builds/zig-x86_64-linux-0.17.0-dev.813+2153f8143.tar.xz";
       #sha256 = "sNRv/EWHuejdC1JO5bxNoeZ/KLulXnxTTOxkry8tenQ=";
        url = "https://ziglang.org/builds/zig-x86_64-linux-0.17.0-dev.956+2dca73595.tar.xz";
        hash = "sha256-EdmV9H+EfDOUu4VV19iEHmhqxqyMUhyM5ipmFubrC0g=";
      };

     #sourceRoot = "zig-x86_64-linux-0.17.0-dev.389+f5a1968f6";
     #sourceRoot = "zig-x86_64-linux-0.17.0-dev.813+2153f8143";
      sourceRoot = "zig-x86_64-linux-0.17.0-dev.956+2dca73595";

      dontBuild = true;
      dontConfigure = true;
      dontFixup = true;
      #env = {
      #  ZIG_GLOBAL_CACHE_DIR = "/tmp/zig-global-cache";
      #  ZIG_LOCAL_CACHE_DIR = "/tmp/zig-local-cache";
      #};
      preBuild = ''
        export HOME=$TMPDIR
        export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-global-cache
        export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-local-cache
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp -r ./* $out/
        chmod +x $out/zig
        ln -s $out/zig $out/bin/zig
      '';
    };
  };

in

{

  options = {
    services.xserver.windowManager.hana = {
      enable = mkEnableOption "hana";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before hana is started.
        '';
      };
      package = mkPackageOption pkgs "hana" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "hana" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "hana";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${hana}/bin/hana &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.hana = {
      enable = true;
      extraSessionCommands = '' '';
      package = hana;
    };

  };

}
