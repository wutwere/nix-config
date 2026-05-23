{
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "openchamber" ''
  exec ${pkgs.nodejs_24}/bin/npx --yes @openchamber/web@1.11.4 "$@"
''
