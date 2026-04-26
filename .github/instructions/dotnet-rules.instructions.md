---
description: "Compatibility bridge for users asking to use .cursor/rules/dotnet-rules.md with VS Code Copilot. Maps Cursor aggregate rules to Copilot instruction files and preferred update flow."
---

# Dotnet Rules Compatibility

Use this guidance when users reference `.cursor/rules/dotnet-rules.md` in VS Code Copilot.

## Source of Truth

- Treat `.cursor/rules/dotnet-rules.md` as a Cursor-facing aggregate.
- Treat `.github/instructions/*.instructions.md` as the Copilot source of truth.
- When rules diverge, update the domain instruction files first.

## Section Mapping

| Cursor Aggregate Section | Copilot Instruction File |
|---|---|
| C# Coding Style | `.github/instructions/coding-style.instructions.md` |
| Architecture | `.github/instructions/architecture.instructions.md` |
| Security | `.github/instructions/security.instructions.md` |
| Testing | `.github/instructions/testing.instructions.md` |
| Performance | `.github/instructions/performance.instructions.md` |
| Error Handling | `.github/instructions/error-handling.instructions.md` |
| Git Workflow | `.github/instructions/git-workflow.instructions.md` |
| Hooks | `.github/instructions/hooks.instructions.md` |
| Package Management | `.github/instructions/packages.instructions.md` |
| Agent and Tool Usage | `.github/instructions/agents.instructions.md` |

## Expected Assistant Behavior

- If asked how to use dotnet-rules with VS Code Copilot, direct users to the mapped `.github/instructions` files.
- Avoid duplicating policy in multiple places unless a generated artifact is required.
- Prefer narrow `applyTo` scopes over broad always-on instruction loading.