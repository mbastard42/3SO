{
  description = "ecommerce-infra-template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      dev = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          repoDir = "/srv/src";
          secret = import ./ops/envs/dev/secret.nix;
        };
        modules = [
          ./ops/hosts/gandi/hardware-configuration.nix
          ./ops/hosts/gandi/gandicloud.nix
          ./ops/envs/dev/host.nix

          (import ./services/frontend/frontend.nix).modules.dev
          (import ./services/backend/backend.nix).modules.dev
          (import ./services/admin/admin.nix).modules.dev
          (import ./services/databases/postgres.nix).modules.dev
          (import ./services/databases/minio.nix).modules.dev
        ];
      };

      preprod = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          repoDir = "/srv/src";
          secret = import ./ops/envs/dev/secret.nix;
        };
        modules = [
          ./ops/hosts/gandi/hardware-configuration.nix
          ./ops/hosts/gandi/gandicloud.nix
          ./ops/envs/dev/host.nix

          (import ./services/server/server.nix).modules.preprod
          (import ./services/frontend/frontend.nix).modules.prod
          # (import ./services/backend/backend.nix).modules.prod
          # (import ./services/admin/admin.nix).modules.prod
          # (import ./services/databases/postgres.nix).modules.prod
          # (import ./services/databases/minio.nix).modules.prod
        ];
      };
    };
  };
}
