{ pkgs, basicTools, internalPackages, poetry2nix, inputs }:
let
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
