{
  fetchPypi,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "goftests";
  version = "0.2.7";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5s0NugSus2TuZIInesCNJNAtxEHnZLQIjn0pxGgwL/o=";
  };

  buildInputs = with python3Packages; [ numpy scipy ];

  doCheck = false;

  # https://github.com/numba/numba/issues/8698#issuecomment-1584888063 
  NUMPY_EXPERIMENTAL_DTYPE_API = 1;

  patchPhase = ''
    mkdir -p dist
  '';
}
