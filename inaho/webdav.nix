{ config, pkgs, ... }:

let
  certPath = config.kiyurica.tailscale.cert.certPath;
  domain = "inaho.tailcbbed9.ts.net";
  
  webdavLocations = {
    "/" = {
      root = "/var/lib/webdav/joplin";
      extraConfig = ''
        client_body_temp_path /var/lib/webdav/tmp;
        dav_methods PUT DELETE MKCOL COPY MOVE;
        dav_ext_methods PROPFIND OPTIONS;
        dav_access user:rw group:rw all:r;

        client_max_body_size 0;
        create_full_put_path on;

        auth_basic "Joplin WebDAV";
        auth_basic_user_file ${config.age.secrets.webdav-htpasswd.path};
      '';
    };

    "/convind4" = {
      root = "/var/lib/webdav/convind4";
      extraConfig = ''
        client_body_temp_path /var/lib/webdav/tmp;
        dav_methods PUT DELETE MKCOL COPY MOVE;
        dav_ext_methods PROPFIND OPTIONS;
        dav_access user:rw group:rw all:r;

        client_max_body_size 0;
        create_full_put_path on;

        auth_basic "WebDAV";
        auth_basic_user_file ${config.age.secrets.webdav-htpasswd.path};

        add_header 'Access-Control-Allow-Origin' 'http://localhost:*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, MKCOL, COPY, MOVE, PROPFIND, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Depth, User-Agent, X-File-Size, X-Requested-With, If-Modified-Since, X-File-Name, Cache-Control' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;

        if ($request_method = 'OPTIONS') {
          return 204;
        }
      '';
    };
  };
in
{
  age.secrets.webdav-htpasswd = {
    file = ../secrets/webdav-htpasswd.age;
    owner = "nginx";
    group = "nginx";
    mode = "0400";
  };

  kiyurica.tailscale.cert.enable = true;

  services.nginx = {
    enable = true;

    virtualHosts."${domain}" = {
      listen = [
        {
          addr = domain;
          port = 8087;
        }
      ];

      locations = webdavLocations;
    };

    virtualHosts."${domain}-https" = {
      serverName = domain;
      listen = [
        {
          addr = domain;
          port = 8088;
          ssl = true;
        }
      ];

      sslCertificate = "${certPath}/${domain}.crt";
      sslCertificateKey = "${certPath}/${domain}.key";

      locations = webdavLocations;
    };
  };
  
  systemd.services.nginx = {
    serviceConfig.StateDirectory = "webdav";
    after = [ "provision-tailscale-cert.service" ];
    wants = [ "provision-tailscale-cert.service" ];
  };

  networking.firewall.allowedTCPPorts = [ 8087 8088 ];
}
