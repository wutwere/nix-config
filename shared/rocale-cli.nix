{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) stdenv fetchurl unzip buildFHSEnv writeShellScriptBin;

  version = "0.1.2";

  # Define sources for different platforms
  sources = {
    x86_64-linux = {
      url = "https://github.com/Roblox/rocale-cli/releases/download/v${version}/rocale-cli-linux-x86_64.zip";
      hash = "sha256-rTflPiYSsjhFRosZj94eNgqinBlxIEuPYs13+Pdil+E=";
    };
    x86_64-darwin = {
      url = "https://github.com/Roblox/rocale-cli/releases/download/v${version}/rocale-cli-macos-x86_64.zip";
      hash = "sha256-3rI5yBTOeqpYU5055Qf6pbWuP2iac8ddF7B49KfCBR4=";
    };
    aarch64-darwin = {
      # Use x86_64-darwin binary via Rosetta 2 on Apple Silicon
      url = "https://github.com/Roblox/rocale-cli/releases/download/v${version}/rocale-cli-macos-x86_64.zip";
      hash = "sha256-3rI5yBTOeqpYU5055Qf6pbWuP2iac8ddF7B49KfCBR4=";
    };
  };

  srcArgs = sources.${stdenv.hostPlatform.system} or (throw "Unsupported system for rocale-cli: ${stdenv.hostPlatform.system}");

  rocale-zip = fetchurl srcArgs;

  rocale-bin = stdenv.mkDerivation {
    pname = "rocale-cli-bin";
    inherit version;
    src = rocale-zip;
    nativeBuildInputs = [unzip];
    sourceRoot = ".";
    unpackPhase = "unzip $src";
    installPhase = ''
      mkdir -p $out/bin
      chmod +x rocale-cli
      cp rocale-cli $out/bin/
    '';
    dontStrip = true;
    dontPatchELF = true;
    dontFixup = true;
  };
in
  if stdenv.isLinux
  then
    buildFHSEnv {
      name = "rocale-cli";
      targetPkgs = pkgs:
        with pkgs; [
          glibc
          stdenv.cc.cc.lib
          zlib
        ];
      runScript = "${rocale-bin}/bin/rocale-cli";
    }
  else
    # For macOS, wrap the binary in a shell script.
    # This ensures the binary is always executed with an absolute path as argv[0],
    # otherwise it falls back to the default `lute` runtime behavior.
    writeShellScriptBin "rocale-cli" ''
      exec "${rocale-bin}/bin/rocale-cli" "$@"
    ''
