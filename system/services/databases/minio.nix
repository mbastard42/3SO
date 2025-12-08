{
  modules = rec {

    deps = args@{ pkgs, lib, secret, ... }:
      let
        adminBucket   = secret.PG_ADMIN_DB;
        backendBucket = secret.PG_BACKEND_DB;

        mkPolicy = bucket: actions: {
          Version   = "2012-10-17";
          Statement = [
            {
              Effect   = "Allow";
              Action   = [ "s3:ListBucket" ];
              Resource = [ "arn:aws:s3:::${bucket}" ];
            }
            {
              Effect   = "Allow";
              Action   = actions;
              Resource = [ "arn:aws:s3:::${bucket}/*" ];
            }
          ];
        };

        policies = {
          truthRw  = mkPolicy adminBucket   [ "s3:GetObject" "s3:PutObject" "s3:DeleteObject" ];
          truthRo  = mkPolicy adminBucket   [ "s3:GetObject" ];
          mirrorRw = mkPolicy backendBucket [ "s3:GetObject" "s3:PutObject" "s3:DeleteObject" ];
        };

        truthRwFile  = pkgs.writeText "truth-rw.json"  (builtins.toJSON policies.truthRw);
        truthRoFile  = pkgs.writeText "truth-ro.json"  (builtins.toJSON policies.truthRo);
        mirrorRwFile = pkgs.writeText "mirror-rw.json" (builtins.toJSON policies.mirrorRw);

        baseExec = "${pkgs.minio}/bin/minio server /var/lib/minio";

        minioInitScript = pkgs.writeShellScript "minio-init.sh" ''
          #!/bin/sh
          set -e

          mc alias set root "$MINIO_ENDPOINT" "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" >/dev/null 2>&1

          mc mb --ignore-existing root/"$MINIO_ADMIN_BUCKET"   || true
          mc mb --ignore-existing root/"$MINIO_BACKEND_BUCKET" || true

          mc admin policy create root truth-rw  ${truthRwFile}  || true
          mc admin policy create root truth-ro  ${truthRoFile}  || true
          mc admin policy create root mirror-rw ${mirrorRwFile} || true

          mc admin user add root "$MINIO_ADMIN_USER" "$MINIO_ADMIN_PASSWORD"   || true
          mc admin user add root "$MINIO_BACKEND_USER" "$MINIO_BACKEND_PASSWORD" || true

          mc admin policy attach root truth-rw  --user "$MINIO_ADMIN_USER"   || true
          mc admin policy attach root truth-ro  --user "$MINIO_BACKEND_USER" || true
          mc admin policy attach root mirror-rw --user "$MINIO_BACKEND_USER" || true
        '';
      in
      {
        minio = {
          inherit
            truthRwFile
            truthRoFile
            mirrorRwFile
            baseExec
            minioInitScript;
        };
      };

    common = args@{ config, pkgs, lib, secret, ... }:
      let
        minioDeps = (deps args).minio;
        inherit (minioDeps)
          truthRwFile
          truthRoFile
          mirrorRwFile
          baseExec
          minioInitScript;
      in
      {
        systemd.services.minio = {
          description = "MinIO object storage";
          wantedBy    = [ "multi-user.target" ];
          wants       = [ "network-online.target" ];
          after       = [ "network-online.target" ];
          
          path = [
            pkgs.minio
            pkgs.getent
          ];

          environment = {
            MINIO_ROOT_USER     = secret.MINIO_ROOT_USER;
            MINIO_ROOT_PASSWORD = secret.MINIO_ROOT_PASSWORD;
          };

          serviceConfig = {
            StateDirectory   = "minio";
            WorkingDirectory = "/var/lib/minio";
            ExecStart        = lib.mkDefault baseExec;
            Restart          = "always";
            RestartSec       = 2;
          };
        };

        systemd.services."minio-init" = {
          description = "Initialise MinIO buckets, users, policies";

          wantedBy = [ "multi-user.target" ];
          after    = [ "minio.service" ];
          requires = [ "minio.service" ];

          path = [
            pkgs.minio-client
            pkgs.bash
            pkgs.getent
          ];

          environment = {
            TRUTH_RW_FILE  = truthRwFile;
            TRUTH_RO_FILE  = truthRoFile;
            MIRROR_RW_FILE = mirrorRwFile;

            MINIO_ENDPOINT         = secret.MINIO_ENDPOINT;
            MINIO_ROOT_USER        = secret.MINIO_ROOT_USER;
            MINIO_ROOT_PASSWORD    = secret.MINIO_ROOT_PASSWORD;
            MINIO_ADMIN_BUCKET     = secret.MINIO_ADMIN_BUCKET;
            MINIO_BACKEND_BUCKET   = secret.MINIO_BACKEND_BUCKET;
            MINIO_ADMIN_USER       = secret.MINIO_ADMIN_USER;
            MINIO_ADMIN_PASSWORD   = secret.MINIO_ADMIN_PASSWORD;
            MINIO_BACKEND_USER     = secret.MINIO_BACKEND_USER;
            MINIO_BACKEND_PASSWORD = secret.MINIO_BACKEND_PASSWORD;
          };

          serviceConfig = {
            Type                  = "oneshot";
            ExecStart             = minioInitScript;
            Restart               = "on-failure";
            RestartSec            = 2;
            StartLimitIntervalSec = 60;
            StartLimitBurst       = 10;
          };
        };
      };

    dev = args@{ config, pkgs, lib, ... }:
      lib.mkMerge [
        (common args)
        {
          systemd.services.minio.serviceConfig.ExecStart =
            lib.mkForce "${pkgs.minio}/bin/minio server /var/lib/minio --console-address :9001";

          networking.firewall.allowedTCPPorts = [ 9000 9001 ];
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