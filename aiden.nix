{ config, lib, ... }:
{
  # NOTE: make sure you configure the peer on Aiden
  options.kiyurica.networks.aiden.enable = lib.mkEnableOption "aiden wireguard";
  options.kiyurica.networks.aiden.address = lib.mkOption {
    type = lib.types.str;
    description = "this device's network IPv4 address in CIDR format";
  };

  config = lib.mkIf config.kiyurica.networks.aiden.enable {
    networking.wireguard.interfaces.aiden = {
      ips = [ config.kiyurica.networks.aiden.address ];
      privateKeyFile = config.age.secrets.aiden-privkey.path;
      peers = [
        {
          publicKey = "hhJ4dU/k8MPZKDqDAa9Rbxs0RZL8DgMFM5d6POxFRyM=";
          allowedIPs = [ "192.168.49.0/24" ];
          endpoint = "128.61.105.57:39003";
          persistentKeepalive = 30;
          dynamicEndpointRefreshRestartSeconds = 10; # dns resolver (dnscrypt?) is flaky on mitsu8
        }
      ];
    };

    age.secrets.aiden-privkey = {
      file = ./secrets/aiden-${config.networking.hostName}.privkey.age;
      mode = "400";
    };
  };
}
