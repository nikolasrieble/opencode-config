# OpenCode Company Configuration

Recommended OpenCode configuration for all engineers.

## Installation

### Option 1: Symlink (Recommended for contributors)

If you want changes to the repo reflected immediately:

```bash
# Clone the repo
git clone https://github.com/<org>/opencode-company-config.git ~/code/opencode-company-config

# Backup existing config (if any)
cp ~/.config/opencode/opencode.json ~/.config/opencode/opencode.json.bak 2>/dev/null

# Symlink agents folder
mkdir -p ~/.config/opencode
rm -rf ~/.config/opencode/agents
ln -s ~/code/opencode-company-config/agents ~/.config/opencode/agents

# Copy the main config (or symlink if you want full sync)
cp ~/code/opencode-company-config/opencode.json ~/.config/opencode/opencode.json
```

### Option 2: Copy (Simple install)

```bash
# Clone the repo
git clone https://github.com/<org>/opencode-company-config.git
cd opencode-company-config

# Copy everything
mkdir -p ~/.config/opencode/agents
cp opencode.json ~/.config/opencode/
cp agents/*.md ~/.config/opencode/agents/
```

### Option 3: Direct download

```bash
mkdir -p ~/.config/opencode/agents

# Download config
curl -o ~/.config/opencode/opencode.json \
  https://raw.githubusercontent.com/<org>/opencode-company-config/main/opencode.json

# Download agents
curl -o ~/.config/opencode/agents/jira.md \
  https://raw.githubusercontent.com/<org>/opencode-company-config/main/agents/jira.md
curl -o ~/.config/opencode/agents/docs.md \
  https://raw.githubusercontent.com/<org>/opencode-company-config/main/agents/docs.md
curl -o ~/.config/opencode/agents/security.md \
  https://raw.githubusercontent.com/<org>/opencode-company-config/main/agents/security.md
```

## Verify Installation

```bash
# Check config exists
cat ~/.config/opencode/opencode.json

# Check agents are available
ls -la ~/.config/opencode/agents/
```

Restart OpenCode to pick up the changes.

## Repository Structure

```
opencode-company-config/
├── opencode.json       # Main config → ~/.config/opencode/opencode.json
├── agents/             # Agent definitions → ~/.config/opencode/agents/
│   ├── jira.md         #   /jira - Manage Jira tickets
│   ├── docs.md         #   /docs - Search company documentation
│   └── security.md     #   /security - Security review
└── README.md
```

## What's Included

### Models

| Setting | Model | Cost |
|---------|-------|------|
| Main | `github-copilot/claude-opus-4-6` | 3x multiplier |
| Small | `github-copilot/gpt-5-mini` | Free (0x) |

### Agents

| Command | Description | MCP Required |
|---------|-------------|--------------|
| `/jira` | Manage Jira tickets and issues | `jira` |
| `/docs` | Search and explain company documentation | `confluence` |
| `/security` | Security review and best practices | None |

### MCP Servers

MCPs are **disabled by default** to save context. Enable them in your project's `opencode.json`:

```jsonc
{
  "mcp": {
    "jira": { "enabled": true }
  }
}
```

| MCP | Purpose |
|-----|---------|
| `jira` | Jira ticket management |
| `confluence` | Company documentation |

## Customization

### Personal Preferences

Edit `~/.config/opencode/opencode.json` to customize:

- `theme` - Change to your preferred theme (`/theme` to see options)
- `keybinds` - Add custom keybindings
- `autoupdate` - Enable/disable auto-updates

### Adding Your Own Agents

Create a new file in `~/.config/opencode/agents/` (or in this repo if symlinked):

```markdown
---
description: My custom agent
tools:
  some_mcp_*: true
---

Your agent prompt here...
```

## Project-Level Config

For team/project-specific settings, add to your project root:

```
your-project/
├── opencode.json           # Project config (overrides global)
└── .opencode/
    └── agents/
        └── my-project-agent.md
```

Example project `opencode.json`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "jira": { "enabled": true }
  }
}
```

## Updating

If you used the symlink approach:

```bash
cd ~/code/opencode-company-config
git pull
```

If you copied the files, re-run the copy commands after pulling.
