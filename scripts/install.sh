#!/usr/bin/env bash
# Install dotnet-claude-kit Copilot customizations into a target repository.
#
# Usage:
#   bash scripts/install.sh [--target <path>] [--template <name>] [--force]
#
# Templates: blazor-app, class-library, modular-monolith, web-api, worker-service

set -euo pipefail

KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$(pwd)"
TEMPLATE=""
FORCE=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)   TARGET="$2"; shift 2 ;;
        --template) TEMPLATE="$2"; shift 2 ;;
        --force)    FORCE=1; shift ;;
        -h|--help)
            sed -n '1,/^set/p' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

TARGET="$(cd "$TARGET" && pwd)"
echo "Installing dotnet-claude-kit into $TARGET"
echo "  Source: $KIT_ROOT"

copy_tree() {
    local src="$1"
    local dst="$2"
    if [[ ! -e "$src" ]]; then
        echo "  WARN: source missing: $src"
        return
    fi
    if [[ -e "$dst" && "$FORCE" -eq 0 ]]; then
        echo "  Skipping (exists): $dst — use --force to overwrite"
        return
    fi
    rm -rf "$dst"
    mkdir -p "$(dirname "$dst")"
    cp -R "$src" "$dst"
    echo "  Copied: $(basename "$src") -> $dst"
}

mkdir -p "$TARGET/.github" "$TARGET/.vscode"

for child in copilot-instructions.md instructions skills prompts agents hooks; do
    copy_tree "$KIT_ROOT/.github/$child" "$TARGET/.github/$child"
done

copy_tree "$KIT_ROOT/.vscode/mcp.json" "$TARGET/.vscode/mcp.json"
copy_tree "$KIT_ROOT/hooks"            "$TARGET/hooks"

if [[ -n "$TEMPLATE" ]]; then
    TMPL_SRC="$KIT_ROOT/templates/$TEMPLATE/.github/copilot-instructions.md"
    TMPL_DST="$TARGET/.github/copilot-instructions.md"
    if [[ -f "$TMPL_SRC" ]]; then
        if [[ -f "$TMPL_DST" && "$FORCE" -eq 0 ]]; then
            echo "  WARN: template overlay skipped (exists): $TMPL_DST — use --force"
        else
            cp "$TMPL_SRC" "$TMPL_DST"
            echo "  Overlaid template '$TEMPLATE' copilot-instructions.md"
        fi
    else
        echo "  WARN: template not found: $TEMPLATE"
    fi
fi

echo
echo "Install complete."
echo "Next steps:"
echo "  1. Open the target repo in VS Code."
echo "  2. Build the Roslyn MCP server: dotnet build mcp/CWM.RoslynNavigator (or copy the kit's mcp/ folder)."
echo "  3. Adjust .vscode/mcp.json args path if mcp/ lives outside the repo."
echo "  4. Confirm Copilot Chat shows the custom instructions."
