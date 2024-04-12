{
  stdenv,
  cmake,
  eigen,
  protobuf3_20,
  src, version
}:
stdenv.mkDerivation {
  pname = "distributions-shared";

  inherit version src;

  nativeBuildInputs = [ cmake ];
  buildInputs = [eigen protobuf3_20 ];

  env.DISTRIBUTIONS_USE_PROTOBUF = 1;

  preConfigure = ''
    make protobuf
  '';

  fixupPhase = ''
    ln -sv $out/lib/libdistributions_shared_release.so $out/lib/libdistributions_shared.so
    ln -sv $out/lib/libdistributions_shared_release.so $out/lib/libdistributions_shared_debug.so
  '';
}
