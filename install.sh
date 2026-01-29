#!/bin/bash

set -e

echo "Installing Claude Code Status Line..."

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo ""
    echo "Install it with:"
    echo "  macOS:        brew install jq"
    echo "  Ubuntu/Debian: sudo apt install jq"
    echo ""
    exit 1
fi

# Create .claude directory if it doesn't exist
mkdir -p ~/.claude

# Copy the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/statusline.sh" ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
echo "Installed statusline.sh to ~/.claude/"

# Update settings.json
if [ -f ~/.claude/settings.json ]; then
    # Check if statusLine is already configured
    if jq -e '.statusLine' ~/.claude/settings.json > /dev/null 2>&1; then
        echo "statusLine already configured in settings.json - skipping"
    else
        # Backup and add statusLine config
        cp ~/.claude/settings.json ~/.claude/settings.json.backup
        jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' ~/.claude/settings.json.backup > ~/.claude/settings.json
        echo "Updated ~/.claude/settings.json (backup: settings.json.backup)"
    fi
else
    echo '{"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' > ~/.claude/settings.json
    echo "Created ~/.claude/settings.json"
fi

echo ""
echo "Done! Restart Claude Code or open a new session to see the status line."
echo ""
echo "Tip: Use /rename to name your sessions"
