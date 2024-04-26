{ stdenv
, lib
, python3Packages
, fetchPypi
, fetchurl

, tree
, unzip
, zip

, autoPatchelfHook
, breakpointHook
, libtensorflow-bin
, libusb
, cudaPackages

, libGL
, libglvnd
, libdrm
, expat
, xorg
, libllvm
, llvmPackages_10
}:
let
  inherit (python3Packages)
    buildPythonPackage
    ipywidgets
    matplotlib
    numpy
    pandas
  plyfile
  pytorchWithCuda
  pyyaml
  scikitlearn
  scipy
  tqdm
  ;

  #addict = buildPythonPackage {
    #pname = "addict";
    #version = "2.4.0";

    #src = fetchPypi {
      #pname = "addict";
      #version = "2.4.0";
      #sha256 = "1574sicy5ydx9pvva3lbx8qp56z9jbdwbj26aqgjhyh61q723cmk";
    #};
  #};

  version = "0.18.0";
  pname = "open3d";
  pythonAbi = "cp311";
  pythonPlatform = "manylinux_2_27_x86_64";

in buildPythonPackage {
  inherit pname version;
  format = "wheel";

  #src = fetchPypi {
    #inherit pname version;
    #format = "wheel";
    #python = pythonAbi;
    #abi = pythonAbi;
    #dist = "py3";
    #sha256 = "";
  #};
  
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/5c/ba/a4c5986951344f804b5cbd86f0a87d9ea5969e8d13f1e8913e2d8276e0d8/open3d-0.18.0-cp311-cp311-manylinux_2_27_x86_64.whl";
    hash = "sha256-jj0dGQCo9NlW9oGcJGx4CBclubCIj4VJ0qeknI2qEwM=";
  };

  patchPhase = ''
    ${unzip}/bin/unzip ./dist/open3d-${version}-${pythonAbi}-${pythonAbi}-${pythonPlatform}.whl -d tmp
    rm ./dist/open3d-${version}-${pythonAbi}-${pythonAbi}-${pythonPlatform}.whl
    #sed -i 's/sklearn/scikit-learn/g' tmp/open3d-${version}.dist-info/METADATA
    cd tmp
    ${zip}/bin/zip -0 -r ../dist/open3d-${version}-${pythonAbi}-${pythonAbi}-${pythonPlatform}.whl ./*
    cd ../
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    breakpointHook
  ];

  buildInputs = [
    # so deps
    stdenv.cc.cc.lib
    libusb.out
    pytorchWithCuda
    libtensorflow-bin
    cudaPackages.cudatoolkit.lib
    libGL
    libglvnd
    libdrm
    expat
    xorg.libXxf86vm
    xorg.libXfixes
    libllvm
  ];

  propagatedBuildInputs = [
    # py deps
    ipywidgets
    tqdm
    pyyaml
    pandas
    plyfile
    scipy
    scikitlearn
    numpy
    #addict
    matplotlib
  ];

  #preBuild = ''
    #mkdir $out
  #'';

  preFixup = ''
    echo "OUTPUT TO: $out"
    cd $out/lib/python3.*/site-packages/open3d
    rm libGL.so.1 libEGL.so.1
    ln -s ${libGL}/lib/libGL.so.1 libGL.so.1
    ln -s ${libGL}/lib/libEGL.so.1 libEGL.so.1
    #exit 1
  '';
}