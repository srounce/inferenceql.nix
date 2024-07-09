{ fetchPypi
, beartype
}:
(beartype.overrideAttrs (final: prev: rec {
  version = "0.16.4";
  
  src = fetchPypi {
    inherit (prev) pname;
    inherit version;
    hash = "sha256-GtqJzy1usw624Vbu0utUkzV3gpN5ENdDgJGOU8Lq4L8=";
  };
}))
