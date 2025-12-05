{
  modules = rec {

    common = { config, pkgs, lib, ... }: {
    };

    dev = args@{ config, pkgs, lib, repoDir, secret, ... }:
      lib.mkMerge [
        (common args)
        {
          systemd.services."backend-dev" = {
            description = "Backend (Symfony) dev server";
            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];

            path = with pkgs; [
              bash
              php83
              php83Packages.composer
            ];

            environment = {
              APP_ENV = "dev";
              APP_DEBUG = "1";
              HOME = "/root";
              COMPOSER_HOME = "/root/.composer";
              COMPOSER_ALLOW_SUPERUSER = "1";

              MINIO_ENDPOINT = secret.MINIO_ENDPOINT;
              MINIO_BUCKET = secret.MINIO_BACKEND_BUCKET;
              ODOO_ENDPOINT = secret.ODOO_ENDPOINT;
              DATABASE_URL = secret.PG_BACKEND_URL;
            };

            serviceConfig = {
              WorkingDirectory = "${repoDir}/system/services/backend/symfony";
              ExecStartPre = "${pkgs.php83Packages.composer}/bin/composer install --no-interaction";
              ExecStart = "${pkgs.php83}/bin/php -S 0.0.0.0:8000 -t public public/index.php";

              Restart = "always";
              RestartSec = 2;
            };
          };

          networking.firewall.allowedTCPPorts = [ 8000 ];
        }
      ];

    prod = { config, pkgs, lib, ... }:
      lib.mkMerge [
        common
        {

        }
      ];
  };
}