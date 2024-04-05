{ pkgs
, fetchFromGitHub
, python3Packages
, cudaPackages
, which
, libglvnd
, libGLU
, open3d
}:
let
  rev = "ba4234a4720512f7dc45d11b8b8fbf449a439c0a";

  #torch-cuda = python3Packages.torch.override (final: prev: {
  #});
in
python3Packages.buildPythonPackage rec {
  pname   = "bayes3d";
  version = "0.1.0+${builtins.substring 0 8 rev}";

  src = fetchFromGitHub {
    repo = pname;
    owner = "probcomp";
    inherit rev;
    hash = "sha256-/Cdm4Syfhm8QFCgKWITvaSGKmDjR38mepQez4xOzH1A=";
  };

  pyproject = true;

  nativeBuildInputs = with python3Packages; [
    setuptools
    setuptools-scm
    which
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
    #python3Packages.genjax # TODO: missing
    #python3Packages.distinctipy # TODO: missing
    python3Packages.imageio
    python3Packages.matplotlib
    python3Packages.meshcat
    python3Packages.natsort
    open3d
    #python3Packages.opencv-python # TODO: missing
    python3Packages.opencv4
    python3Packages.plyfile
    python3Packages.liblzfse
    #python3Packages.pyransac3d # TODO: missing
    python3Packages.tensorflow-probability
    python3Packages.timm
    python3Packages.trimesh
  ];

  env.CUDA_HOME = "${cudaPackages.cuda_nvcc}";
}
