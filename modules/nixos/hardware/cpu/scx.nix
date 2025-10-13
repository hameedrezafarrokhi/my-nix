{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.hardware.cpu.scx.enable) {

  services.scx = {
   enable = true;
   scheduler = "scx_bpfland"; # one of "scx_bpfland", "scx_central", "scx_flash", "scx_flatcg", "scx_lavd", "scx_layered", "scx_mitosis", "scx_nest", "scx_pair", "scx_qmap", "scx_rlfifo", "scx_rustland", "scx_rusty", "scx_sdt", "scx_simple", "scx_userland"
   package = pkgs.scx.full;
   extraArgs = [
     # LAVD
    #"--performance"
   ];
  };

  # to avoid clashing with scx set to false
  services.ananicy.enable = false;

};}
