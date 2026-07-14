#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/pets"
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"
TARGET_DIR="$CODEX_ROOT/pets"

if [[ ! -d "$SOURCE_DIR" ]]; then
  printf 'Error: pet source directory not found: %s\n' "$SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

installed=0
for pet_dir in "$SOURCE_DIR"/*; do
  [[ -d "$pet_dir" ]] || continue
  pet_id="$(basename "$pet_dir")"

  if [[ ! -f "$pet_dir/pet.json" || ! -f "$pet_dir/spritesheet.webp" ]]; then
    printf 'Error: incomplete pet package: %s\n' "$pet_dir" >&2
    exit 1
  fi

  mkdir -p "$TARGET_DIR/$pet_id"
  cp "$pet_dir/pet.json" "$TARGET_DIR/$pet_id/pet.json"
  cp "$pet_dir/spritesheet.webp" "$TARGET_DIR/$pet_id/spritesheet.webp"
  printf 'Installed %s\n' "$pet_id"
  installed=$((installed + 1))
done

if [[ "$installed" -eq 0 ]]; then
  printf 'Error: no pet packages were found in %s\n' "$SOURCE_DIR" >&2
  exit 1
fi

printf 'Installed %d Codex pets into %s\n' "$installed" "$TARGET_DIR"
printf 'Restart Codex to reload the custom-pet list.\n'

