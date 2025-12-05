{
  modules = rec {

    common = { config, pkgs, lib, secret, ... }: {
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_16;
        dataDir = "/var/lib/postgresql/16";

        enableTCPIP = true;

        initialScript = pkgs.writeText "init.sql" ''
          CREATE ROLE ${secret.PG_ADMIN_USER}   LOGIN PASSWORD '${secret.PG_ADMIN_PASSWORD}';
          CREATE ROLE ${secret.PG_BACKEND_USER} LOGIN PASSWORD '${secret.PG_BACKEND_PASSWORD}';

          CREATE DATABASE ${secret.PG_ADMIN_DB}   OWNER ${secret.PG_ADMIN_USER};
          CREATE DATABASE ${secret.PG_BACKEND_DB} OWNER ${secret.PG_BACKEND_USER};

          REVOKE CONNECT ON DATABASE ${secret.PG_ADMIN_DB}   FROM PUBLIC;
          REVOKE CONNECT ON DATABASE ${secret.PG_BACKEND_DB} FROM PUBLIC;

          GRANT CONNECT ON DATABASE ${secret.PG_ADMIN_DB}   TO ${secret.PG_ADMIN_USER};
          GRANT CONNECT ON DATABASE ${secret.PG_BACKEND_DB} TO ${secret.PG_BACKEND_USER};
        '';

        authentication = ''
          local   all   all                              peer
          host    all   all           127.0.0.1/32       scram-sha-256
          host    all   all           ::1/128            scram-sha-256
        '';
      };
    };

    dev = args@{ config, pkgs, lib, ... }:
      lib.mkMerge [
        (common args)
        {
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