#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "$0")" && pwd)
config="${XDG_CONFIG_HOME:-$HOME/.config}"
remove_owned() {
  local source="$1" target="$2"
  if [[ -f "$target" ]] && cmp -s "$source" "$target"; then
    rm -- "$target"
  elif [[ -e "$target" ]]; then
    printf 'Kept modified file: %s\n' "$target"
  fi
}
if [[ -f "$config/systemd/user/omarchy-zed-glass.path" ]] && cmp -s "$root/systemd/omarchy-zed-glass.path" "$config/systemd/user/omarchy-zed-glass.path"; then
  systemctl --user disable --now omarchy-zed-glass.path 2>/dev/null || true
fi
for unit in omarchy-zed-glass.path omarchy-zed-glass.service; do
  remove_owned "$root/systemd/$unit" "$config/systemd/user/$unit"
done
systemctl --user daemon-reload 2>/dev/null || true
remove_owned "$root/hooks/zed-themes" "$config/omarchy/hooks/theme-set.d/zed-themes"
for name in omarchy-zed-themes omarchy-zed-neovim-export.lua; do
  remove_owned "$root/bin/$name" "$HOME/.local/bin/$name"
done
printf 'The generated theme and Zed selection were kept. Remove them manually if desired.\n'
