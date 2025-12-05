{
  modules = rec {

    overlay = args@{ config, pkgs, lib, secret, ... }:
      let
        fsspecVersion = "2025.3.0";

        python3 = pkgs.python312.override {
          packageOverrides = self: super: {
            fsspec = super.buildPythonPackage {
              pname = "fsspec";
              version = fsspecVersion;
              format = "wheel";

              src = pkgs.fetchurl {
                url = "https://files.pythonhosted.org/packages/py3/f/fsspec/fsspec-${fsspecVersion}-py3-none-any.whl";
                sha256 = "sha256-77h68++pED+UypGn+Mt6Tfka+fdPwQbJx+oO/XJ3wbM=";
              };

              doCheck = false;
              propagatedBuildInputs = [ ];
            };
          };
        };

        pythonPkgs = python3.pkgs;
      in
      {
        _module.args.pythonPkgs = pythonPkgs;
      };

    common = args@{ config, pkgs, lib, secret, ... }: 
      lib.mkMerge [
        (overlay args)
        {
          users.groups.odoo = { };

          users.users.odoo = {
            isSystemUser = true;
            group = "odoo";
            description = "Odoo admin service user";
            home = "/var/lib/odoo";
            createHome = true;
          };
        }
      ];

    dev = args@{ config, pkgs, lib, secret, repoDir, pythonPkgs, ... }:
      let
        addonsPath = "${repoDir}/system/services/admin/odoo/addons";
        odooConfig = pkgs.writeText "odoo.conf" ''
          [options]
          http_interface = 0.0.0.0
          addons_path = ${addonsPath}
          without_demo = all

          db_host = ${secret.HOST}
          db_port = ${secret.POSTGRES_PORT}
          db_name = ${secret.PG_ADMIN_DB}
          db_user = ${secret.PG_ADMIN_USER}
          db_password = ${secret.PG_ADMIN_PASSWORD}
          list_db = False

          [fs_storage.odoofs]
          protocol = s3
          options = {"endpoint_url": "${secret.MINIO_ENDPOINT}", "key": "${secret.MINIO_ADMIN_USER}", "secret": "${secret.MINIO_ADMIN_PASSWORD}" }
          directory_path = ${secret.MINIO_ADMIN_BUCKET}
          use_as_default_for_attachments = True
          use_filename_obfuscation = True
          model_xmlids = base.model_res_lang,base.model_res_country
          field_xmlids = base.field_res_partner__image_128
        '';

        odooWithDeps = pkgs.odoo.overrideAttrs (old: {
          propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [
            pythonPkgs.packaging
            pythonPkgs.fsspec
            pythonPkgs.s3fs
            pythonPkgs.boto3
            pythonPkgs.cachetools
            pythonPkgs.cerberus
            pythonPkgs.python-slugify
          ];
        });

      in
      lib.mkMerge [
        (common args)
        {
          systemd.services."admin-dev" = {
            description = "Odoo admin (dev)";
            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
            after = [
              "network-online.target"
              "postgresql.service"
              "minio.service"
            ];

            serviceConfig = {
              User  = "odoo";
              Group = "odoo";

              ExecStart = "${odooWithDeps}/bin/odoo -i setup -c ${odooConfig}";

              Restart    = "always";
              RestartSec = 2;
            };
          };

          networking.firewall.allowedTCPPorts = [ 8069 ];
        }
      ];

    prod = args@{ config, pkgs, lib, secret, ... }:
      lib.mkMerge [
        (common args)
        {
        }
      ];
  };
}