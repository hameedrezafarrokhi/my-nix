{ config, lib, pkgs, ... }:

{

  imports = lib.optional (lib.pathExists ./secrets/default.nix) ./secrets/default.nix;

}
