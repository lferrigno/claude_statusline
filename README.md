# Claude Code Status Line

A custom status line for [Claude Code](https://claude.ai/claude-code) that displays useful session information at the bottom of your terminal.

## What it shows

```
My Task | Opus 4.5 | my-project (main) | 12.5%
```

- **Session name** - Custom name you set with `/rename`
- **Model** - Current Claude model (Opus 4.5, Sonnet, etc.)
- **Directory** - Current project folder name
- **Git branch** - Current branch (if in a git repo)
- **Context %** - How much of the context window is used

## Why use this?

When you have multiple Claude Code terminals open, it's hard to tell which is which. This status line lets you glance at any terminal and instantly know:
- What task that session is working on
- Which project/branch it's in
- How much context is left

## Requirements

- [Claude Code](https://claude.ai/claude-code) CLI
- `jq` (JSON processor)
  - macOS: `brew install jq`
  - Ubuntu/Debian: `sudo apt install jq`
  - Other: https://jqlang.github.io/jq/download/

## Installation

### Option 1: Clone and install

```bash
git clone https://github.com/lferrigno/claude_statusline.git
cd claude_statusline
./install.sh
```

### Option 2: One-liner (curl)

```bash
# Download the script
mkdir -p ~/.claude
curl -o ~/.claude/statusline.sh https://raw.githubusercontent.com/lferrigno/claude_statusline/main/statusline.sh
chmod +x ~/.claude/statusline.sh

# Add to settings (creates file if it doesn't exist)
if [ -f ~/.claude/settings.json ]; then
    # Backup existing settings
    cp ~/.claude/settings.json ~/.claude/settings.json.backup
    # Add statusLine config (requires jq)
    jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' ~/.claude/settings.json.backup > ~/.claude/settings.json
else
    echo '{"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' > ~/.claude/settings.json
fi
```

### Option 3: Manual install

1. Copy `statusline.sh` to `~/.claude/`:

```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

2. Edit `~/.claude/settings.json` (create if it doesn't exist):

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

If you already have settings, just add the `statusLine` block.

3. Restart Claude Code or open a new session.

## Usage

### Naming sessions

Use `/rename` to give your session a descriptive name:

```
/rename fixing auth bug
/rename feature-user-dashboard
/rename code review PR #123
```

The name appears immediately in the status line.

### Resuming named sessions

```bash
# Interactive picker showing all sessions with names
claude --resume

# Resume by name directly
claude --resume "fixing auth bug"
```

## Customization

Edit `~/.claude/statusline.sh` to customize what's shown. The script receives JSON input with these fields:

```json
{
  "session_id": "uuid",
  "model": { "display_name": "Opus 4.5" },
  "workspace": {
    "current_dir": "/path/to/project",
    "project_dir": "/path/to/project"
  },
  "context_window": {
    "used_percentage": 12.5
  }
}
```

## Troubleshooting

### Status line not showing

1. Check `jq` is installed: `which jq`
2. Verify script is executable: `ls -la ~/.claude/statusline.sh`
3. Check settings.json syntax: `cat ~/.claude/settings.json | jq .`

### Session name not appearing

The name shows after your first message following `/rename`. If it's still not showing:

```bash
# Check if the script can find your session
~/.claude/statusline.sh < /tmp/statusline-debug.json
```

## License

MIT
