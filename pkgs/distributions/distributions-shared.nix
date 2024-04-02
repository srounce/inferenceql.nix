{ lib,
  stdenv,
  cmake,
  eigen,
  protobuf3_20,
  python3,
  src, version
}:
stdenv.mkDerivation {
  pname = "distributions-shared";

  inherit version src;

  nativeBuildInputs = [ cmake python3 python3.pkgs.pyflakes ];
  buildInputs = [ eigen protobuf3_20 ];

  DISTRIBUTIONS_USE_PROTOBUF = 1;

  patches = [
    ./x86-intrinsics-only-on-intel.patch
  ] ++ (lib.lists.optionals stdenv.isAarch64 [
    ./remove-sse-flags.patch
  ]);

  preConfigure = ''
    make protobuf
  '';

  fixupPhase = ''
    ln -sv $out/lib/libdistributions_shared_release.so $out/lib/libdistributions_shared.so
    ln -sv $out/lib/libdistributions_shared_release.so $out/lib/libdistributions_shared_debug.so
  '';
}
