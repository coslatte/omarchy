#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "$0")" && pwd)
config="${XDG_CONFIG_HOME:-$HOME/.config}"
bin="$HOME/.local/bin"
hook="$config/omarchy/hooks/theme-set.d/zed-themes"
if [[ -e "$config/zed/themes/Omarchy.json" && ! -e "$bin/omarchy-zed-themes" ]]; then
  printf 'Existing theme: %s\n' "$config/zed/themes/Omarchy.json" >&2; exit 1
fi
if [[ ${1:-} == --glass-watch ]]; then
  for unit in omarchy-zed-glass.path omarchy-zed-glass.service; do
    target="$config/systemd/user/$unit"
    if [[ -e "$target" ]] && ! cmp -s "$root/systemd/$unit" "$target"; then
      printf 'Conflicting file: %s\n' "$target" >&2; exit 1
    fi
  done
fi
install_file() {
  local source="$1" target="$2" mode="$3"
  if [[ -e "$target" ]] && ! cmp -s "$source" "$target"; then
    printf 'Conflicting file: %s\n' "$target" >&2; exit 1
  fi
  mkdir -p "$(dirname "$target")"
  install -m "$mode" "$source" "$target"
}
for target in "$bin/omarchy-zed-themes" "$bin/omarchy-zed-neovim-export.lua" "$hook"; do
  source="$root/bin/${target##*/}"
  [[ "$target" == "$hook" ]] && source="$root/hooks/zed-themes"
  if [[ -e "$target" ]] && ! cmp -s "$source" "$target"; then
    printf 'Conflicting file: %s\n' "$target" >&2; exit 1
  fi
done
install_file "$root/bin/omarchy-zed-themes" "$bin/omarchy-zed-themes" 755
install_file "$root/bin/omarchy-zed-neovim-export.lua" "$bin/omarchy-zed-neovim-export.lua" 644
install_file "$root/hooks/zed-themes" "$hook" 755
"$bin/omarchy-zed-themes"
printf 'Select Omarchy in Zed using the theme selector.\n'
if [[ ${1:-} == --glass-watch ]]; then
  for unit in omarchy-zed-glass.path omarchy-zed-glass.service; do
    install_file "$root/systemd/$unit" "$config/systemd/user/$unit" 644
  done
  systemctl --user daemon-reload
  systemctl --user enable --now omarchy-zed-glass.path
fi
