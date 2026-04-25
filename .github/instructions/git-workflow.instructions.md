---
description: "Conventional commits, branch naming, atomic commits, and PR verification workflow. Loaded on demand for git tasks."
---

# Git Workflow Rules

## Commit Messages

- **DO** use conventional commit prefixes: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`. Enables automated changelogs and semantic versioning.
- **DO** write the commit body to explain "why", not "what". The diff shows what changed.
- **DON'T** write vague messages like "fix bug" or "update code".

## Branch Naming

- **DO** use prefixed branch names: `feature/`, `fix/`, `refactor/`. Prefixes make branch purpose obvious.
- **DON'T** use personal or opaque branch names like `my-branch` or `wip`.

## Atomic Commits

- **DO** make one logical change per commit. A feature and its tests belong together.
- **DO** include test changes in the same commit as the feature or fix they cover.
- **DON'T** bundle unrelated changes in a single commit.

## Branch Safety

- **DON'T** force-push to main or master. Ever. Force-push rewrites shared history.
- **DON'T** skip pre-commit hooks with `--no-verify`. Hooks catch real issues.

## PR Process

- **DO** run verification (`/verify` or `dotnet build` + `dotnet test`) before creating a PR.
- **DO** keep PRs focused on a single concern. Split large changes into stacked PRs.

## Quick Reference

| Action | Convention |
|---|---|
| New feature | `feat: add order export endpoint` |
| Bug fix | `fix: prevent duplicate payments on retry` |
| Refactor | `refactor: extract pricing calculator from OrderService` |
| Tests only | `test: add edge cases for discount calculation` |
| Branch for feature | `feature/order-export` |
| Branch for fix | `fix/duplicate-payment` |
