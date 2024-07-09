{
  lib,
  stdenv,
  fetchurl,

  # Build-time dependencies:
  buildPythonPackage,
  curl,
  fetchFromGitHub,
  jsoncpp,
  autoPatchelfHook,

  # Python dependencies:
  absl-py,
  flatbuffers,
  ml-dtypes,
  numpy,
  scipy,
  six,

  # Runtime dependencies:
  double-conversion,
  giflib,
  libjpeg_turbo,
  python,
  snappy,

}:

let
  pname = "jaxlib";
  version = "0.4.28";

  # REMOVEME
  effectiveStdenv = stdenv;

  meta = with lib; {
    description = "JAX is Autograd and XLA, brought together for high-performance machine learning research";
    homepage = "https://github.com/google/jax";
    license = licenses.asl20;
    maintainers = with maintainers; [ ndl ];
    platforms = platforms.unix;
    # aarch64-darwin is broken because of https://github.com/bazelbuild/rules_cc/pull/136
    # however even with that fix applied, it doesn't work for everyone:
    # https://github.com/NixOS/nixpkgs/pull/184395#issuecomment-1207287129
    # NOTE: We always build with NCCL; if it is unsupported, then our build is broken.
    # broken = effectiveStdenv.isDarwin || nccl.meta.unsupported;
  };


  arch =
    # KeyError: ('Linux', 'arm64')
    if effectiveStdenv.hostPlatform.isLinux && effectiveStdenv.hostPlatform.linuxArch == "arm64" then
      "aarch64"
    else
      effectiveStdenv.hostPlatform.linuxArch;

  xla = effectiveStdenv.mkDerivation {
    pname = "xla-src";
    version = "unstable";

    src = fetchFromGitHub {
      owner = "openxla";
      repo = "xla";
      # Update this according to https://github.com/google/jax/blob/jaxlib-v${version}/third_party/xla/workspace.bzl.
      rev = "e8247c3ea1d4d7f31cf27def4c7ac6f2ce64ecd4";
      hash = "sha256-ZhgMIVs3Z4dTrkRWDqaPC/i7yJz2dsYXrZbjzqvPX3E=";
    };

    dontBuild = true;

    # This is necessary for patchShebangs to know the right path to use.
    nativeBuildInputs = [ python ];

    # Main culprits we're targeting are third_party/tsl/third_party/gpus/crosstool/clang/bin/*.tpl
    postPatch = ''
      patchShebangs .
    '';

    installPhase = ''
      cp -r . $out
    '';
  };

  platformTag =
    if effectiveStdenv.hostPlatform.isLinux then
      "manylinux2014_${arch}"
    else if effectiveStdenv.system == "x86_64-darwin" then
      "macosx_10_9_${arch}"
    else if effectiveStdenv.system == "aarch64-darwin" then
      "macosx_11_0_${arch}"
    else
      throw "Unsupported target platform: ${effectiveStdenv.hostPlatform}";

  wheelUrls = {
    "x86_64-linux" = {
      url = "https://files.pythonhosted.org/packages/8e/d7/65b1f5cf05d9159abd5882a51695d4d1b386bc8e26140eff7159854777f2/jaxlib-0.4.28-cp311-cp311-manylinux2014_x86_64.whl";
      hash = "sha256-Rc4PPIQM/4I2z/JsN/Jsn/B4aV+T4MFiwyDCgfUEEnU=";
    };

    "aarch64-linux" = {
      url = "https://files.pythonhosted.org/packages/f2/87/0c07ec3ba047ca58c940d1c3050cd08c4390bca992cdfeeb2d9d356cd2c6/jaxlib-0.4.28-cp311-cp311-manylinux2014_aarch64.whl";
      hash = "";
    };
  
    "x86_64-darwin" = {
      url = "https://files.pythonhosted.org/packages/e0/b2/896d8d1f35e16e9f88ae6a753012e6d5a6882507ea58e7f0dd5af68ee1e8/jaxlib-0.4.28-cp311-cp311-macosx_10_14_x86_64.whl";
      hash = "";
    };

    "aarch64-darwin" = {
      url = "https://files.pythonhosted.org/packages/75/f3/1ce8b092ca68dfcfa6a0ee0a8a410f6d877e1628c05799c5d03757682c66/jaxlib-0.4.28-cp311-cp311-macosx_11_0_arm64.whl";
      hash = "";
    };
  };
in
buildPythonPackage {
  inherit meta pname version;
  format = "wheel";

  src = fetchurl (
    if builtins.hasAttr stdenv.system wheelUrls
    then wheelUrls.${stdenv.system}
    else throw "Unsupported system '${stdenv.system}'"
  );

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ 
    stdenv.cc.cc.lib
  ];

  dependencies = [
    absl-py
    curl
    double-conversion
    flatbuffers
    giflib
    jsoncpp
    libjpeg_turbo
    ml-dtypes
    numpy
    scipy
    six
    snappy
  ];

  pythonImportsCheck = [
    "jaxlib"
    # `import jaxlib` loads surprisingly little. These imports are actually bugs that appeared in the 0.4.11 upgrade.
    "jaxlib.cpu_feature_guard"
    "jaxlib.xla_client"
  ];
}
