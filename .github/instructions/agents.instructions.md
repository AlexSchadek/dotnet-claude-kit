---
description: "MCP-first tool usage, subagent routing for parallel work, and agent selection guidance. Loaded on demand."
---

# Agent & Tool Usage Rules

## MCP Tools Before File Reading

- **DO** use Roslyn MCP tools (`find_symbol`, `find_references`, `get_public_api`, `get_type_hierarchy`) before reading source files. MCP tools return focused, token-efficient results.
- **DO** use `get_project_graph` before making any structural changes (new projects, moved references).
- **DO** use `get_diagnostics` after modifications instead of running `dotnet build` when possible.
- **DON'T** read entire files to find a single method or type. Use `find_symbol` first.

## Subagent Routing

- **DO** use subagents for parallel research, exploration, and independent tasks. Keep the main context window clean.
- **DO** assign one task per subagent for focused execution.
- **DO** route to specialist agents for domain-specific work. Check `AGENTS.md` for the routing table.
- **DON'T** use subagents for trivial, single-step tasks. The overhead is not worth it.

## Model Selection

- **DO** use Sonnet for routine tasks: formatting, simple refactors, test generation, boilerplate.
- **DO** use Opus for complex architecture decisions, design reviews, and multi-system analysis.

## Skill Loading

- **DO** load relevant skills before starting work. Check `AGENTS.md` skill maps for the current task domain.
- **DON'T** start implementation without checking if a relevant skill exists.

## Quick Reference

| Need | Tool / Approach |
|---|---|
| Find where a type is defined | `find_symbol` |
| Understand who calls a method | `find_callers` |
| Check public API surface | `get_public_api` |
| Verify no regressions | `get_diagnostics` |
| Parallel research | Subagent |
| Architecture decision | Opus + specialist agent |
| Routine refactor | Sonnet |
