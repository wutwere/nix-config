{pkgs ? import <nixpkgs> {}}: let
  rocale-zip = pkgs.fetchurl {
    url = "https://github.com/Roblox/rocale-cli/releases/download/v0.1.2/rocale-cli-linux-x86_64.zip";
    hash = "sha256-rTflPiYSsjhFRosZj94eNgqinBlxIEuPYs13+Pdil+E=";
  };

  rocale-bin = pkgs.stdenv.mkDerivation {
    pname = "rocale-cli-unpatched";
    version = "0.1.2";
    src = rocale-zip;
    nativeBuildInputs = [pkgs.unzip];
    sourceRoot = ".";
    unpackPhase = "unzip $src";
    installPhase = "mkdir -p $out/bin && chmod +x rocale-cli && cp rocale-cli $out/bin/";
    dontStrip = true;
    dontPatchELF = true;
  };
in
  pkgs.buildFHSEnv {
    name = "rocale-cli";
    targetPkgs = pkgs:
      with pkgs; [
        glibc
        stdenv.cc.cc.lib
        zlib
      ];
    runScript = "${rocale-bin}/bin/rocale-cli";
  }
