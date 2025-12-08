{
  modules = rec {

    dev = args@{ pkgs, lib, repoDir, ... }: {
      systemd.services."frontend-dev" = {
        description = "Frontend (SvelteKit) dev server";
        wantedBy = [ "multi-user.target" ];
        wants    = [ "network-online.target" ];
        after    = [ "network-online.target" ];

        path = [
          pkgs.bash
          pkgs.nodejs_22
        ];

        serviceConfig = {
          WorkingDirectory = "${repoDir}/system/services/frontend/svelte";
          ExecStartPre     = "${pkgs.nodejs_22}/bin/npm ci";
          ExecStart        = "${pkgs.nodejs_22}/bin/npm run dev";

          Restart    = "always";
          RestartSec = 2;
        };
      };

      networking.firewall.allowedTCPPorts = [ 5173 ];
    };

    prod = args@{ pkgs, lib, ... }: let
      frontendStatic = pkgs.buildNpmPackage {
        pname    = "frontend-static";
        version  = "0.1.0";
        src      = ./svelte;

        npmDepsHash    = "sha256-mjuMETFgMSBtuA3MLRF7hyoz0KglXGyrGfyxlMrIeV8=";
        npmBuildScript = "build";

        installPhase = ''
          mkdir -p $out
          cp -r build $out/
        '';
      };
    in {
      options.services.frontend.staticRoot = lib.mkOption {
        type        = lib.types.str;
        description = "Path to the built static frontend files (Svelte build output).";
      };

      config.services.frontend.staticRoot = "${frontendStatic}/build";
    };
  };
}