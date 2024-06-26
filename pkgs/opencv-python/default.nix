{ lib
, buildPythonPackage
, fetchPypi
, fetchFromGitHub
, writeText
, git
, cmake
, numpy
, pip
, scikit-build
, setuptools
, wheel
, breakpointHook
}:
let
  version = "4.10.0.84";
  
  versionPy = writeText "version.py" ''
    opencv_version = "${version}"
    contrib = 1
    headless = 0
    rolling = 0
    ci_build = 0
  '';
  
  src = fetchFromGitHub {
    owner = "opencv";
    repo = "opencv-python";
    rev = "cce7c994d46406205eb39300bb7ca9c48d80185a";
    hash = "sha256-qxpZsH1bZNBRIbaN2gvH1/GN6CM08XudSrg4uOJqwbA=";
    fetchSubmodules = true;
    #leaveDotGit = true;
  };
in
buildPythonPackage rec {
  pname = "opencv-python";
  inherit version;
  pyproject = true;

  inherit src;

  patches = [
    ./relax-dependency-ranges.patch
  ];

  env = {
    ENABLE_CONTRIB = 1;
    ENABLE_HEADLESS = 0;
    ENABLE_ROLLING = 0;
  };

  preConfigure = ''
    #python -m find_version $ENABLE_CONTRIB $ENABLE_HEADLESS $ENABLE_ROLLING 0
    cp ${versionPy} cv2/version.py
  '';

  dontUseCmakeConfigure = true;

  nativeBuildInputs = [
    git
    cmake
    numpy
    pip
    scikit-build
    setuptools
    wheel
    breakpointHook
  ];

  propagatedBuildInputs = [
    numpy
  ];

  cmakeFlags = [
    "-D WITH_GSTREAMER=ON"
    "-D WITH_QT=ON"
    "-D WITH_TBB=ON"
    "-D ENABLE_FAST_MATH=1"
    "-D CUDA_FAST_MATH=0"
    "-D WITH_CUDA=OFF"
    "-DBUILD_opencv_cudacodec=OFF"
    "-DBUILD_opencv_cudaoptflow=OFF"
  ];

  pythonImportsCheck = [ "opencv_python" ];

  #preBuild = ''
    #echo export PATH="$PATH"
  #'';

  meta = with lib; {
    description = "Wrapper package for OpenCV python bindings";
    homepage = "https://pypi.org/project/opencv-python";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ ];
  };
}
