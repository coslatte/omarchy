#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="${HOME}/.agents/skills/local-agent-coordination"
GLOBAL="${HOME}/.codex/AGENTS.md"
FRAGMENT="$ROOT/global/AGENTS.fragment.md"
MARKER='## Local multi-agent Git coordination (global)'
mkdir -p "${HOME}/.agents/skills" "${HOME}/.codex"
if [[ -e "$SKILL_DIR" ]]; then
  echo "Skill already exists: $SKILL_DIR" >&2
  echo "Back it up or remove it intentionally before installing." >&2
  exit 1
fi
cp -R "$ROOT/skills/local-agent-coordination" "$SKILL_DIR"
if [[ -f "$GLOBAL" ]] && grep -Fq "$MARKER" "$GLOBAL"; then
  echo 'Global instructions already present; keeping existing AGENTS.md'
else
  if [[ -f "$GLOBAL" ]]; then cp -p "$GLOBAL" "$GLOBAL.backup.$(date +%Y%m%d%H%M%S)"; fi
  { [[ ! -s "$GLOBAL" ]] || printf '\n'; cat "$FRAGMENT"; } >> "$GLOBAL"
fi
printf 'Installed Skill and appended global rules. No services or MCP configurations were changed.\n'
printf 'Review docs/INSTALL.md to install and configure Mesh and Agent Mail.\n'
