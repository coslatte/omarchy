## Local multi-agent Git coordination (global)

Whenever delegating parallel coding tasks or working alongside other Codex sessions, load `~/.agents/skills/local-agent-coordination/SKILL.md` and follow its protocol.

Use Agent Mesh for presence and shared task decisions, MCP Agent Mail for communications and authoritative advisory file reservations, and Git worktrees for isolated writes. Never assume native Codex subagents have separate worktrees or independent MCP identities; verify, or let their parent broker coordination.

Before concurrent writes: inspect Git state and active worktrees; verify both services, register agent identities, assign distinct scopes, and reserve files. On unavailable services, avoid overlapping concurrent writes and use serialized execution. An Agent Mail reservation is advisory, not a filesystem lock.

Only one integrator changes the shared integration branch. Workers report changed files, tests, branch and commit IDs. Integrate locally one at a time, test, and retain user changes. Do not push, force-push, reset or discard others' work without explicit authorization. Never require GitHub Actions for local completion.
