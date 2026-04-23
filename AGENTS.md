# AGENTS.md

## Scope and entrypoints
- This repo is a single Nix flake for two hosts defined in `flake.nix`: `nixosConfigurations.nixos` (WSL/NixOS) and `darwinConfigurations.macbook` (nix-darwin).
- Primary files to edit are host-specific (`wsl/`, `darwin/`) plus shared modules in `shared/`.
- `wsl/configuration.nix` and `darwin/configuration.nix` both import `../shared/configuration.nix`.
- `wsl/home.nix` and `darwin/home.nix` both import `../shared/home.nix` (Home Manager is wired from `flake.nix`).

## Apply changes (authoritative commands)
- WSL/NixOS apply: `sudo nixos-rebuild switch --flake .#nixos`
- macOS apply: `sudo darwin-rebuild switch --flake .#macbook`
- Format Nix files via flake formatter: `nix fmt`

## Verification shortcuts
- Fast structural check after edits: `nix flake check`
- Validate host evaluation without switching:
  - `nix build .#nixosConfigurations.nixos.config.system.build.toplevel`
  - `nix build .#darwinConfigurations.macbook.system`

## Repo-specific gotchas
- `shared/home.nix` symlinks Neovim config from `${config.home.homeDirectory}/dotfiles/nvim/.config/nvim`; rebuilds fail or link breaks if that path is missing.
- `shared/configuration.nix` installs custom derivations from `shared/rocale-cli.nix` and `shared/blink.nix`; if bumping versions, update URL and hash together.
- `shared/rocale-cli.nix` intentionally uses the macOS `x86_64` binary for `aarch64-darwin` (Rosetta path); do not "fix" to arm64 unless upstream artifact support is confirmed.
- Homebrew on Darwin is managed through nix-homebrew in `flake.nix` with pinned taps and `mutableTaps = false`; change taps there, not with `brew tap` imperatively.

## What is not present
- No CI workflows, pre-commit config, or alternate agent instruction files are currently in-repo.
