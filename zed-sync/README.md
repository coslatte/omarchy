# Omarchy Zed Sync

Generates one local Zed theme named **Omarchy** from the active Omarchy profile. An Omarchy theme-set hook regenerates it when the profile changes.

The generator prefers a Zed theme provided by the active profile. Otherwise, it exports highlight groups from the active Neovim configuration and maps them to Zed captures. If export is unavailable, it uses the Omarchy color palette. Zed and Neovim use different syntax queries, so their rendering may differ.

## Requirements

- Linux with Omarchy and Zed, and Python 3.11 or newer.
- `omarchy-theme-color`, `flock`, and the active Omarchy theme under `~/.local/state/omarchy/current/`.
- Neovim is optional. Export uses the user's installed configuration and plugins; failures fall back to the Omarchy palette.

## Install

Run `./install.sh`, then open Zed's theme selector and select **Omarchy**. The installer refuses to replace different files with the same names. To update an existing installation, inspect and move conflicting files first.

For installations using the custom `omarchy-power-glass-state` integration, run `./install.sh --glass-watch` instead. This installs a user systemd path unit that regenerates the theme when that state changes. The state format is `mode|animations|blur_size|blur_passes|opacity`; without it, the generated theme keeps its original background appearance. This state file is not a standard Omarchy requirement. Hyprland must have blur enabled to blur translucent areas.

The hook updates the theme file; the user selects the theme in Zed. For separate light and dark selections, choose Omarchy in both slots if desired. Zed's handling of live theme changes and transparency can vary by version and compositor.

## Uninstall

Run `./uninstall.sh`. It removes installed files only when they match this checkout and disables the optional watcher. It retains `~/.config/zed/themes/Omarchy.json` and Zed's theme selection; remove or change those manually if desired.

## Current limitations

The generated theme reads the active Omarchy state from the standard home paths. The Neovim export runs the local Neovim configuration in headless mode and requires its selected colorscheme to load successfully. Profiles with their own Zed JSON take priority.
