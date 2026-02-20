#!/usr/bin/env bash
# Post-scaffold hook: restore NuGet packages after .csproj changes
# Triggered when a .csproj file is created or modified.

set -euo pipefail

echo "Project file changed. Running dotnet restore..."

if dotnet restore --verbosity quiet 2>/dev/null; then
    echo "Restore completed."
else
    echo "Warning: dotnet restore failed. You may need to restore manually."
fi
