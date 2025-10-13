{ config, lib, pkgs, mypkgs, ... }:

{
config = lib.mkIf (config.my.software.fetch.enable) {

  environment.systemPackages = with pkgs; [

    neofetch                      ##Fetch script
   #fastfetch                     ##Fetch script
    nerdfetch
    countryfetch
    owofetch
    yafetch
    uwufetch
    ufetch
    tinyfetch
    starfetch
    screenfetch
    ramfetch
    profetch
    pridefetch
    pfetch-rs
   #pfetch
    onefetch
    octofetch
    ghfetch
    microfetch
    maxfetch
    ipfetch
    gpufetch
    freshfetch
    foodfetch
    fetchutils
    disfetch
    cpufetch
    bunnyfetch
    bfetch
    afetch

  ] ++

  [ mypkgs.fallback.fastfetch ]

  ;

};
}
