{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) stdenv fetchurl xz buildFHSEnv writeShellScriptBin;

  version = "0.18.8";

  sources = {
    x86_64-linux = {
      url = "https://github.com/1Axen/blink/releases/download/v${version}/blink-linux-x86_64.tar.xz";
      hash = "sha256-YzJzECQ5NmLcpQOdb7hVhzF2gzWFhXjyoMxhe9pE2Kg=";
    };
    aarch64-darwin = {
      url = "https://github.com/1Axen/blink/releases/download/v${version}/blink-macos-aarch64.tar.xz";
      hash = "sha256-WEVFVPQRNNMVD0kQjhW62csOW1HMqD9NxNS5lGDcfG4=";
    };
  };

  system = stdenv.hostPlatform.system;
  srcArgs = sources.${system} or (throw "Unsupported system: ${system}");

  # 1. Extract the binary and keep it "Sacred" (No patching/stripping)
  blink-raw = stdenv.mkDerivation {
    pname = "blink-raw";
    inherit version;
    src = fetchurl srcArgs;
    nativeBuildInputs = [xz];

    dontStrip = true;
    dontPatchELF = true;
    dontFixup = true;

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/bin
      cp blink $out/bin/blink-internal
      chmod +x $out/bin/blink-internal
    '';
  };
in
  if stdenv.isLinux
  then
    # 2. Linux: Create the FHS environment
    buildFHSEnv {
      name = "blink";
      targetPkgs = pkgs:
        with pkgs; [
          glibc
          stdenv.cc.cc.lib
          zlib
        ];
      # Point directly to the binary file.
      # buildFHSEnv will wrap this automatically.
      runScript = "${blink-raw}/bin/blink-internal";
    }
  else
    # 3. macOS: Wrapper script to ensure absolute path argv[0]
    writeShellScriptBin "blink" ''
      exec "${blink-raw}/bin/blink-internal" "$@"
    ''
