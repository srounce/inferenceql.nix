{
  description = "Nix utilities and cross-repo build artifacts for OpenGen";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-llvm-10.url = "github:NixOS/nixpkgs?rev=222c1940fafeda4dea161858ffe6ebfc853d3db5";

    genjax.url = "github:probcomp/genjax?ref=v0.1.1";
    genjax.flake = false;

    poetry2nix.url = "github:nix-community/poetry2nix";
    poetry2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig.extra-substituters = [ "https://numtide.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [ "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=" ];
  nixConfig.sandbox = "relaxed";

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule
        ./lib
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];


      # NOTE: This property is consumed by flake-parts.mkFlake to specify outputs of
      # the flake that are replicated for each supported system. Typically packages,
      # apps, and devshells are per system.
      perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        sppl = pkgs.callPackage ./pkgs/sppl {};

        ociImgBase = pkgs.callPackage ./pkgs/ociBase {
          inherit nixpkgs;
          basicTools = self.lib.basicTools;
        };
        
        poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };

        scopes = (self.lib.mkScopes {
          inherit pkgs internalPackages inputs poetry2nix;
          basicTools = self.lib.basicTools;
        });
        loom = scopes.callPy3Package ./pkgs/loom { };

        bayes3d = scopes.callPackage ./pkgs/bayes3d { };
        open3d = scopes.callPackage ./pkgs/open3d { };

        internalPackages = {
          #jaxlib = scopes.callPy3Package ./pkgs/jaxlib { };
          #jax = scopes.callPy3Package ./pkgs/jax { };
          jaxtyping = scopes.callPy3Package ./pkgs/jaxtyping { };
          tinygltf = scopes.callPackage ./pkgs/tinygltf { };
          PoissonRecon = scopes.callPackage ./pkgs/PoissonRecon { };
          goftests = scopes.callPackage ./pkgs/goftests { };
          parsable = scopes.callPackage ./pkgs/parsable { };
          pymetis = scopes.callPackage ./pkgs/pymetis { };
          distributions = scopes.callPackage ./pkgs/distributions { };
          genjax = scopes.callPy3Package ./pkgs/genjax { };
          distinctipy = scopes.callPy3Package ./pkgs/distinctipy { };
          pyransac3d = scopes.callPy3Package ./pkgs/pyransac3d { };
          opencv-python = scopes.callPy3Package ./pkgs/opencv-python { };
          oryx = scopes.callPy3Package ./pkgs/oryx { };
          plum-dispatch = scopes.callPy3Package ./pkgs/plum-dispatch { };
        } // packages;

        packages = {
          inherit
            loom
            sppl

            ociImgBase

            bayes3d
            open3d
            ;
        };

      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
          overlays = [
            (final: prev: {
              inherit (inputs.nixpkgs-llvm-10.legacyPackages.${system}) llvmPackages_10;
            })
          ];
        };

        inherit packages;
        
        legacyPackages.internalPackages = internalPackages;
      };

      # NOTE: this property is consumed by flake-parts.mkFlake to define fields
      # of the flake that are NOT per system, such as generic `lib` code or other
      # universal exports. Note that in our case, the lib is equivalently declared
      # by modules that are imported (see ./lib/devtools/default.nix)
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
