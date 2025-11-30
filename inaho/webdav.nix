{ config, pkgs, ... }:

{
  age.secrets.webdav-htpasswd = {
    file = ../secrets/webdav-htpasswd.age;
    owner = "nginx";
    group = "nginx";
    mode = "0400";
  };

  services.nginx = {
    enable = true;
    
    virtualHosts."inaho.tailcbbed9.ts.net" = {
      listen = [
        { addr = "inaho.tailcbbed9.ts.net"; port = 8087; }
      ];
      
      locations."/" = {
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
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/webdav 0755 nginx nginx -"
    "d /var/lib/webdav/joplin 0755 nginx nginx -"
    "d /var/lib/webdav/tmp 0755 nginx nginx -"
  ];

  networking.firewall.allowedTCPPorts = [ 8087 ];
}
