#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${HOME}/.local/bin"

mkdir -p "$BIN_DIR"

for script in "$SCRIPT_DIR"/bin/*; do
  name="$(basename "$script")"
  ln -sf "$script" "$BIN_DIR/$name"
  echo "Linked $name → $BIN_DIR/$name"
done

echo ""
echo "Done! Make sure $BIN_DIR is in your PATH."
