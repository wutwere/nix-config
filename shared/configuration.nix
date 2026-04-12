{pkgs, ...}: {
  environment.systemPackages = [
    (pkgs.callPackage ./rocale-cli.nix {})
  ];
}
