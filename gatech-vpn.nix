{ config, lib, ... }:
{
  options.kiyurica.gatech-vpn.enable = lib.mkEnableOption "Georgia Tech VPN via proxy";

  config = lib.mkIf config.kiyurica.gatech-vpn.enable {
    age.secrets."gatech-vpn-password.cred" = {
      file = ./secrets/gatech-vpn-password-${config.networking.hostName}.cred.age;
      owner = config.kiyurica.ocproxy.user;
      mode = "400";
    };
    kiyurica.ocproxy = {
      enable = true;
      server = "vpn.gatech.edu";
      gateway = "DC Gateway";
      username = "kshibata6";
      password-file = config.age.secrets."gatech-vpn-password.cred".path;
    };
  };
}
