{
  description = "ecommerce-infra-template - NixOS preprod";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.dev = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        secret = import ./ops/envs/dev/secret.nix;
        repoDir = "/srv/ecommerce-infra-template";
      };

      modules = [

        ./ops/hosts/gandi/hardware-configuration.nix
        ./ops/hosts/gandi/gandicloud.nix
        ./ops/envs/dev/host.nix

        (import ./services/frontend/frontend.nix).modules.dev
      ];
    };
  };
}
