<#
.SYNOPSIS
  Pre-build hook: validate project structure matches expected architecture.
.DESCRIPTION
  Checks that expected project folders exist and naming conventions are followed.
  Run before `dotnet build` to catch structural issues early.
#>

param([string]$SolutionDir = '.')

$errors   = 0
$warnings = 0

Write-Host 'Validating project structure...'

$slnCount = (Get-ChildItem -Path $SolutionDir -File -Filter *.sln* -ErrorAction SilentlyContinue | Measure-Object).Count
if ($slnCount -eq 0) {
    Write-Host "  WARN: No .sln or .slnx file found in $SolutionDir"
    $warnings++
}

$csprojFiles = Get-ChildItem -Path $SolutionDir -Recurse -Filter *.csproj -ErrorAction SilentlyContinue
$csprojCount = $csprojFiles.Count
if ($csprojCount -gt 2 -and -not (Test-Path (Join-Path $SolutionDir 'Directory.Build.props'))) {
    Write-Host '  WARN: Multi-project solution without Directory.Build.props — consider centralizing common settings'
    $warnings++
}

if (-not (Test-Path (Join-Path $SolutionDir 'global.json'))) {
    Write-Host '  WARN: No global.json found — consider pinning the SDK version'
    $warnings++
}

if (-not (Test-Path (Join-Path $SolutionDir '.editorconfig'))) {
    Write-Host '  WARN: No .editorconfig found — consider adding for consistent code style'
    $warnings++
}

$testCount = ($csprojFiles | Where-Object { $_.Name -match 'Tests?\.csproj$' }).Count
if ($testCount -eq 0 -and $csprojCount -gt 1) {
    Write-Host '  WARN: No test projects found — consider adding tests'
    $warnings++
}

if ($csprojCount -gt 0) {
    $frameworks = ($csprojFiles | ForEach-Object {
        Select-String -Path $_.FullName -Pattern '<TargetFramework>([^<]+)</TargetFramework>' -ErrorAction SilentlyContinue |
            ForEach-Object { $_.Matches[0].Groups[1].Value }
    } | Sort-Object -Unique)
    if ($frameworks.Count -gt 1) {
        Write-Host '  WARN: Mixed target frameworks detected — consider aligning all projects'
        $warnings++
    }
}

Write-Host ''
if ($errors -gt 0) {
    Write-Host "  $errors error(s) found — fix before building"
    exit 1
} elseif ($warnings -gt 0) {
    Write-Host "  $warnings warning(s) — consider addressing these"
    exit 0
} else {
    Write-Host '  Project structure looks good'
    exit 0
}
