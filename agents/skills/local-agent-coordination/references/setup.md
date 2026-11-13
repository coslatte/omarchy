# Setup: Arch Linux / Codex CLI

Authoritative upstream docs:
- https://github.com/georgenijo/agent-mesh
- https://github.com/Dicklesworthstone/mcp_agent_mail_rust
- https://learn.chatgpt.com/docs/config-file/config-reference

## Global Codex paths

- `~/.codex/AGENTS.md`: global always-on concise policy, including instructions to load this skill.
- `~/.agents/skills/local-agent-coordination/SKILL.md`: user-global skill folder.
- `~/.codex/config.toml`: global MCP server settings; preserve other existing keys.
- Optional `~/.codex/agents/*.toml`: custom worker role definitions; not necessary for baseline.

## Mesh setup (from project README)

```bash
git clone https://github.com/georgenijo/agent-mesh.git ~/tools/agent-mesh
cd ~/tools/agent-mesh
make build
# Move or link mesh and meshd into a PATH directory, after verifying generated files.
mesh up
mesh who
```

Dashboard documented at `http://127.0.0.1:8737/ui/`. `mesh join --name <unique-name> --role builder` registers an agent session. Mesh CLI is NOT automatically an MCP server; use CLI, hooks, sidecars, or project-supported integration as verified.

## Agent Mail setup

Review release source, signed installer and permissions before executing third-party installers. The Rust project documents a verified release installer and `am setup run` to configure detected coding agents. Start using `am` (localhost HTTP on port 8765 by default) and test `am setup status`.

Global Codex configuration example (only if installer did not add it):

```toml
[mcp_servers.mcp_agent_mail]
url = "http://127.0.0.1:8765/mcp/"
# If authentication is enabled, use the provider's documented secure token setup.
```

Do not expose the MCP server to the public network. Keep tokens out of Git, screenshots, chat logs and copied instructions. Agent Mail tool examples from README: `ensure_project`, `register_agent`, `file_reservation_paths`, `send_message`, `fetch_inbox`. See current server tool discovery for release/retrieve functions and parameter schemas.

## Smoke test

1. Start Mesh and Agent Mail locally.
2. Confirm Codex sees Agent Mail MCP tools.
3. Start two independently addressable agents; have A reserve a disposable test file, check B sees conflict.
4. Have A send a message and B fetch/acknowledge it; release reservation.
5. Create two disposable isolated Git worktrees and test local integration on a throwaway branch.
6. Confirm no remote push occurred.

Native in-process Codex subagents may not be visible as separate operating-system sessions to Mesh. Configure explicit registration for each if possible; otherwise parent-broker Mesh/Agent Mail actions. Do not state full per-subagent visibility without confirming it in test.
