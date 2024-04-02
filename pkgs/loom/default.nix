{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, cpplint
, cython
, goftests
, imageio
, matplotlib
, mock
, nose
, numpy
, pandas
, parsable
, pep8
, pkgs
, protobuf3_20
, pyflakes
, python3Packages
, pytest
, pymetis
, scikit-learn
, scipy
, simplejson
, cmake
, gnumake
, stdenv
, zlib
, eigen
, distributions
, gperftools
}:
let
  protobuf = protobuf3_20;

  version = "0.2.10";

  src = fetchFromGitHub {
    owner = "posterior";
    repo = "loom";
    # Use the forked branch that adds support for Python 3
    rev = "346757a80fccc0a3406879829926fc7db8d422e6";
    hash = "sha256-4oj03uG9mgQ9YpK6Ractnw3nf8ekfiHpUndOU4TIdYo=";
  };

  loom-cpp = stdenv.mkDerivation {
    inherit src version;
    pname = "loom-cpp";

    nativeBuildInputs = [
      cmake
      protobuf
      eigen
      zlib
      gperftools
    ];

    buildInputs = [
      distributions.distributions-shared
    ];

    enableParallelBuilding = true;

    outputs = [ "out" "dev" ];

    prePatch = ''
      sed -i 's/-Werror//g' CMakeLists.txt # remove -Werror
    '';

    installPhase = ''
      installPhase

      mkdir $dev
      cp -r .. $dev
      rm -rf $dev/build
    '';
  };

  contextlib2 = python3Packages.contextlib2.overrideAttrs (final: prev: {
    # https://github.com/jazzband/contextlib2/pull/52
    # updated to support Python3
    src = fetchFromGitHub {
      owner = "mr-c";
      repo = "contextlib2";
      rev = "b8b7eb8ecd9e012178b5dcec4313edded751a459";
      hash = "sha256-FSx/vKctoFl4NlwzNDa9eDNUXeW1J875/nB6of+5gQk=";
    };
  });
in
buildPythonPackage {
  inherit version;

  src = loom-cpp.dev;

  pname = "loom";

  nativeBuildInputs = [
    cmake
    setuptools
    wheel
    protobuf
  ];

  buildInputs = [
    cmake
    gnumake

    distributions.distributions-shared
    distributions
    zlib
    eigen
    gperftools
  ];

  nativeCheckInputs = [
    pyflakes
  ];

  # https://github.com/numba/numba/issues/8698#issuecomment-1584888063 
  NUMPY_EXPERIMENTAL_DTYPE_API = 1;

  DISTRIBUTIONS_USE_PROTOBUF = 1;

  propagatedBuildInputs = [
    contextlib2
    cpplint
    cython
    distributions
    distributions.distributions-shared
    goftests
    imageio
    matplotlib
    mock
    nose
    numpy
    pandas
    parsable
    pep8
    python3Packages.protobuf
    pyflakes
    pymetis
    scikit-learn
    scipy
    setuptools
    simplejson
    pytest
  ];

  # TODO: make tests run in checkPhase
  doCheck = false;

  pythonImportsCheck = [
    "loom"
    "loom.cleanse"
    "loom.crossvalidate"
    "loom.datasets"
    "loom.format"
    "loom.generate"
    "loom.preql"
    "loom.query"
    "loom.schema_pb2"
    "loom.store"
    "loom.tasks"
    "loom.transforms"
    "loom.util"
    "loom.watch"
  ];

  dontUseCmakeConfigure = true;

  enableParallelBuilding = true;

  prePatch = ''
    sed -i 's/-Werror//g' CMakeLists.txt # remove -Werror
  '';

  passthru.loom-cpp = loom-cpp;

  meta = with lib; {
    description = "A streaming cross-cat inference engine";
    homepage = "https://github.com/emilyfertig/loom";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
