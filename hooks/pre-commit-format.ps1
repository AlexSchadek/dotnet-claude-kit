<#
.SYNOPSIS
  Pre-commit hook: verify code formatting.
.DESCRIPTION
  Runs `dotnet format --verify-no-changes`. Fails if any files need formatting.
#>

$ErrorActionPreference = 'Stop'

Write-Host 'Checking code formatting...'

& dotnet format --verify-no-changes --verbosity quiet 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host 'Format check passed.'
    exit 0
} else {
    Write-Host "Format check failed. Run 'dotnet format' to fix formatting issues."
    exit 1
}
