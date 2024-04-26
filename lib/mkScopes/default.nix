{ pkgs, basicTools, internalPackages }:
let
  callPackage = pkgs.newScope (
    pkgs
    // {
      inherit callPackage callPy3Package;
      basicTools = basicTools pkgs;
    }
    // internalPackages
  );

  callPy3Package = pkgs.newScope (
    pkgs
    // pkgs.python3Packages
    // {
      inherit callPackage callPy3Package;
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
