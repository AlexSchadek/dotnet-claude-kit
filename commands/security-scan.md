---
description: >
  Deep security audit covering OWASP Top 10, secrets detection, vulnerable NuGet
  packages, authentication configuration, CORS policy, and data protection. Produces
  a structured report with severity-ranked findings. Invoke when: "security scan",
  "security audit", "check for vulnerabilities", before production deployment,
  after adding auth or payment features.
---

# /security-scan

## What

Comprehensive security audit that scans the solution across six dimensions:

1. **Vulnerable dependencies** -- NuGet packages with known CVEs
2. **Secrets detection** -- Hardcoded connection strings, API keys, tokens in source
3. **OWASP Top 10 patterns** -- Injection, broken auth, sensitive data exposure,
   security misconfiguration, and more
4. **Authentication and authorization** -- Missing `[Authorize]` attributes, weak
   JWT configuration, insecure cookie settings
5. **CORS policy** -- Overly permissive origins, missing restrictions
6. **Data protection** -- PII in logs, unencrypted sensitive data, missing input validation

The output is a structured security report with findings ranked by severity
(Critical, High, Medium, Low) and actionable remediation steps for each finding.

## When

- Before deploying to production or staging environments
- During a security review or compliance audit
- After adding authentication, authorization, or payment features
- After adding new API endpoints that handle sensitive data
- After updating packages (to catch newly disclosed vulnerabilities)
- Periodically as part of project health maintenance
- User says: "security scan", "check for vulnerabilities", "is this secure?"

## How

### Phase 1: Vulnerable Dependencies

```bash
dotnet list package --vulnerable
dotnet list package --deprecated
```

Flag any package with a known CVE. Report severity, CVE ID, and the fixed version.

### Phase 2: Secrets Detection

Scan source files for patterns that indicate hardcoded secrets:

- Connection strings with passwords in `appsettings.json` or `.cs` files
- API keys, tokens, or credentials in source code
- Private keys or certificates committed to the repository
- `.env` files or `secrets.json` tracked in git

Use grep-based scanning for patterns: `password=`, `secret`, `apikey`,
`connectionstring` with literal values (not placeholders or config references).

### Phase 3: OWASP Top 10 Patterns

Use MCP tools and source analysis:

```
get_diagnostics(scope: "solution") -- security analyzer warnings
detect_antipatterns(projectFilter: each project) -- broad catch, missing cancellation token
find_references(symbolName: "FromSqlRaw") -- potential SQL injection
find_references(symbolName: "Html.Raw") -- potential XSS
find_symbol(name: "Authorize") -- locate auth configuration
```

Check for:
- **A01 Broken Access Control** -- Endpoints missing `[Authorize]`, insecure direct object references
- **A02 Cryptographic Failures** -- Weak hashing, unencrypted sensitive data at rest
- **A03 Injection** -- Raw SQL queries, unsanitized user input in commands
- **A04 Insecure Design** -- Missing rate limiting, no input validation
- **A05 Security Misconfiguration** -- Debug mode in production config, default credentials
- **A06 Vulnerable Components** -- (covered in Phase 1)
- **A07 Auth Failures** -- Weak JWT settings, missing token validation parameters
- **A08 Data Integrity** -- Missing anti-forgery tokens, unsigned data
- **A09 Logging Failures** -- Missing audit logging, PII in log output
- **A10 SSRF** -- Unvalidated URLs in outbound HTTP calls

### Phase 4: Auth Configuration Review

```
find_symbol(name: "AddAuthentication") -- locate auth setup
find_symbol(name: "AddAuthorization") -- locate authorization policies
get_public_api(typeName: endpoints/controllers) -- check for [Authorize] presence
```

Verify:
- JWT `ValidateIssuer`, `ValidateAudience`, `ValidateLifetime` are all `true`
- Token expiration is reasonable (not 24+ hours for access tokens)
- Refresh token rotation is implemented
- Password hashing uses a strong algorithm (Argon2, bcrypt, or ASP.NET Identity default)

### Phase 5: CORS Policy

```
find_symbol(name: "AddCors") -- locate CORS configuration
find_references(symbolName: "WithOrigins") -- check allowed origins
find_references(symbolName: "AllowAnyOrigin") -- flag overly permissive CORS
```

### Phase 6: Data Protection

- Check for PII (email, phone, SSN) in log statements
- Verify sensitive model properties have `[PersonalData]` or are excluded from serialization
- Check that HTTPS is enforced (`UseHttpsRedirection`, HSTS headers)
- Verify anti-forgery token usage in form-based endpoints

### Report Format

```markdown
## Security Scan Report

### Summary
[X findings: N critical, N high, N medium, N low]

### Critical
- **[CVE/Category] [Title]** -- [File:Line] [Description]. [Remediation].

### High
- ...

### Medium
- ...

### Low
- ...

### Passed Checks
- [List of security checks that passed -- confirms coverage]
```

## Invokes

| Type  | Name               | Purpose                                       |
|-------|--------------------|-----------------------------------------------|
| Skill | `authentication`   | Auth and authorization best practices          |
| Skill | `configuration`    | Secrets management and environment config      |
| Agent | `security-auditor` | Deep security expertise and OWASP knowledge    |

### MCP Tools Used

- `get_diagnostics` -- Security analyzer warnings across the solution
- `detect_antipatterns` -- Broad catch blocks, missing cancellation tokens
- `find_references` -- Trace usage of security-sensitive APIs
- `find_symbol` -- Locate auth configuration, CORS setup, crypto usage
- `get_public_api` -- Review endpoint surfaces for missing auth attributes

## Example

```
User: /security-scan

Claude: Running security scan across 6 dimensions...

  Phase 1: Vulnerable Dependencies
  - CRITICAL: Newtonsoft.Json 12.0.3 has CVE-2024-XXXX (upgrade to 13.0.3+)

  Phase 2: Secrets Detection
  - HIGH: Hardcoded connection string in appsettings.Development.json:8
    contains plaintext password. Move to user-secrets or environment variable.

  Phase 3: OWASP Top 10
  - HIGH: FromSqlRaw usage in SearchService.cs:34 with string concatenation.
    Use FromSqlInterpolated or parameterized queries.
  - MEDIUM: No rate limiting configured on authentication endpoints.

  Phase 4: Auth Configuration
  - MEDIUM: JWT access token lifetime is 24 hours (Program.cs:67).
    Recommend 15-30 minutes with refresh token rotation.

  Phase 5: CORS Policy
  - Passed. Origins are explicitly listed, no AllowAnyOrigin.

  Phase 6: Data Protection
  - LOW: Email address logged at Information level in OrderService.cs:23.
    Mask PII or use Debug level.

  Summary: 5 findings (1 critical, 2 high, 1 medium, 1 low)
```

## Related

- `/verify` -- General verification pass including build and test
- `/health-check` -- Broader project health assessment (includes security dimension)
