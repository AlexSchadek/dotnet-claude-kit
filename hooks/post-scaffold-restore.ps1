<#
.SYNOPSIS
  Post-scaffold hook: restore NuGet packages after .csproj changes.
.DESCRIPTION
  Triggered when a .csproj file is created or modified.
  Accepts file path via argument, CLAUDE_EDITED_FILE env var, or stdin JSON.
#>

param([string]$Path)

$file = $Path
if (-not $file) { $file = $env:CLAUDE_EDITED_FILE }

if (-not $file -and [Console]::IsInputRedirected) {
    try {
        $stdin = [Console]::In.ReadToEnd()
        if ($stdin) {
            $payload = $stdin | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($payload.tool_input.file_path) { $file = $payload.tool_input.file_path }
        }
    } catch { }
}

# If we have a file path, only restore for .csproj files
if ($file -and $file -notlike '*.csproj') { exit 0 }

Write-Host 'Project file changed. Running dotnet restore...'
try {
    & dotnet restore --verbosity quiet 2>$null
    Write-Host 'Restore completed.'
} catch {
    Write-Host 'Warning: dotnet restore failed. You may need to restore manually.'
}

exit 0
