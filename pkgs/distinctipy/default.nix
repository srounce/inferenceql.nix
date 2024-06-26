{ fetchPypi
, python3Packages
}:
python3Packages.buildPythonPackage rec {
  pname = "distinctipy";
  version = "1.3.4";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/tl6//Gvtz7KqHyFRhAh8LqJ+uYwZ8ASW5ZzUmUQqsQ=";
  };

  doCheck = false;

  nativeBuildInputs = [
    python3Packages.setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    numpy
  ];
}

