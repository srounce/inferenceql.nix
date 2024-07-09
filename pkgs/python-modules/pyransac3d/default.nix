{ fetchFromGitHub
, python3
, buildPythonPackage
}:
# TODO: upstream me
buildPythonPackage rec {
  pname = "pyransac3d";
  version = "0.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "leomariga";
    repo = "pyRANSAC-3D";
    rev = "v${version}";
    hash = "sha256-QplIgH+zjkZgPWMvvpV2yM/HEEBRea4D+dG7G7h2jdQ=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    numpy
  ];

  pythonImportsCheck = [ "pyransac3d" ];
}
