{ callPy3Package
, inputs
, poetry2nix
, python311
, pkgs
, oryx
, plum-dispatch
}:
poetry2nix.mkPoetryPackages {
  projectDir = inputs.genjax;

  overrides = poetry2nix.overrides.withDefaults (final: prev: {
    #dm-tree = python311.pkgs.dm-tree;
    #ruff = python311.pkgs.python-lsp-ruff;
  });

  preferWheels = true;

  python = python311;
}
#python311.pkgs.buildPythonPackage {
  #pname = "genjax";
  #version = "0.1.0";
  #inherit src;
  #format = "pyproject";

  #nativeBuildInputs = [
    #pkgs.poetry
    #python311.pkgs.poetry-core
    #python311.pkgs.poetry-dynamic-versioning
  #];

  #propagatedBuildInputs = with python311.pkgs; [
    #beartype
    #deprecated
    #dill
    #equinox
    #jax
    #jaxtyping
    #numpy
    #optax
    #oryx
    #plum-dispatch
    #pygments
    #rich
    #tensorflow-probability
    #typing-extensions
  #];
#}
