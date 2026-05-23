{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for your binaries here
    # Common ones include:
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    # ... any others you find you need
  ];
}
