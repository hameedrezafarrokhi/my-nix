{ config, pkgs, lib, ... }:

let

  cfg = config.my.security.tpm;

in

{

  options.my.security.tpm.enable = lib.mkEnableOption "enable tpm";

  config = lib.mkIf cfg.enable {

    security.tpm2 = {
      enable = true;
      applyUdevRules = true;
     #abrmd = {
     #  enable = true;
     #  package = pkgs.tpm2-abrmd;
     #};
      pkcs11 = {
        enable = true;
        package = if config.security.tpm2.abrmd.enable then pkgs.tpm2-pkcs11.abrmd else pkgs.tpm2-pkcs11;
      };
      tctiEnvironment = {
        enable = true;
        deviceConf = "/dev/tpmrm0";
        interface = "device"; # one of "tabrmd", "device"
        tabrmdConf = "bus_name=com.intel.tss2.Tabrmd";
      };
      tssUser = if config.security.tpm2.abrmd.enable then "tss" else "root";
      tssGroup = "tss";
    };

  };

}
