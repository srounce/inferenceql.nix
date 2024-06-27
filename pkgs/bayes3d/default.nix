{ lib
, fetchFromGitHub
, breakpointHook
, python3Packages
, cudaPackages
, which
, libglvnd
, libGLU
, open3d
, symlinkJoin
, genjax
, distinctipy
, pyransac3d
, opencv-python
}:
let
  rev = "21fc1ec8439b11eecc308610b23df45e7eee5ee0";

  #torch-cuda = python3Packages.torch.override (final: prev: {
  #});
  
  cuda-common-redist = with cudaPackages; [
    cuda_cccl # <thrust/*>
    libcublas # cublas_v2.h
    libcurand
    libcusolver # cusolverDn.h
    libcusparse # cusparse.h
  ];

  cuda-native-redist = symlinkJoin {
    name = "cuda-native-redist-${cudaPackages.cudaVersion}";
    paths =
      with cudaPackages;
      [
        cuda_cudart # cuda_runtime.h cuda_runtime_api.h
        cuda_nvcc
      ]
      ++ cuda-common-redist;
  };
in
python3Packages.buildPythonPackage rec {
  pname   = "bayes3d";
  version = "0.1.0+${builtins.substring 0 8 rev}";

  src = fetchFromGitHub {
    repo = pname;
    owner = "probcomp";
    inherit rev;
    hash = "sha256-8HUtf9AGgsMSSarFpRhDSzen6Mt1TJNkAhm6T3o/fO0=";
  };

  pyproject = true;

  nativeBuildInputs = with python3Packages; [
    setuptools
    setuptools-scm
    which
    #breakpointHook
  ];

  buildInputs = [
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
    cudaPackages.libcusparse
    cudaPackages.cuda_cccl
    cudaPackages.libcublas
    cudaPackages.libcusolver
    libglvnd
    libGLU
  ];

  propagatedBuildInputs = [
    python3Packages.torch
    python3Packages.graphviz
    python3Packages.imageio
    python3Packages.matplotlib
    python3Packages.meshcat
    python3Packages.natsort
    python3Packages.opencv4
    python3Packages.plyfile
    python3Packages.liblzfse
    python3Packages.tensorflow-probability
    python3Packages.timm
    python3Packages.trimesh

    distinctipy
    open3d
    opencv-python
    pyransac3d
    genjax
  ];

  preBuild = ''
    export CUDA_HOME=${cuda-native-redist}
  '';

  #preferLocalBuild = true;
}
