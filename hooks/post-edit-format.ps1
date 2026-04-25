<#
.SYNOPSIS
  Post-edit hook: auto-format edited .cs files.
.DESCRIPTION
  Runs `dotnet format` scoped to the file just edited.
  Accepts file path via:
    1. First argument
    2. CLAUDE_EDITED_FILE env var
    3. PostToolUse stdin JSON ({"tool_input":{"file_path":"..."}})
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

if (-not $file) { exit 0 }
if ($file -notlike '*.cs') { exit 0 }
if (-not (Test-Path $file)) { exit 0 }

# Walk up to nearest .csproj or .sln
$dir = Split-Path -Parent $file
$project = $null
while ($dir -and (Test-Path $dir)) {
    $csproj = Get-ChildItem -Path $dir -Filter '*.csproj' -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($csproj) { $project = $csproj.FullName; break }
    $sln = Get-ChildItem -Path $dir -Filter '*.sln*' -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($sln) { $project = $sln.FullName; break }
    $parent = Split-Path -Parent $dir
    if ($parent -eq $dir) { break }
    $dir = $parent
}

if ($project) {
    & dotnet format $project --include $file --no-restore 2>$null
} else {
    Write-Host "No .csproj or .sln found for $file, skipping format"
}

exit 0
