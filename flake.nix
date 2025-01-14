{
  description = "Home-Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        utils.follows = "flake-utils";
      };
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix?rev=6799201bec19b753a4ac305a53d34371e497941e";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    # Modules

    flake-commons = {
      url = "github:christianharke/flake-commons";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix-cli = {
      url = "github:cole-h/agenix-cli";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    homeage = {
      url = "github:jordanisaacs/homeage/release";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    i3lock-pixeled = {
      url = "gitlab:christianharke/i3lock-pixeled";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };

    nixgl = {
      url = "github:guibou/nixGL";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      flakeLib = import ./flake {
        inherit inputs;
        rootPath = ./.;
      };

      inherit (nixpkgs.lib) listToAttrs recursiveUpdate;
      inherit (flakeLib) eachSystem mkHome;
    in
    {
      lib = { rootPath }:
        import ./flake { inherit inputs rootPath; };

      homeConfigurations = listToAttrs [
        (mkHome "x86_64-linux" "sca@bcr-nl005")
      ];

    }
    // eachSystem ({ mkGeneric, mkCheck, getDevShell, mkDevShell, ... }:
      let
        mkShellCheck = pkgs: ''
          shopt -s globstar
          echo 'Running shellcheck...'
          ${pkgs.shellcheck}/bin/shellcheck --check-sourced --enable all --external-sources --shell bash ${./.}/**/*.sh
        '';
      in
      {
        checks = recursiveUpdate
          (listToAttrs [
            (mkGeneric "pre-commit-check" (system: inputs.pre-commit-hooks.lib."${system}".run {
              src = ./.;
              hooks = {
                nixpkgs-fmt.enable = true;
                shellcheck.enable = true;
                statix.enable = true;
              };
            }))

            (mkCheck "shellcheck" {
              script = mkShellCheck;
            })

            (mkCheck "nixpkgs-fmt" {
              script = pkgs: ''
                shopt -s globstar
                ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}/**/*.nix
              '';
            })
          ])
          {
            "build-sca@bcr-nl005" = self.homeConfigurations."sca@bcr-nl005".activationPackage;
          };

        devShells = listToAttrs [
          (mkDevShell "default" {
            name = "nixcfg";
            checksShellHook = system: self.checks."${system}".pre-commit-check.shellHook;
            packages = pkgs: with pkgs; [ nixpkgs-fmt shellcheck statix ];
            customShellHook = mkShellCheck;
          })
        ];
      });
}
