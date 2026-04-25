<#
.SYNOPSIS
  Post-test hook: analyze dotnet test output and emit a summary.
.DESCRIPTION
  Pipe `dotnet test` output to this script, or pass a log file path as argument.
#>

param([string]$LogFile)

$output = $null
if ($LogFile -and (Test-Path $LogFile)) {
    $output = Get-Content -Raw $LogFile
} elseif ([Console]::IsInputRedirected) {
    $output = [Console]::In.ReadToEnd()
} else {
    Write-Host 'Usage: dotnet test 2>&1 | pwsh -File hooks/post-test-analyze.ps1'
    Write-Host '   or: pwsh -File hooks/post-test-analyze.ps1 <test-output.log>'
    exit 0
}

if (-not $output) { exit 0 }

$passed  = ([regex]::Matches($output, 'Passed!')).Count
$failed  = ([regex]::Matches($output, 'Failed!')).Count
$skipped = ([regex]::Matches($output, 'Skipped!')).Count

$failureLines = ($output -split "`n") | Where-Object { $_ -match 'Failed\s' } | Select-Object -First 50

Write-Host ''
Write-Host '==================================='
Write-Host '  Test Results Summary'
Write-Host '==================================='
Write-Host ''

if ($failed -gt 0) {
    Write-Host "  FAILED:  $failed"
    Write-Host "  Passed:  $passed"
    Write-Host "  Skipped: $skipped"
    Write-Host ''
    Write-Host '  Failed Tests:'
    Write-Host '  -------------'
    $failureLines | ForEach-Object { Write-Host $_ }
    Write-Host ''
    Write-Host '  Next Steps:'
    Write-Host '  1. Fix the failing tests above'
    Write-Host '  2. Run ''dotnet test'' to verify fixes'
    Write-Host '  3. Check test output for root cause details'
} else {
    Write-Host "  All $passed test(s) passed"
    if ($skipped -gt 0) { Write-Host "  $skipped test(s) skipped" }
}

Write-Host ''
Write-Host '==================================='
exit 0
