{ fetchFromGitHub
, optax
}:
(optax.overrideAttrs rec {
  version = "0.1.7";
  src = fetchFromGitHub {
    owner = "deepmind";
    repo = "optax";
    rev = "refs/tags/v${version}";
    hash = "sha256-zSMJxagPe2rkhrawJ+TWXUzk6V58IY6MhWmEqLVtOoA=";
  };
})
