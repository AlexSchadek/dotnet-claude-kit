---
description: "Correct interaction with pre-commit, post-edit, and post-test hooks. Loaded on demand."
---

# Hook Rules

## Format Hooks

- **DO** auto-accept post-edit format hooks. They enforce consistent style automatically.
- **DON'T** revert or undo formatting changes applied by hooks.

## Pre-Commit Hooks

- **DON'T** skip pre-commit hooks with `--no-verify`. Pre-commit hooks catch real issues (build errors, lint failures, format violations).
- **DO** investigate and fix the root cause when a hook blocks a commit.

## Post-Test Analysis

- **DO** review post-test-analyze hook output. Contains actionable insights about test quality and coverage.

## Hook Infrastructure

- **DON'T** interfere with hook configuration. Hooks run automatically via plugin settings.
- **DO** wait for post-scaffold-restore to complete after `.csproj` changes before building. NuGet restore must finish before the build can resolve dependencies.

## Quick Reference

| Hook | Correct Response |
|---|---|
| Post-edit format | Accept the changes |
| Pre-commit failure | Fix the issue, commit again |
| Post-test-analyze | Read and act on insights |
| Post-scaffold-restore | Wait for completion before building |
