my poorly written nix config while trying to set up nixos

```sh
sudo nixos-rebuild switch --flake .
```

# todo
- [ ] split up home.nix
- [ ] put `wally-packages-type` in nixpkgs instead of building it in my config
    - [ ] delete `Cargo.lock` after
- [ ] set up flakes in projects for `nix develop`

