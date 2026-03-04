---
description: >
  Systematic code cleanup pass. Triggers on: /de-sloppify, "clean this up",
  "cleanup pass", "tidy the code", "fix the mess", "before PR cleanup".
  Runs formatting, dead code removal, analyzer fixes, and structural improvements.
---

# /de-sloppify

## What

A sequential code cleanup pipeline that systematically improves code quality across multiple dimensions:

1. **Format** -- Run `dotnet format` to fix whitespace, indentation, and style violations
2. **Unused usings** -- Remove all unused `using` directives across the solution
3. **Analyzer warnings** -- Resolve compiler and Roslyn analyzer warnings (CA/IDE rules)
4. **Dead code** -- Identify and remove unreferenced types, methods, and properties
5. **TODOs** -- Surface remaining TODO/HACK/FIXME comments for triage
6. **Sealed classes** -- Seal classes that are not inherited and not designed for extension
7. **Missing CancellationToken** -- Add `CancellationToken` parameters to async methods that lack them

Each step is verified before moving to the next. The pipeline stops on build failure and reports what was fixed.

## When

- Before opening a pull request -- catch quality issues before review
- After a sprint of feature work -- accumulated tech debt cleanup
- When the user says "clean this up", "de-sloppify", or "tidy the code"
- After merging multiple branches -- resolve inconsistencies
- Periodic hygiene pass on any active project

## How

### Step 1: Invoke Skills and Agents

Load the following:

- **Skill**: `de-sloppify` -- Provides the cleanup checklist and ordering rules
- **Agent**: `refactor-cleaner` -- Handles the structural improvements (sealing, CancellationToken propagation, dead code removal)

### Step 2: Run the Pipeline

Execute each cleanup phase sequentially:

```
1. dotnet format --verify-no-changes   (detect issues)
2. dotnet format                        (fix formatting)
3. dotnet build -warnaserror            (surface warnings)
4. Roslyn MCP: get_diagnostics          (get full diagnostic list)
5. Roslyn MCP: find_dead_code           (identify unused symbols)
6. Roslyn MCP: detect_antipatterns      (catch known anti-patterns)
7. dotnet build                         (verify nothing broke)
8. dotnet test                          (verify behavior preserved)
```

### Step 3: Verify and Report

After all steps complete, produce a summary:

- Files modified (count and list)
- Warnings resolved (before/after count)
- Dead code removed (types, methods, properties)
- Anti-patterns fixed
- Remaining TODOs surfaced for user decision
- Build and test status (must be green)

### Important Rules

- **Never change behavior** -- Cleanup is cosmetic and structural only
- **Verify after each step** -- Run `dotnet build` between phases to catch regressions
- **Ask before removing** -- If a symbol looks unused but might be part of a public API, ask the user
- **Respect .editorconfig** -- All formatting follows the project's existing style configuration
- **Commit incrementally** -- Offer to commit after each major phase for easy rollback

## Example

```
User: /de-sloppify

Claude: Starting cleanup pipeline for the solution...

Phase 1/7: Formatting
  - Running `dotnet format`...
  - Fixed 12 files (whitespace, using order)
  - Build: GREEN

Phase 2/7: Unused Usings
  - Removed 8 unused using directives across 6 files
  - Build: GREEN

Phase 3/7: Analyzer Warnings
  - Resolved 5 CA1822 (mark as static), 3 IDE0060 (unused parameter)
  - Build: GREEN (warnings: 14 -> 6)

Phase 4/7: Dead Code
  - Found 2 unreferenced internal methods -- removed
  - Found 1 unreferenced type (OldDto) -- confirm removal? [y/n]

Phase 5/7: TODOs
  - 3 remaining TODOs found:
    - OrderService.cs:42  // TODO: add retry logic
    - Startup.cs:18       // HACK: workaround for config bug
    - UserRepo.cs:95      // FIXME: n+1 query

Phase 6/7: Sealed Classes
  - Sealed 4 classes with no derived types

Phase 7/7: CancellationToken
  - Added CancellationToken to 2 async methods
  - Propagated to 3 downstream calls

Summary: 23 files modified, warnings 14->6, all tests passing.
```

## Related

- `/verify` -- Run build and test verification without cleanup
- `/health-check` -- Broader project health assessment including dependencies and architecture
