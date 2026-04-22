{pkgs, ...}: {
  environment.systemPackages = [
    (pkgs.callPackage ./rocale-cli.nix {})
    (pkgs.callPackage ./blink.nix {})
  ];
}
