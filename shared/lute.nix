{pkgs, ...}: let
  inherit (pkgs) stdenv fetchurl unzip buildFHSEnv writeShellScriptBin;

  version = "1.0.0";

  sources = {
    x86_64-linux = {
      url = "https://github.com/luau-lang/lute/releases/download/v${version}/lute-linux-x86_64.zip";
      hash = "sha256-3nptqwayHfVyxJJX7CSkzx7NVPuFTehWqjd6EYglXJU=";
    };
    aarch64-darwin = {
      url = "https://github.com/luau-lang/lute/releases/download/v${version}/lute-macos-aarch64.zip";
      hash = "sha256-bRILXSgE5iqyRTVl51XQIr1pAjB8q80P7bTNy9QlHoQ=";
    };
  };

  system = stdenv.hostPlatform.system;
  srcArgs = sources.${system} or (throw "Unsupported system for lute: ${system}");

  lute-bin = stdenv.mkDerivation {
    pname = "lute-bin";
    inherit version;

    src = fetchurl srcArgs;
    nativeBuildInputs = [unzip];
    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/bin
      chmod +x lute
      cp lute $out/bin/
    '';

    dontStrip = true;
    dontPatchELF = true;
    dontFixup = true;
  };
in
  if stdenv.isLinux
  then
    buildFHSEnv {
      name = "lute";
      targetPkgs = pkgs:
        with pkgs; [
          glibc
          stdenv.cc.cc.lib
          zlib
        ];
      runScript = "${lute-bin}/bin/lute";
    }
  else if stdenv.isDarwin
  then
    # Keep absolute argv[0] on macOS to avoid runtime self-path issues.
    writeShellScriptBin "lute" ''
      exec "${lute-bin}/bin/lute" "$@"
    ''
  else lute-bin
