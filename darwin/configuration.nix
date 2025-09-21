{
  self,
  pkgs,
  ...
}: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  programs.fish.enable = true;
  users.knownUsers = ["robert"];
  users.users.robert.shell = pkgs.fish;
  users.users.robert.home = "/Users/robert";
  users.users.robert.uid = 501;
  system.primaryUser = "robert";

  homebrew = {
    enable = true;
    casks = [
      "alt-tab"
      "basictex"
      "bitwarden"
      "coconutbattery"
      "font-jetbrains-mono-nerd-font"
      "font-meslo-lg-nerd-font"
      "font-monaspace"
      "font-roboto-mono-nerd-font"
      "font-sf-mono"
      "font-sf-pro"
      "font-symbols-only-nerd-font"
      "ghostty"
      "middleclick"
      "miniconda"
      "qbittorrent"
      "raycast"
      "sf-symbols"
      "sioyek"
      "zoom"
    ];
    brews = [
      "wally"
    ];
  };

  services.yabai = {
    enable = true;
  };
  services.skhd = {
    enable = true;
  };
}
