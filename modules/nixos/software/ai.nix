{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.ai.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

    alpaca
    # To Add GPU Acceleration Add Below SOWMWHERE ELSE!
    # pkgs.alpaca.override {
    #   ollama = pkgs.ollama-cuda;
    # }

    gpt4all
    gpt4all-cuda
    chatd
    aichat
    yai

  ] ) config.my.software.ai.exclude)

   ++

  config.my.software.ai.include;

  services = {
    ollama = {
      enable = true;
      package = pkgs.ollama;
     #environmentVariables = {};
     #host = "127.0.0.1";
     #port = 11434;
      openFirewall = true;
     #home = "/home/${admin}";
      models = "\${config.services.ollama.home}/models";
      loadModels = [
        #wizardlm-uncensored:13b
        #deepseek-r1
        #gemma3n
      ];
     #user = admin;
     #group = config.services.ollama.user;
    };
    nextjs-ollama-llm-ui = {
      enable = true;
      package = pkgs.nextjs-ollama-llm-ui;
     #ollamaUrl = "http://127.0.0.1:11434";
     #port = 3000;
     #hostname = "127.0.0.1";
    };
  };

};}
