#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
plugin_dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins"
shell_config="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/shell.json"
mkdir -p "$plugin_dir"

for source in "$repo_dir"/*; do
  [[ -d "$source" && -f "$source/manifest.json" ]] || continue
  id="$(basename "$source")"
  target="$plugin_dir/$id"
  if [[ -e "$target" ]]; then
    backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    cp -a -- "$target" "$backup"
    printf 'Backup: %s\n' "$backup"
  fi
  rm -rf -- "$target"
  cp -a -- "$source" "$target"
  printf 'Installed: %s\n' "$id"
done

if command -v omarchy-shell >/dev/null 2>&1; then
  omarchy-shell shell rescanPlugins
fi
printf '\nPlugins copied. Enable and arrange each widget in ~/.config/omarchy/shell.json.\n'
