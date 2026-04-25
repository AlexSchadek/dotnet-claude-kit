<#
.SYNOPSIS
  Pre-Bash Guard — Block destructive operations.
.DESCRIPTION
  Inspects a bash/shell command via stdin JSON (Copilot PreToolUse hook contract)
  and blocks destructive git, rm, and similar operations.
  Exit 2 = block. Exit 0 = allow.
#>

$ErrorActionPreference = 'Stop'

$command = $env:CLAUDE_TOOL_INPUT
if (-not $command -and -not [Console]::IsInputRedirected -eq $false) {
    try {
        $stdin = [Console]::In.ReadToEnd()
        if ($stdin) {
            $payload = $stdin | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($payload.tool_input.command) { $command = $payload.tool_input.command }
        }
    } catch { }
}

if (-not $command) { exit 0 }

function Block($msg) {
    [Console]::Error.WriteLine("BLOCKED: $msg")
    exit 2
}

# Destructive git operations
if ($command -match 'git\s+push\s+.*--force|git\s+push\s+-f\b') {
    Block 'Force push detected. Use regular push or discuss with the user first.'
}
if ($command -match 'git\s+reset\s+--hard') {
    Block 'git reset --hard will discard all uncommitted changes. Discuss with the user first.'
}
if ($command -match 'git\s+clean\s+-[a-zA-Z]*f') {
    Block 'git clean -f will permanently delete untracked files. Discuss with the user first.'
}
if ($command -match 'git\s+checkout\s+\.') {
    Block 'git checkout . will discard all unstaged changes. Discuss with the user first.'
}

# Dangerous file operations
if ($command -match 'rm\s+-[a-zA-Z]*r[a-zA-Z]*f|rm\s+-[a-zA-Z]*f[a-zA-Z]*r') {
    if ($command -match 'rm\s+-rf\s+(node_modules|bin|obj|TestResults|\.vs|/tmp)') {
        # safe target — fall through
    } else {
        Block 'rm -rf detected in a project directory. Verify the target path is intentional.'
    }
}

# Windows equivalents
if ($command -match 'Remove-Item\s+.*-Recurse.*-Force|Remove-Item\s+.*-Force.*-Recurse') {
    if ($command -notmatch '(node_modules|bin|obj|TestResults|\.vs)') {
        Block 'Remove-Item -Recurse -Force detected. Verify the target path is intentional.'
    }
}

# dotnet run advisory
if ($command -match 'dotnet\s+run\b') {
    [Console]::Error.WriteLine('NOTE: dotnet run detected. Ensure launchSettings.json exists and the correct profile is selected.')
}

exit 0
