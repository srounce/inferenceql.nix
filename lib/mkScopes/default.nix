{ pkgs, basicTools, internalPackages, inputs }:
let
  poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };

  callPackage = pkgs.newScope (
    pkgs
    // {
      inherit
        callPackage
        callPy3Package
        inputs
        poetry2nix
        ;
      basicTools = basicTools pkgs;
    }
    // internalPackages
  );

  callPy3Package = pkgs.newScope (
    pkgs
    // pkgs.python3Packages
    // {
      inherit
        callPackage
        callPy3Package
        inputs
        poetry2nix
        ;
      basicTools = basicTools pkgs;
    }
    // internalPackages
  );
in
{
  inherit
    callPackage
    callPy3Package
    ;
}
