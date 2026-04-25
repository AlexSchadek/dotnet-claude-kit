<#
.SYNOPSIS
  Pre-commit hook: detect anti-patterns in staged C# files.
.DESCRIPTION
  Lints staged .cs files for common .NET anti-patterns.
  For deep analysis, use the Roslyn MCP `detect_antipatterns` tool.
.OUTPUTS
  Exit 0 — no issues (or no staged .cs files).
  Exit 1 — issues found, commit blocked.
#>

$ErrorActionPreference = 'Stop'

$staged = git diff --cached --name-only --diff-filter=ACM 2>$null | Where-Object { $_ -like '*.cs' }
if (-not $staged) { exit 0 }

Write-Host 'Checking staged C# files for common issues...'
$errors = 0

foreach ($file in $staged) {
    if (-not (Test-Path $file)) { continue }

    $content = Get-Content -Raw $file -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    if ($content -match 'DateTime\.(Now|UtcNow)') {
        Write-Host "  WARN: $file — Use TimeProvider instead of DateTime.Now/UtcNow"
        $errors++
    }
    if ($content -match 'new HttpClient\(\)') {
        Write-Host "  WARN: $file — Use IHttpClientFactory instead of new HttpClient()"
        $errors++
    }
    $asyncVoid = ($content -split "`n") | Where-Object { $_ -match 'async void' -and $_ -notmatch 'EventArgs' }
    if ($asyncVoid) {
        Write-Host "  ERR:  $file — async void is dangerous; use async Task instead"
        $errors++
    }
    if ($content -match '\.Result\b|\.GetAwaiter\(\)\.GetResult\(\)') {
        Write-Host "  ERR:  $file — Avoid sync-over-async (.Result / .GetAwaiter().GetResult())"
        $errors++
    }
}

if ($errors -gt 0) {
    Write-Host ''
    Write-Host "Found $errors anti-pattern issue(s) in staged files."
    Write-Host "Fix the issues above or use 'git commit --no-verify' to skip this check (not recommended)."
    exit 1
}

Write-Host 'No anti-patterns detected in staged files.'
exit 0
