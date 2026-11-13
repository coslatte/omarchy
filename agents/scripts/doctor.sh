#!/usr/bin/env bash
set -uo pipefail
printf 'Codex: '; command -v codex || true
printf 'Mesh: '; command -v mesh || true
printf 'Agent Mail CLI: '; command -v am || true
for path in "$HOME/.codex/AGENTS.md" "$HOME/.codex/config.toml" "$HOME/.agents/skills/local-agent-coordination/SKILL.md"; do
  if [[ -f "$path" ]]; then printf 'OK %s\n' "$path"; else printf 'MISSING %s\n' "$path"; fi
done
if command -v mesh >/dev/null 2>&1; then mesh who || true; fi
if command -v am >/dev/null 2>&1; then am setup status || true; fi
printf 'Check actual MCP tool access from a new Codex session; CLI presence alone is insufficient.\n'
