# Secrets quickstart

Simple flow for secrets with `sops` + `age`.

## 1) Create or reuse age key

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
```

Put the public key into `.sops.yaml` (`age1...`).

## 2) Encrypt/edit secrets

```bash
sops -e -i secrets/common.yaml
```

Edit later:

```bash
sops secrets/common.yaml
# also update home.nix
```

## 3) Apply config

- macOS: `sudo darwin-rebuild switch --flake .#macbook`
- WSL/NixOS: `sudo nixos-rebuild switch --flake .#nixos`

## 4) Use a secret in CLI

```bash
OPENAI_API_KEY="$(< "$XDG_RUNTIME_DIR/openai_api_key")" my-cli
```

macOS runtime dir helper (if needed):

```bash
OPENAI_API_KEY="$(< "$(getconf DARWIN_USER_TEMP_DIR)/openai_api_key")" my-cli
```

combine both:

```bash
ROBLOX_INTEGTEST_API_KEY="$(< "${XDG_RUNTIME_DIR:-$(getconf DARWIN_USER_TEMP_DIR 2>/dev/null)/ROBLOX_INTEGTEST_API_KEY}")"
```

## 5) New machine restore

Copy your age key file to the new machine:

```bash
~/.config/sops/age/keys.txt
```

Then rebuild. Secrets will decrypt automatically.

## 6) Rotate/backup keys

- Keep a backup copy of `~/.config/sops/age/keys.txt` in a password manager.
- If you add another recipient, run:

```bash
sops updatekeys secrets/common.yaml
```
