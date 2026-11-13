# Reusable Engineering Rules, Skills, and Tools

This document captures reusable agent-workflow practices from an existing software project. It intentionally omits that project's business rules, domain model, source paths, credentials, and environment-specific configuration.

## General Engineering Rules

### Understand before editing

- Read the applicable repository instructions and skills before changing code.
- Find the relevant implementation, callers, tests, and external contracts before editing.
- Use the repository's code index or structural tools when available; use text search and direct file reads when they fit the question or when indexed coverage is incomplete.
- Check version history when behavior or design intent is unclear.
- For changes spanning multiple files, modules, or public contracts, write a short implementation plan first. Identify applicable guidance and record why other guidance does not apply.

### Keep boundaries clear

- Keep transport and framework concerns at system boundaries.
- Put orchestration and domain decisions in the appropriate application layer; keep persistence and mapping components focused on their roles.
- Avoid hidden dependencies, duplicated policy, and parallel sources of truth.
- Prefer a single well-understood tool for each capability. Add a tool or MCP only when it provides a distinct capability that existing tools do not cover.

### Make changes carefully

- Preserve existing behavior unless the requested change requires changing it.
- Avoid opportunistic refactors and unrelated cleanup.
- Prefer explicit types and imports when they make code easier to read. Follow the language and repository conventions.
- Write comments only when they explain a non-obvious reason, constraint, or invariant. Do not narrate code, add decorative separators, or leave commented-out code.
- Treat schema and data migrations as high-impact changes: inspect current state, surface conflicts, and make the change reviewable.

### Verify and report honestly

- Choose verification proportional to the change: focused checks while iterating, then the repository's required checks before completion.
- For externally observable behavior, verify the actual running path and contract when the environment permits; compilation alone does not prove runtime behavior.
- Report the commands run and their real outcomes. State unavailable checks and blockers clearly.

### Protect shared work

- Preserve pre-existing changes. Inspect repository status before editing.
- For concurrent work, assign non-overlapping ownership, isolate work with worktrees when practical, and coordinate reservations and integration using the local coordination protocol in this kit.
- Keep credentials, tokens, local databases, private exports, and machine-specific paths out of version control.

## Reusable Skill Catalog

These skill areas were used in the source project. The descriptions below are generalized summaries, not copies of project-specific procedures.

| Skill area | Purpose |
| --- | --- |
| Code review | Review contracts, boundaries, security, persistence, and test coverage against the target repository's own rules. |
| Codebase investigation | Gather source, call-flow, history, and test evidence before implementation. |
| Comment discipline | Keep comments sparse and focused on non-obvious reasons and constraints. |
| Commit format review | Check that commit subjects are clear, consistent, and follow the repository's chosen convention. |
| Context awareness | Obtain current request or user context through supported abstractions instead of coupling code to framework internals. |
| Debugging | Reproduce a failure, trace it to its cause, and verify the fix at the source. |
| Safe production changes | Preserve compatibility and data integrity when modifying deployed code. |
| Endpoint security review | Check authentication, authorization, and exposure when adding or changing public endpoints. |
| Migration review | Check migration ordering, conflicts, data impact, and reversibility before changing persistent schemas. |
| Language best practices | Use current language features while keeping code clear and consistent with local conventions. |
| Plan creation | Turn multi-file or contract-level work into a small, evidence-based implementation plan. |
| Refactoring restraint | Make only refactors that address demonstrated problems and keep diffs focused. |
| Dead-code review | Verify apparent unused code against framework discovery and runtime entry points before removal. |
| Layered architecture | Preserve dependency direction and keep responsibilities in their intended layers. |
| Mapper guardrails | Keep object mapping deterministic and free of persistence access, hidden I/O, and domain orchestration. |
| Structural search and refactoring | Use syntax-aware search and transformations for code-shape changes; review every resulting diff. |
| Testing from scratch | Build tests progressively from isolated logic to integration boundaries. |
| Strict maintainability review | Look for needless abstraction, oversized files, duplicated logic, and tangled control flow. |
| Typed code and import style | Keep types and dependencies visible; avoid unnecessary qualification, wildcard imports, and decorative code comments. |
| Validation | Define the evidence required to call a change complete and report any remaining gaps. |
| Compact file references | Keep assistant file citations readable while linking to the full local path. |

