---
description: "Security best practices for .NET: secrets management, input validation, auth patterns, and OWASP compliance."
applyTo: "**/*.cs"
---

# Security Rules

## Secrets Management

- **Never hardcode secrets in source code.** Use `dotnet user-secrets` for local development, Azure Key Vault or environment variables for deployed environments.
- **Never commit `.env` files, `appsettings.Development.json` with real credentials, or `credentials.json`.**

```csharp
// DO
builder.Configuration.AddAzureKeyVault(vaultUri, credential);
var conn = builder.Configuration.GetConnectionString("Default");

// DON'T
var conn = "Server=prod;Password=hunter2";
```

## Input Validation

- **Validate all external input at system boundaries.** API endpoints, message handlers, file uploads. Use FluentValidation or built-in attributes before data reaches domain logic.
- **Use parameterized queries — never string concatenation for SQL.** EF Core parameterizes by default; raw SQL and Dapper require explicit parameterization.

## Authentication and Authorization

- **Always add `[Authorize]` or `[AllowAnonymous]` explicitly.** Ambiguous auth is a security hole.

```csharp
// DO
[Authorize(Policy = "AdminOnly")]
public sealed class AdminController : ControllerBase { }

[AllowAnonymous]
app.MapGet("/health", () => Results.Ok());
```

## Transport and Data Protection

- **Use HTTPS everywhere.** Enforce via HSTS in production.

```csharp
app.UseHsts();
app.UseHttpsRedirection();
```

- **Use Data Protection API for encrypting user data at rest.** Never roll your own.
- **CORS: explicit origins only, never wildcard in production.**

```csharp
// DO
builder.Services.AddCors(o => o.AddPolicy("Web", p =>
    p.WithOrigins("https://app.example.com")
     .AllowAnyMethod()
     .AllowAnyHeader()));
```

## Logging

- **Do not log PII at Information level or below.** Emails, names, IP addresses, and tokens stay at `Debug` at most, only in development.
