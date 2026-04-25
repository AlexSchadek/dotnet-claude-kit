<#
.SYNOPSIS
  Install dotnet-claude-kit Copilot customizations into a target repository.

.DESCRIPTION
  Copies the kit's `.github/` (skills, prompts, agents, instructions, hooks,
  copilot-instructions.md), `.vscode/mcp.json`, and the `hooks/` PowerShell
  scripts into a target repo. Optionally overlays a template's
  `.github/copilot-instructions.md`.

.PARAMETER Target
  Destination repository root. Defaults to the current directory.

.PARAMETER Template
  Optional template name to overlay (blazor-app, class-library, modular-monolith,
  web-api, worker-service).

.PARAMETER Force
  Overwrite existing files. Without -Force, existing files are skipped with a warning.

.EXAMPLE
  pwsh -File scripts/install.ps1 -Target C:\src\my-app

.EXAMPLE
  pwsh -File scripts/install.ps1 -Target C:\src\my-app -Template web-api -Force
#>

[CmdletBinding()]
param(
    [string]$Target = (Get-Location).Path,
    [ValidateSet('', 'blazor-app', 'class-library', 'modular-monolith', 'web-api', 'worker-service')]
    [string]$Template = '',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$kitRoot = Split-Path -Parent $PSScriptRoot
$Target  = (Resolve-Path $Target).Path

Write-Host "Installing dotnet-claude-kit into $Target"
Write-Host "  Source: $kitRoot"

function Copy-Tree {
    param(
        [string]$From,
        [string]$To,
        [switch]$ForceCopy
    )

    if (-not (Test-Path $From)) {
        Write-Warning "Source missing: $From"
        return
    }

    if ((Test-Path $To) -and -not $ForceCopy) {
        Write-Warning "Skipping (exists): $To  — use -Force to overwrite"
        return
    }

    Copy-Item -Path $From -Destination $To -Recurse -Force:$ForceCopy
    Write-Host "  Copied: $(Split-Path -Leaf $From) -> $To"
}

# .github/
$githubSrc = Join-Path $kitRoot '.github'
$githubDst = Join-Path $Target  '.github'
if (-not (Test-Path $githubDst)) { New-Item -ItemType Directory -Path $githubDst | Out-Null }

foreach ($child in 'copilot-instructions.md', 'instructions', 'skills', 'prompts', 'agents', 'hooks') {
    Copy-Tree -From (Join-Path $githubSrc $child) -To (Join-Path $githubDst $child) -ForceCopy:$Force
}

# .vscode/mcp.json
$vscodeDst = Join-Path $Target '.vscode'
if (-not (Test-Path $vscodeDst)) { New-Item -ItemType Directory -Path $vscodeDst | Out-Null }
Copy-Tree -From (Join-Path $kitRoot '.vscode/mcp.json') -To (Join-Path $vscodeDst 'mcp.json') -ForceCopy:$Force

# hooks/ (PowerShell scripts referenced by .github/hooks/hooks.json)
Copy-Tree -From (Join-Path $kitRoot 'hooks') -To (Join-Path $Target 'hooks') -ForceCopy:$Force

# Optional template overlay
if ($Template) {
    $tmplSrc = Join-Path $kitRoot "templates/$Template/.github/copilot-instructions.md"
    if (Test-Path $tmplSrc) {
        $tmplDst = Join-Path $githubDst 'copilot-instructions.md'
        if ((Test-Path $tmplDst) -and -not $Force) {
            Write-Warning "Template overlay skipped (exists): $tmplDst — use -Force to overwrite"
        } else {
            Copy-Item -Path $tmplSrc -Destination $tmplDst -Force
            Write-Host "  Overlaid template '$Template' copilot-instructions.md"
        }
    } else {
        Write-Warning "Template not found: $Template"
    }
}

Write-Host ''
Write-Host 'Install complete.'
Write-Host 'Next steps:'
Write-Host '  1. Open the target repo in VS Code.'
Write-Host '  2. Build the Roslyn MCP server: dotnet build mcp/CWM.RoslynNavigator (or copy the kit''s mcp/ folder).'
Write-Host '  3. Adjust .vscode/mcp.json args path if mcp/ lives outside the repo.'
Write-Host '  4. Confirm Copilot Chat shows the custom instructions.'
