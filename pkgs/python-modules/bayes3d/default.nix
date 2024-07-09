{ lib
, fetchFromGitHub
, breakpointHook
, buildPythonPackage
, cudaPackages_11
, which
, libglvnd
, libGLU
, open3d
, symlinkJoin
, genjax
, distinctipy
, pyransac3d
, opencv-python
, setuptools
, setuptools-scm
, torch
, pytorchWithCuda
, graphviz
, imageio
, matplotlib
, meshcat
, natsort
, opencv4
, plyfile
, liblzfse
, tensorflow-probability
, timm
, trimesh
}:
let
  rev = "eb942aeca9441957c5cc62da26dde3e2c70c23c2";

   cuda-common-redist = with cudaPackages_11; [
     cuda_cccl # <thrust/*>
     libcublas # cublas_v2.h
     libcurand
     libcusolver # cusolverDn.h
     libcusparse # cusparse.h
   ];
  
   cuda-native-redist = symlinkJoin {
     name = "cuda-native-redist-${cudaPackages_11.cudaVersion}";
     paths =
       with cudaPackages_11;
       [
         cuda_cudart # cuda_runtime.h cuda_runtime_api.h
         cuda_nvcc
       ]
       ++ cuda-common-redist;
   };
in
buildPythonPackage rec {
  pname   = "bayes3d";
  version = "0.1.0+${builtins.substring 0 8 rev}";

  src = fetchFromGitHub {
    repo = pname;
    owner = "probcomp";
    inherit rev;
    hash = "sha256-jtiLyBu3G+B4Qx1iBq7gVlzb4sdaaB25Gyk+fxcgKxU=";
  };

  pyproject = true;

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    which
    #breakpointHook
  ];

  buildInputs = [
    # cudaPackages.cuda_nvcc
    # cudaPackages.cuda_cudart
    # cudaPackages.libcusparse
    # cudaPackages.cuda_cccl
    # cudaPackages.libcublas
    # cudaPackages.libcusolver
    cudaPackages_11.cudatoolkit.lib
    pytorchWithCuda
    libglvnd
    libGLU
  ];

  propagatedBuildInputs = [
    distinctipy
    genjax
    graphviz
    imageio
    liblzfse
    matplotlib
    meshcat
    natsort
    open3d
    opencv-python
    opencv4
    plyfile
    pyransac3d
    tensorflow-probability
    timm
    #torch
    trimesh
  ];

   preBuild = ''
     export CUDA_HOME=${cuda-native-redist}
   '';

  #preferLocalBuild = true;
}
