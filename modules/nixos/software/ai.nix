{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.software.ai.enable) {

  environment.systemPackages = with pkgs; [

    alpaca
    # To Add GPU Acceleration Add Below SOWMWHERE ELSE!
    # pkgs.alpaca.override {
    #   ollama = pkgs.ollama-cuda;
    # }
   #gpt4all
   #gpt4all-cuda
   #chatd
   #aichat
   #yai

  ];

};
}
