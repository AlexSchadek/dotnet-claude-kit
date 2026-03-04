---
description: >
  Multi-dimensional project health assessment that produces letter grades (A-F)
  across code quality, architecture compliance, test coverage, dead code, anti-patterns,
  and circular dependencies. Uses Roslyn MCP tools for deep static analysis.
  Invoke when: "health check", "project health", "quality report", "assess codebase",
  starting on a new codebase, periodic quality audit.
---

# /health-check

## What

Comprehensive project health assessment that evaluates a .NET solution across six
dimensions and produces a graded report card. Each dimension receives a letter
grade (A through F) based on objective criteria, and the report includes an
overall health score with specific, actionable items to improve each grade.

This is a read-only analysis -- it does not modify any code. It uses Roslyn MCP
tools for static analysis combined with build and test verification.

## When

- Starting work on a new or unfamiliar codebase (establish a baseline)
- Periodic quality check (monthly or per-sprint)
- Before a major initiative (migration, refactor, new feature area)
- After a large merge or release to assess accumulated tech debt
- User says: "health check", "how healthy is this project?", "quality report"

## How

### Dimensions and Grading

| # | Dimension | MCP Tools | A | B | C | D | F |
|---|-----------|-----------|---|---|---|---|---|
| 1 | **Build & Compiler Health** | `get_diagnostics(scope: "solution")` + `dotnet build` | 0 errors, 0 warnings | 0 errors, 1-5 warnings | 0 errors, 6-15 warnings | 0 errors, 16+ warnings | Any errors |
| 2 | **Anti-Pattern Density** | `detect_antipatterns(severity: "warning")` | 0 per 1K LoC | 1-2 per 1K LoC | 3-5 per 1K LoC | 6-10 per 1K LoC | 11+ per 1K LoC |
| 3 | **Architecture Compliance** | `get_project_graph()` + `detect_circular_dependencies(scope: "projects")` | Clean graph, zero cycles | 1-2 minor concerns | 1-2 circular deps | 3+ circular deps | Tangled graph |
| 4 | **Test Coverage** | `get_test_coverage_map(maxResults: 100)` + `dotnet test` | 90%+ types tested | 80-89% | 70-79% | 60-69% | Below 60% |
| 5 | **Dead Code** | `find_dead_code(scope: "solution", maxResults: 50)` | 0-2 symbols | 3-5 | 6-10 | 11-20 | 21+ |
| 6 | **Type Dependency Health** | `detect_circular_dependencies(scope: "types", projectFilter: each project)` | Zero cycles | 1-2 in non-core | 3-5 or any in domain | 6-10 cycles | 11+ cycles |

### Overall Score

Each dimension weighted equally. Letter-to-points: A=95, B=85, C=75, D=65, F=40.
Overall grade: **A** (90+), **B** (80-89), **C** (70-79), **D** (60-69), **F** (<60).

### Report Format

```markdown
## Project Health Report

| Dimension                | Grade | Score | Key Finding                    |
|--------------------------|-------|-------|--------------------------------|
| Build & Compiler Health  | A     | 95    | Zero errors, zero warnings     |
| Anti-Pattern Density     | B     | 85    | 2 DateTime.Now usages found    |
| Architecture Compliance  | A     | 95    | Clean dependency graph         |
| Test Coverage            | C     | 75    | 73% types have tests           |
| Dead Code                | B     | 85    | 4 unused methods found         |
| Type Dependency Health   | A     | 95    | Zero type-level cycles         |

### Overall: B (88/100)

## Top 3 Improvement Actions
1. [Most impactful action to raise the lowest grade]
2. [Second most impactful action]
3. [Third most impactful action]

## Detailed Findings
[Per-dimension breakdown with specific file paths and line numbers]
```

## Invokes

| Type  | Name                   | Purpose                                     |
|-------|------------------------|---------------------------------------------|
| Skill | `code-review-workflow` | Structured review process and MCP tool usage |
| Agent | `code-reviewer`        | Code quality expertise and pattern detection |

### MCP Tools Used

- `get_diagnostics` -- Compiler errors and warnings across the solution
- `detect_antipatterns` -- Anti-pattern detection with severity filtering
- `get_project_graph` -- Project dependency tree and framework targets
- `detect_circular_dependencies` -- Project-level and type-level cycle detection
- `get_test_coverage_map` -- Structural test coverage by naming convention
- `find_dead_code` -- Unused types, methods, and properties

## Example

```
User: /health-check

Claude: Running project health assessment...

  Dimension 1: Build & Compiler Health -- A (95)
    Zero errors, 0 warnings. Clean build.

  Dimension 2: Anti-Pattern Density -- B (85)
    3 findings: 2x DateTime.Now (OrderService, PaymentHandler), 1x broad catch (Startup).

  Dimension 3: Architecture Compliance -- A (95)
    Clean Architecture detected. Dependency direction correct. Zero circular refs.

  Dimension 4: Test Coverage -- C (75)
    73% of production types have test classes.
    Missing: PaymentHandler, NotificationService, 4 validators.
    Tests: 52/52 passed.

  Dimension 5: Dead Code -- A (95)
    1 unused method: OrderExtensions.ToLegacyDto()

  Dimension 6: Type Dependency Health -- A (95)
    Zero type-level cycles.

  Overall: B+ (90/100)

  Top 3 Improvement Actions:
  1. Add tests for PaymentHandler and NotificationService (C -> B on coverage)
  2. Replace 2x DateTime.Now with TimeProvider (B -> A on anti-patterns)
  3. Remove OrderExtensions.ToLegacyDto() dead code
```

## Related

- `/verify` -- Quick verification pass (build + test + format)
- `/de-sloppify` -- Fix code quality issues found by health check
- `/code-review` -- Targeted review of specific files or PRs
- `/security-scan` -- Deep security-focused audit (complements health check)
