{
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage
(finalAttrs: {
  pname = "wally-package-types";
  version = "v1.6.2";

  src = fetchFromGitHub {
    owner = "JohnnyMorganz";
    repo = "wally-package-types";
    tag = finalAttrs.version;
    hash = "sha256-ynd5z2pbhGnPTKuJQG4EJL/Zy/X9lTCjSi8Cd6nRSsA=";
  };
  cargoLock.lockFile = ./Cargo.lock;
})
