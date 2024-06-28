{ callPy3Package
, inputs
, poetry2nix
, python311
, fetchPypi
, stdenv
, pkgs
, oryx
, plum-dispatch
, jax
, jaxtyping
}:
let
  src = stdenv.mkDerivation {
    name = "genjax-source";
    version = inputs.genjax.shortRev;
    src = inputs.genjax;
    
    patches = [
      ./set-pyproject-version.patch
    ];

    installPhase = ''
      mkdir $out
      ls -alsph $src
      cp -rfv ./. $out
    '';
  };

  #jax = python311.pkgs.buildPythonPackage rec {
    #pname = "jax";
    #version = "0.4.28";

    #src = fetchPypi {
      #inherit pname version;
      #hash = "sha256-3PCkSv8uFxPworNpKBzVt52MGPwQGJBcQSWJfLBrN+k=";
    #};

    #nativeBuildInputs = [
      
    #];

    #propagatedBuildInputs = with python311.pkgs; [
      #pip
      #scipy
      #opt-einsum
      #ml-dtypes
      #jaxlib
    #];
  #};

  #jaxlib = python311.pkgs.buildPythonPackage {
    #pname = "";
    #version = "";

    #src = fetchPypi {

    #};
  #};
in
python311.pkgs.buildPythonPackage {
  __noChroot = true;

  pname = "genjax";
  version = "0.1.1";
  inherit src;
  format = "pyproject";

  nativeBuildInputs = [
    #pkgs.poetry
    #python311.pkgs.poetry-core
    python311.pkgs.poetry-dynamic-versioning
  ];

  propagatedBuildInputs = [  ] ++ (with python311.pkgs; [
    beartype
    deprecated
    dill
    jax
    jaxtyping
    equinox
    numpy
    optax
    oryx
    plum-dispatch
    pygments
    rich
    tensorflow-probability
    typing-extensions
  ]);
}
