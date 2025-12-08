{
  modules = rec {

    common = args@{ config, pkgs, lib, ... }: {
    };

    preprod = args@{ config, pkgs, lib, secret, ... }:
      lib.mkMerge [
        (common args)
        {
          users.groups.caddy = { };
          users.users.caddy = {
            isSystemUser = true;
            group = "caddy";
            home = "/var/lib/caddy";
          };

          systemd.services.server = {
            description = "Caddy server service";
            wantedBy = [ "multi-user.target" ];

            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];

            environment = {
              CADDYPATH = "/var/lib/caddy";
              XDG_DATA_HOME = "/var/lib/caddy";
            };

            serviceConfig = {
              ExecStart = ''
                ${pkgs.caddy}/bin/caddy run \
                  --config ${pkgs.writeText "Caddyfile" ''
                    {
                      admin off
                      storage file_system {
                        root /var/lib/caddy
                      }
                    }

                    ${secret.HTTPS_HOSTNAME} {
                      tls internal
                      encode zstd gzip

                      handle /health {
                        reverse_proxy backend:8080
                      }

                      handle {
                        root * ${config.services.frontend.staticRoot}
                        try_files {path} /index.html
                        file_server
                      }
                    }
                    
                  ''} \
                  --adapter caddyfile
              '';

              User = "caddy";
              Group = "caddy";

              Restart = "on-failure";
              RestartSec = 2;

              AmbientCapabilities = "CAP_NET_BIND_SERVICE";
              CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";

              NoNewPrivileges = true;
              PrivateTmp = true;
              ProtectSystem = "strict";
              ProtectHome = true;

              StateDirectory = "caddy";
              WorkingDirectory = "/var/lib/caddy";
            };
          };

          networking.firewall.allowedTCPPorts = [ 80 443 ];
        }
      ];

    prod = args@{ config, pkgs, lib, ... }:
      lib.mkMerge [
        (common args)
        {

        }
      ];
  };
}