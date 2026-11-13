---
name: local-agent-coordination
description: Coordinate parallel Codex agents and sessions on a local machine using Agent Mesh and MCP Agent Mail. Use whenever dispatching parallel coding tasks, sharing file ownership, coordinating Git changes, communicating between agents, or integrating concurrent local work without GitHub Actions.
---

# Local Codex multi-agent coordination

## Non-negotiable rules

- Keep all integration local until the user explicitly requests a remote push. Never treat GitHub Actions or remote PRs as the local coordination mechanism.
- Identify whether agents share a working tree or occupy distinct worktrees. Native Codex subagents **do not automatically** get isolated worktrees; verify isolation, do not assume it.
- Treat Agent Mesh as the coordination/visibility plane (presence, notes, work scopes, job status), MCP Agent Mail as the communications/file-reservation plane, and Git as the authoritative commits/diffs plane.
- Reservations are advisory. Enforce them through instructions plus installed hooks/guards when available. Never claim they technically prevent all edits.
- Avoid two competing authoritative locks: **Agent Mail owns file reservations**. Mesh claims may be published for visibility, but neither grant nor override Agent Mail permission. If the two disagree, stop until reconciled.
- Use a single project identity (canonical absolute repository root, not each worktree's own path) for all Agent Mail agents. Use corresponding shared Mesh project/repo context; verify how the installed Mesh version identifies repos.
- Before first parallel action, check `command -v mesh`, `mesh who`, Agent Mail connectivity via MCP or `am robot status`, and `git worktree list`. If unavailable, report degraded coordination and run independent read-only exploration only; do not perform conflicting concurrent edits.

## Initialization / agent registration

1. The parent identifies the canonical Git repository, branch, HEAD, current working-tree state and active worktrees. Preserve pre-existing user changes.
2. Check whether `mesh up` is already serving; start only when needed and allowed. Inspect `mesh --help` / installed docs for version-specific commands. `mesh who` should show presence when the agent/session joins (e.g. `mesh join --name <unique-id> --role builder`).
3. Connect MCP Agent Mail through the globally configured server. Confirm availability of `ensure_project`, `register_agent`, `file_reservation_paths`, `send_message`, `fetch_inbox`, and release operations; inspect actual tool schemas rather than guessing. Register each independently addressable Codex process/agent with its own name; if native subagents cannot independently register, the parent must broker reservations and messages on their behalf.
4. Publish a concise task plan and file/contract ownership to the Mesh blackboard/notes using the installed CLI. Do not invent command flags; consult `mesh --help`.
5. Spawn agents only after scope assignment and registration or documented parent-broker fallback.

## Work protocol

1. Before editing, the worker requests exclusive Agent Mail reservations for the *smallest practical* file globs, includes task identifier and TTL, and checks returned conflicts. Never bypass a refused reservation.
2. If blocked, query Agent Mail inbox, contact the owner, and move to independent work. Do not busy-wait or edit the reserved files.
3. Announce ownership, API/contract changes, and dependencies via Agent Mail thread; log a concise durable decision in Mesh. When a contract change affects other agents, request acknowledgement before implementing an incompatible interface.
4. Renew expiring reservations and periodically check inbox while actively working. Treat stale reservations as unresolved until investigated; don't blindly steal ownership.
5. Each writer uses its own Git worktree and branch when possible. If workers share a directory, do **not** run concurrent Git index/HEAD operations and do not commit as subagents; parent alone stages and commits after all writers stop.
6. At completion, send files changed, `git status`, commit hash if applicable, tests, outstanding contracts, and known conflicts. Release reservations after the worker has stopped writing and safely handed off modifications. Update Mesh status/notes.

## Local integration protocol (single owner)

- Parent/integrator is the only process allowed to integrate into the shared target branch. Use a serialized queue; no direct worker pushes to that branch.
- Ensure every contributor has reported FINISHED or is safely isolated from the target working tree. Verify no conflicting live reservations.
- Inspect `git worktree list`, `git status --porcelain`, `git log --all --graph --oneline`, and per-branch diffs; map expected contributions to real commits and files. Do not mistake uncommitted work in another worktree for a commit.
- Integrate agent commits one at a time onto a clean local integration worktree/branch. Determine merge/rebase/cherry-pick strategy from task semantics. Preserve branch commits and never discard existing user modifications.
- After each integration, run relevant focused tests; run full checks before final handoff. Stop on conflicts and ask owner agents for help using Agent Mail. Document resolution in Mesh.
- Report integrated commit hashes, remaining branches, tests and conflicts. `git push` only if user expressly requested publishing; fetch and revalidate immediately beforehand. No automatic force-push.

## Failure behavior

- Mesh offline: maintain read-only Git inspection; pause *new overlapping edits* and warn that presence/state sharing is unavailable.
- Agent Mail offline: no coordinated concurrent writing; serialize or isolate work until restored.
- Agent cannot access MCP: parent brokers reservation, message and acknowledgement explicitly; never pretend the subagent itself is connected.
- Stale job/agent: reconcile heartbeat, process and worktree before clearing reservations.
- Files reserved but a worker edits anyway: stop that worker and resolve ownership; advisory locks are not an absolute safeguard.

## Setup, troubleshooting and exact tool names

Read [references/setup.md](references/setup.md) for local installation and global Codex setup. Use live project docs for version-specific commands and MCP schema.
