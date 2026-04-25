---
description: "Result pattern for expected failures, ProblemDetails for HTTP errors, and boundary-only exception handling."
applyTo: "**/*.cs"
---

# Error Handling Rules

## Result Pattern Over Exceptions

- **DO** use a Result/Result<T> pattern for expected failure paths (not found, validation, conflict). Exceptions are expensive and hide control flow.
- **DON'T** use try-catch for flow control. If you can predict the failure, return a Result.
- **DO** define typed error codes: `NotFound`, `Validation`, `Conflict`, `Unauthorized`. Typed errors enable consistent mapping to HTTP status codes.

## ProblemDetails for HTTP Responses

- **DO** return ProblemDetails (RFC 9457) for all HTTP error responses. Industry standard format that clients can parse consistently.
- **DON'T** return bare strings or ad-hoc JSON for errors.

## Exception Handling Boundaries

- **DO** verify `app.UseExceptionHandler()` + `IExceptionHandler` (or inline handler) exists in Program.cs for EVERY web project. Without a global handler, unhandled exceptions leak stack traces.
- **DON'T** catch bare `Exception` unless at the application boundary.
- **DON'T** catch and rethrow without adding context. Either handle it or let it propagate.

## Boundary Validation

- **DO** validate at system boundaries: API input, external service responses, file/config data.
- **DON'T** defensively validate inside internal/private methods. Internal code should trust validated data.

## Quick Reference

| Scenario | Approach |
|---|---|
| User input invalid | Result with Validation error |
| Entity not found | Result with NotFound error |
| Unhandled crash | IExceptionHandler middleware |
| External API failure | Catch specific exception, return Result |
| Concurrent update | Result with Conflict error |
