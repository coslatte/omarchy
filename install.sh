#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
plugin_dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins"
shell_config="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/shell.json"
mkdir -p "$plugin_dir"

for source in "$repo_dir"/plugins/*; do
  [[ -d "$source" ]] || continue
  id="$(basename "$source")"
  target="$plugin_dir/$id"
  if [[ -e "$target" ]]; then
    backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    cp -a -- "$target" "$backup"
    printf 'Respaldo: %s\n' "$backup"
  fi
  rm -rf -- "$target"
  cp -a -- "$source" "$target"
  printf 'Instalado: %s\n' "$id"
done

if command -v omarchy-shell >/dev/null 2>&1; then
  omarchy-shell shell rescanPlugins
fi
printf '\nLos plugins están copiados. Activa y ordena cada widget desde ~/.config/omarchy/shell.json.\n'
