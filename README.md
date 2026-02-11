# OpenCode Company Configuration

Recommended OpenCode configuration for all engineers.

## Why?

[OpenCode](https://opencode.ai/docs) is a provider-agnostic agent harness. When a new model comes out, you just switch providers - no need to change your tooling, workflows, or muscle memory.

## Strong Opinions

- **Sharing is caring** - A global config shared across all teams and projects, with agents that encapsulate tool usage.
- **Do not pollute the context** - Every token counts. We disable tools by default and keep instructions/rules/commands out of the global config.
- **Agents over skills** - Skills are [unreliable](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals) (56% never invoked) and bloat context when they do load. Agents enable only the tools they need, nothing more.
- **Best model by default, cheapest as fallback** - `claude-opus-4-6` for quality code with fewer iterations. `gpt-5-mini` (currently free via GitHub Copilot) for mundane tasks like title generation.

### What This Repo Is Not

This is **not** a place for team-specific or project-specific configuration. Those belong in each project's `opencode.json` and `AGENTS.md`, following the same architecture.

**Caveat:** In a local project, rules and instructions that "pollute" context are actually a feature - they provide project-specific guidance that improves code quality. The global config avoids them because no single set of rules applies everywhere.

## Installation

### Option 1: Symlink (Recommended for contributors)

If you want changes to the repo reflected immediately:

```bash
# Clone the repo (replace with your fork URL if applicable)
git clone <repo-url> ~/code/opencode-company-config

# Backup existing config (if any)
cp ~/.config/opencode/opencode.json ~/.config/opencode/opencode.json.bak 2>/dev/null

# Symlink agents folder
mkdir -p ~/.config/opencode
rm -rf ~/.config/opencode/agents
ln -s ~/code/opencode-company-config/agents ~/.config/opencode/agents

# Symlink the main config (or cp if you want a local copy to customize)
ln -sf ~/code/opencode-company-config/opencode.json ~/.config/opencode/opencode.json
```

### Option 2: Copy (Simple install)

```bash
# Clone the repo
git clone <repo-url>
cd opencode-company-config

# Copy everything
mkdir -p ~/.config/opencode/agents
cp opencode.json ~/.config/opencode/
cp agents/*.md ~/.config/opencode/agents/
```

### Option 3: Direct download

```bash
mkdir -p ~/.config/opencode/agents

# Set your repo's raw URL base (adjust org/repo as needed)
RAW_BASE="https://raw.githubusercontent.com/<owner>/opencode-company-config/main"

# Download config
curl -o ~/.config/opencode/opencode.json "$RAW_BASE/opencode.json"

# Download agents
curl -o ~/.config/opencode/agents/jira.md "$RAW_BASE/agents/jira.md"
curl -o ~/.config/opencode/agents/docs.md "$RAW_BASE/agents/docs.md"
curl -o ~/.config/opencode/agents/security.md "$RAW_BASE/agents/security.md"
```

## Verify Installation

```bash
# Check config exists
cat ~/.config/opencode/opencode.json

# Check agents are available
ls -la ~/.config/opencode/agents/
```

Restart OpenCode to pick up the changes.

## Authenticate MCP Servers

After installation, authenticate with the Atlassian MCP server:

```bash
opencode mcp auth atlassian
```

This opens a browser for OAuth authentication. Verify with `opencode mcp list` - you should see `✓ atlassian connected`.

## Using Agents

There are two ways to use agents:

**1. Start a session with an agent**

Type `@` followed by the agent name to switch to that agent:

```
@jira
```

All subsequent messages will be handled by this agent until you switch back.

**2. Tag an agent in a message (subagent)**

Mention an agent inline to delegate a specific task:

```
Can you @security review this authentication code?
```

The main agent will invoke the security agent as a subagent, then continue the conversation.

### Atlassian Tools

Atlassian tools are **disabled by default** to save context. The included agents (`jira`, `docs`) automatically enable the tools they need.

To use Atlassian tools directly (without an agent), enable them in your project's `opencode.json`:

```jsonc
{
  "tools": {
    "atlassian_*": true
  }
}
```

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
  "instructions": ["CONTRIBUTING.md"]
}
```

## Updating

If you used the symlink approach:

```bash
cd ~/code/opencode-company-config
git pull
```

If you copied the files, re-run the copy commands after pulling.

---

## Appendix: Why Agents Over Skills

OpenCode supports [Agent Skills](https://opencode.ai/docs/skills/) for on-demand prompt injection. However, **we do not recommend using skills** for company-wide configuration.

### The Problem with Skills

Vercel's engineering team ran rigorous evals comparing skills vs. static context (AGENTS.md). The results were striking:

| Approach | Pass Rate |
|----------|-----------|
| Baseline (no docs) | 53% |
| Skills (default) | 53% |
| Skills (with explicit instructions) | 79% |
| **AGENTS.md (static context)** | **100%** |

Key findings:
- **56% of cases**: Skills were never invoked - the agent didn't decide to use them
- **Fragile behavior**: Small wording changes in "use this skill" instructions caused large outcome swings
- **No improvement over baseline**: Default skill behavior performed identically to having no documentation

### Why Static Context Wins

1. **No decision point** - The agent doesn't have to decide "should I load this?"
2. **Consistent availability** - Context is present every turn, not loaded on-demand
3. **No ordering issues** - No "read docs first vs explore project first" sequencing problems

Read the full research: [AGENTS.md outperforms skills in our agent evals](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals)

## Appendix: Agents vs Commands

Both agents and commands extend OpenCode, but serve different purposes:

| | Agents | Commands |
|-|--------|----------|
| **Purpose** | Define *who* responds (role, persona) | Define *what* to do (task template) |
| **Invocation** | `@agent` or Tab to switch | `/command` |
| **Tool access** | Can enable/disable specific tools | Inherits from current agent |
| **Conversation** | Multi-turn, persistent context | One-shot execution |
| **Dynamic input** | No templating | `$ARGUMENTS`, `` !`shell` ``, `@file` |

### Use Agents when:
- You need **different tool access** (e.g., Atlassian MCP for jira/docs agents)
- You need a **persistent persona** for multi-turn conversations
- Other agents should invoke it via the **Task tool**

### Use Commands when:
- You have a **repeatable task** with consistent structure
- You need to **inject dynamic content** (arguments, shell output, files)
- The task is **one-shot** and doesn't need follow-up in a special context
