{ fetchFromGitHub
, python3Packages
, cmake
, git
, ispc
, nasm
, xorg
, vulkan-tools
, libjpeg
}:
python3Packages.buildPythonPackage rec {
  pname = "open3d";
  version = "0.18.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "isl-org";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-VMykWYfWUzhG+Db1I/9D1GTKd3OzmSXvwzXwaZnu8uI=";
  };

  #doCheck = false;

  env.VERBOSE = "1";

  nativeBuildInputs = [
    cmake
    ispc
    git
    nasm
  ];

  buildInputs = [
    xorg.libX11
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXcursor
    vulkan-tools
    libjpeg
  ];

  propagatedBuildInputs = [
    python3Packages.pybind11
  ];

  cmakeFlags = [
    #"--debug-output"
    "--loglevel=VERBOSE"
    #"--trace"
    "-DCMAKE_ISPC_COMPILER=${ispc}/bin/ispc"
  ];
}