Load only the skills relevant to a task. Skills that encode a specific framework, language, schema, API, or domain must be adapted to the target project before use.

## Tools and Plugin Integrations

The source setup used these categories of tools. Install and configure them per machine; keep secrets and user-specific paths outside this repository.

| Tool or integration | Capability |
| --- | --- |
| Codebase memory MCP | Repository architecture, symbol lookup, call paths, and impact exploration. |
| AST search tool | Syntax-aware code search and structural refactoring. |
| Insomnia MCP integration | Optional read and request execution against a user's API workspaces. Treat collections and environments as private; review before writing. |
| Linear MCP integration | Read or manage issue-tracking context when configured and authorized. |
| Git | Change history, blame, diffs, branches, and worktree isolation. |
| Language build and test tools | Compile, test, and package the target repository using its own wrappers and scripts. |

Avoid loading overlapping indexes or MCPs for the same capability unless a measured need justifies the extra context and maintenance. Confirm the installed tool's current commands and permissions before relying on it.

## Additional Practices from a Personal Project

The following rules and skill areas were also present in a separate personal repository. They are generalized here; application-specific examples, component names, API contracts, and design tokens are intentionally excluded.

### Repository and language conventions

- Keep code, comments, documentation, branch names, and Git artifacts in the repository's chosen language. User-facing conversation can follow the user's language.
- Use Conventional Commits with a short imperative subject. Keep subjects within the repository's line-length limit and verify the staged diff matches the message.
- Prefer editing the existing source of truth over creating parallel files, and keep commits focused on one logical change.
- Before frontend edits, read the architecture decision record. Update it alongside changes that move files, change layer boundaries, or alter documented conventions.
- Run the relevant type checks and tests before completion; a transpiling build may not perform type checking.

### Translation and localized content

When changing visible text, accessible labels, metadata, or localized content:

1. Check the repository's current supported locale list and translation architecture.
2. Update the source message and all corresponding locales in the same change.
3. Preserve meaning, tone, named parameters, proper names, URLs, and user-authored content.
4. Remove unused translation keys when removing source copy.
5. Verify locale switching and run the repository's translation checks when available.

Do not copy a locale list, catalog structure, or component API from another project; those belong to the target repository.

### Java source style

- Prefer imports and simple class names over fully qualified names in method bodies.
- Avoid wildcard imports and remove imports made unused by a change.
- Qualify a name inline only when needed to resolve a real ambiguity, and make the distinction clear.
- Follow the target repository's import grouping and build checks.

### Interactive UI behavior

- For suitable mutations, update local UI state immediately, reconcile it with the server response, and restore prior state on failure.
- Avoid reloading the whole page or collection for a local mutation. Keep temporary client identifiers and rollback behavior scoped to the feature.
- Surface failures to the user; do not silently discard them.
- For animations and interactive controls, provide keyboard focus styling and respect reduced-motion preferences. Keep shared visual behavior in shared styles rather than duplicating transitions at call sites.
- Treat design patterns as optional: use them only when they match the product's interaction model and existing architecture.

### Additional skill areas

| Skill area | Purpose |
| --- | --- |
| English Git artifacts | Enforce a consistent language and Conventional Commit format in versioned work. |
| Java clean imports | Keep Java dependencies visible and imports explicit. |
| Lean comments | Remove comments that restate code and retain concise explanations of non-obvious constraints. |
| Translation synchronization | Keep localized copy and accessible text aligned across supported locales. |
| Optimistic UI | Apply local updates, reconcile server state, and roll back on mutation failure where the interaction supports it. |
| Shared interactive controls | Reuse shared component styles and preserve focus and reduced-motion behavior. |

The visual style and optimistic update details from the source application are not universal rules. Adopt a target project's own UI language, accessibility requirements, API contracts, and state-management patterns.

### Plugin and agent configuration

That repository used OpenCode's scoped skills mechanism and codebase-memory graph guidance. Its project-specific OpenCode configuration did not declare additional plugins. Skills, MCP servers, and plugin configuration are separate concerns: document which client loads each skill, keep machine-level MCP credentials in local configuration, and avoid copying another repository's client settings wholesale.

## Adapting These Rules

This playbook is a starting point, not a replacement for project instructions. For each new repository, document its actual language, architecture, build commands, test strategy, security model, migration policy, and external integrations separately. Do not transfer business rules or environment assumptions from another codebase.
