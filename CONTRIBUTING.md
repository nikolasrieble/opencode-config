# Contributing

Before pushing changes to this shared config, evaluate them against the criteria below. The goal is to keep the global config lean, correct, and token-efficient.

---

## Getting Started

If this is your first time working with the shared config:

1. **Clone and install:** Follow the README to symlink `opencode.json` → `~/.config/opencode/opencode.json` and copy `agents/` → `~/.config/opencode/agents/`.
2. **Measure the baseline:** Run `./script/baseline.sh` from the repo root. Note the token count — this is your "before" number.
3. **Make your change** in a branch.
4. **Run `./script/baseline.sh` again.** If the baseline increased, your change added to the default session context. Investigate before pushing.
5. **Open a PR** with both baseline numbers in the description.

### What belongs here vs. in a project config

| Belongs in global config | Belongs in project `opencode.json` |
|---|---|
| Model selection (`model`, `small_model`) | Project-specific MCP servers |
| Global tool disablement (`"atlassian_*": false`) | Project-specific tool overrides |
| Compaction settings | Project-specific instructions |
| Shared agents (jira, docs, security) | Team-specific agents |
| Theme, TUI preferences | Repo-specific build commands |

When in doubt, put it in the project config. Global changes affect every engineer on every repo.

---

## Baseline Token Measurement

Every new session pays a fixed cost before the user's message is processed: the system prompt plus all tool definitions. This is the **baseline**.

`./script/baseline.sh` measures it by sending a minimal message (`"hi"`) and reading the token count from the first `step_finish` event. It prints a single number: `input + cache_read`.

**Current baseline (v1.1.56):** ~11,369 tokens.

The baseline is determined by the OpenCode version, not by our config. Custom agents, disabled MCP tools, and config values like model/compaction/theme do not contribute to it. A stable number confirms our config stays out of the way. If it increases after a config change, something is leaking into the default context — e.g., globally enabled tools.

**Updating the baseline:** When the OpenCode version changes and the baseline shifts, update the number above. Include the measurement in your PR description.

---

## Evaluation Tools

OpenCode ships several CLI tools useful for manual evaluation:

| Tool | Purpose |
|------|---------|
| `opencode export <sessionID>` | Dump a full session as JSON (messages, tokens, tool calls) |
| `opencode session list --format json -n 5` | List recent sessions with IDs |
| `opencode stats --days 7 --models 10` | Aggregate token/cost/tool usage stats |
| `opencode mcp list` | Show MCP server status and enabled state |
| `opencode agent list` | List all registered agents |

---

## Adding an Agent

When adding a new agent to `agents/`, evaluate:

1. **Does it need MCP tools?** If yes, enable only the specific tools it needs via frontmatter (`tools: { some_*: true }`). Never enable tools globally for one agent's benefit.
2. **How large is the prompt?** Keep agent prompts concise. Every token in the prompt is sent on every turn when that agent is active.
3. **Does it overlap with an existing agent?** Prefer extending an existing agent over creating a new one with similar scope.
4. **Test the token impact:** Switch to the new agent, send a minimal message, and compare `tokens.input` against the baseline. The delta is the agent's cost per turn.
5. **Test delegation:** From the default `build` agent, verify `@<your-agent>` can be invoked via the Task tool and that results are relayed correctly.
6. **Update the agent table below** with the agent's expected behavior and MCP tool requirements.

### Agent prompt checklist

- [ ] Frontmatter includes `tools:` only if MCP tools are needed
- [ ] Prompt clearly states the agent's scope and constraints
- [ ] Prompt does not duplicate instructions already in the system prompt
- [ ] Token delta documented in PR description (e.g., "Adds ~800 tokens when @myagent is active")

### Agent behavior reference

| Agent | Expected behavior | MCP tools |
|-------|-------------------|-----------|
| `build` (default) | General coding assistance | None (Atlassian disabled) |
| `@jira` | Jira ticket management, asks for project key | `atlassian_*: true` |
| `@docs` | Confluence search, cites sources with links | `atlassian_*: true` |
| `@security` | OWASP-focused review, severity ratings, provides fixes | None |

---

## Breaking Changes

Some changes can disrupt every engineer using this config. Take extra care with:

| Change type | Risk | Mitigation |
|---|---|---|
| Removing an agent | Engineers may reference it in workflows | Deprecate first: add a note to the agent prompt, then remove after a cycle |
| Changing `model` or `small_model` | Different behavior, cost, capability | Test thoroughly; announce in team channel |
| Enabling tools globally | Inflates baseline for everyone | Almost always wrong — use per-agent frontmatter instead |
| Changing compaction settings | Affects long session behavior | Test with a long session before pushing |
| Renaming an agent file | Breaks `@agent` references | Treat as remove + add; coordinate with team |
