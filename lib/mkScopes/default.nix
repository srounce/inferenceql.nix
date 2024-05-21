{ pkgs, basicTools }: let
  callPackage = pkgs.newScope (
    pkgs
    // {
      inherit callPackage;
      basicTools = basicTools pkgs;
    }
  );
  callPy3Package = pkgs.newScope (
    pkgs
    // pkgs.python3Packages
    // {
      inherit callPackage;
      basicTools = basicTools pkgs;
    }
  );
in {
  inherit callPackage callPy3Package ;
}
