{ fetchurl
, callPy3Package
, inputs
, poetry2nix
, python311
, fetchPypi
, stdenv
, pkgs
, oryx
, plum-dispatch
}:
let
  wheelUrls = {
    "x86_64-linux" = {
      url = "https://files.pythonhosted.org/packages/a6/a3/951da3d1487b2f8995a2a14cc7e9496c9a7c93aa1f1d0b33e833e24dee92/jaxlib-0.4.30-cp311-cp311-manylinux2014_x86_64.whl";
      hash = "sha256-FrKrGOqQ0uFZQbz0XeN6/C8omgKRKciMjXq6BATdAEM=";
    };

    "aarch64-linux" = {
      url = "https://files.pythonhosted.org/packages/a4/f8/b85a46cb0cc4bc228cea4366b0d15caf42656c6d43cf8c91d90f7399aa4d/jaxlib-0.4.30-cp311-cp311-manylinux2014_aarch64.whl";
      hash = "";
    };
  
    "x86_64-darwin" = {
      url = "https://files.pythonhosted.org/packages/12/95/399da9204c3b13696baefb93468402f3389416b0caecfd9126aa94742bf2/jaxlib-0.4.30-cp311-cp311-macosx_11_0_arm64.whl";
      hash = "";
    };

    "aarch64-darwin" = {
      url = "https://files.pythonhosted.org/packages/33/2d/b6078f5d173d3087d32b1b49e5f65d406985fb3894ff1d21905972b9c89d/jaxlib-0.4.30-cp311-cp311-macosx_10_14_x86_64.whl";
      hash = "";
    };
  };
in
python311.pkgs.buildPythonPackage rec {
  pname = "jaxlib";
  version = "0.4.30";

  src = fetchurl (
    if builtins.hasAttr stdenv.system wheelUrls
    then wheelUrls.${stdenv.system}
    else throw "Unsupported system"
  );

  format = "wheel";

  nativeBuildInputs = [
  ];

  propagatedBuildInputs = [  ] ++ (with python311.pkgs; [
  ]);
}
