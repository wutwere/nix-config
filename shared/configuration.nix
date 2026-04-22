{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    (pkgs.callPackage ./rocale-cli.nix {})
    (pkgs.callPackage ./blink.nix {})
  ];
}
