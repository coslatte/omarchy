# init

this is my current configuration for my agents and overall workflow. with many of the tools that i use and will use in the future, willing to update these maybe depending of what tools ill be using. will leave it public unless something is really private.

# Summary

> The following content is SLOP generated

A portable setup for coordinating concurrent Codex CLI work with Agent Mesh, MCP Agent Mail, and Git worktrees.

Each part has a specific role:

- `global/AGENTS.fragment.md` contains Codex's permanent global instructions.
- `skills/local-agent-coordination/` documents the complete coordination protocol.
- `scripts/` lets you restore and check the configuration.
- `docs/INSTALL.md` explains how to install and connect Agent Mesh and MCP Agent Mail.
- `docs/engineering-playbook.md` summarizes reusable engineering rules, skill areas, and tool integrations.

## Use the Kit on a New PC

Extract the kit, then run:

```bash
cd codex-agent-coordination-kit
bash scripts/install.sh
```

The installer adds the instructions and skill to their global locations:

```text
~/.codex/AGENTS.md
~/.agents/skills/local-agent-coordination/
```

It preserves existing instructions and does not overwrite an existing skill. Check the setup with:

```bash
bash scripts/doctor.sh
```

The installer configures instructions, but does not install Agent Mesh or MCP Agent Mail. Their installation and connection steps are documented in [docs/INSTALL.md](docs/INSTALL.md). Verify MCP access from Codex as an additional step.

## Share the Kit on GitHub

Create an empty GitHub repository named `codex-agent-coordination`. You can keep it private while testing the system.

From the extracted kit directory, initialize and push the repository:

```bash
cd codex-agent-coordination-kit

git init
git add .
git commit -m "feat: add portable Codex coordination setup"
git branch -M main

git remote add origin git@github.com:YOUR_USERNAME/codex-agent-coordination.git
git push -u origin main
```

For a future installation, clone the repository and run the installer:

```bash
git clone git@github.com:YOUR_USERNAME/codex-agent-coordination.git
cd codex-agent-coordination
bash scripts/install.sh
```

Then follow the dependency and MCP setup guide in [docs/INSTALL.md](docs/INSTALL.md).

## How the System Can Evolve

The kit can grow beyond a copy of `AGENTS.md` into a reproducible setup for agent-assisted development:

| Component | What to keep |
| --- | --- |
| Codex | Global instructions and non-sensitive configuration |
| Skills | Reusable specialized procedures |
| Agent Mesh | Coordination configuration and protocol |
| MCP Agent Mail | Installation, connection, and reservation instructions |
| Git | Worktree, commit, and integration policies |
| Bootstrap | Automated setup for new machines |

Never publish MCP tokens, GitHub credentials, Codex authentication files, or local agent databases.

With this approach, the repository is the source of truth for your rules, while each computer keeps its own credentials and services.

Once the environment is stable, pin specific versions of Mesh and Agent Mail. Otherwise, a future installation may behave differently as those projects change.

The end goal is that after reinstalling Arch Linux, you can clone one repository, run a bootstrap, configure your credentials, and restore your multi-agent work environment without rebuilding its instructions by hand.
