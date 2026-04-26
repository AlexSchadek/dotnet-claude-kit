# dotnet-claude-kit — Copilot Instructions

> Repository-level instructions for GitHub Copilot in VS Code. Always loaded.
> Domain-specific rules live in [./instructions/](./instructions/) and load via `applyTo` globs.

## Repository Purpose

dotnet-claude-kit is an opinionated GitHub Copilot companion for .NET developers. It provides skills, agents, prompts, templates, knowledge documents, and a Roslyn MCP server that make Copilot dramatically more effective for .NET 10 development.

## Philosophy

- **Guided over prescriptive** — Ask the right questions, then recommend the best approach with clear rationale.
- **Modern .NET only** — Target .NET 10 and C# 14. No legacy patterns, no .NET Framework backwards compatibility.
- **Architecture-aware** — Support VSA, Clean Architecture, DDD, and Modular Monolith via the `architecture-advisor` skill.
- **Token-conscious** — Skills max at ~400 lines, commands at ~200, instructions at ~100.
- **Practical over theoretical** — Every recommendation includes a working code example and a "why".

## Layout

| Folder | Purpose |
|---|---|
| `.github/copilot-instructions.md` | This file. Always loaded. |
| `.github/instructions/*.instructions.md` | Domain-scoped rules loaded via `applyTo` globs. |
| `.github/skills/<name>/SKILL.md` | On-demand workflows. ~50 skills. |
| `.github/prompts/*.prompt.md` | Slash-command prompts (e.g. `/plan`, `/scaffold`, `/verify`). |
| `.github/agents/*.agent.md` | Custom chat modes / specialist subagents. |
| `.github/hooks/*.json` | Lifecycle hooks (PowerShell scripts under `hooks/`). |
| `.github/instructions/dotnet-rules.instructions.md` | Compatibility map for Cursor `.cursor/rules/dotnet-rules.md` users in VS Code Copilot. |
| `.cursor/rules/dotnet-rules.md` | Generated aggregate reference for Cursor; not the primary Copilot instruction source. |
| `.vscode/mcp.json` | MCP server registration for the Roslyn navigator. |
| `agents/`, `commands/`, `skills/` (top-level) | **Removed** — migrated to `.github/`. |
| `knowledge/` | Reference material (ADRs, antipatterns, package recommendations). Tool-neutral. |
| `templates/` | Drop-in `.github/` overlays for new .NET projects. |
| `mcp/CWM.RoslynNavigator/` | The Roslyn MCP server source. Build with `dotnet build`. |
| `hooks/` | PowerShell hook scripts referenced by `.github/hooks/*.json`. Requires `pwsh` 7+. |

## Authoring Rules

### Skills (`.github/skills/<name>/SKILL.md`)

- Folder name MUST match `name:` field exactly.
- Frontmatter requires `name:` and `description:`. Quote any description containing a colon.
- Max ~400 lines per SKILL.md. Use `references/` subfolder for overflow.
- Every recommendation needs a "why".

### Prompts (`.github/prompts/*.prompt.md`)

- Frontmatter requires `description:`. Optional: `agent:`, `argument-hint:`, `model:`, `tools:`.
- Prompts orchestrate; they invoke skills and agents rather than duplicating their content.
- Max ~200 lines.

### Custom Agents (`.github/agents/*.agent.md`)

- Frontmatter requires `description:` (with trigger phrases for subagent discovery).
- Set `tools:` to the minimum the agent needs. Read-only agents (`code-reviewer`, `security-auditor`, `performance-analyst`) get `[read, search]`.
- Set `user-invocable: false` for subagent-only agents.
- Use `model:` array for fallback: `['Claude Sonnet 4.5 (copilot)', 'GPT-5 (copilot)']`.

### Instructions (`.github/instructions/*.instructions.md`)

- Frontmatter requires `description:`. Use `applyTo:` for scoped activation.
- **Never use `applyTo: "**"`** — burns context on every interaction. Use specific globs.
- Max ~100 lines each. Total instructions budget across all files: ~600 lines.

## Workflow Standards

- **Plan before building** — non-trivial work (3+ steps or architectural decisions) goes through `/plan` first.
- **Verify before done** — run `dotnet build` + `dotnet test` (or `/verify`) after changes.
- **Fix bugs autonomously** — investigate and resolve. Don't ask for hand-holding.
- **Use subagents for parallel work** — keep main context clean.
- **Learn from corrections** — capture patterns; the mistake rate should drop over time.

## Cursor Rules Compatibility

- If contributors use Cursor rules, treat `.cursor/rules/dotnet-rules.md` as a generated aggregate reference.
- For VS Code Copilot behavior, `.github/instructions/*.instructions.md` remains the source of truth.
- Keep rule content aligned by updating the domain instruction files (coding style, architecture, security, performance, testing, packages, git workflow, hooks) rather than editing generated aggregates directly.

## Roslyn MCP Server

Lives at `mcp/CWM.RoslynNavigator/`. Tools are read-only, token-optimized.

```
dotnet build mcp/CWM.RoslynNavigator/CWM.RoslynNavigator.slnx
dotnet test  mcp/CWM.RoslynNavigator/CWM.RoslynNavigator.slnx
```

`.vscode/mcp.json` wires it up automatically when the workspace opens in VS Code.

## See Also

- `AGENTS.md` — Tool-neutral routing table for specialists and meta skills.
- `CONTRIBUTING.md` — Authoring conventions for skills, prompts, agents, hooks.
- `docs/dotnet-claude-kit-SPEC.md` — Full vision and roadmap.
