# agent-native-cli — Agent-Native CLI Design & Review Skill

[中文文档](README_CN.md)

## What it does

- Evaluates whether an existing CLI is reliably usable by AI agents
- Designs CLI interfaces that serve humans, agents, and orchestration systems simultaneously
- Converts REST APIs and SDKs into agent-native CLI command trees
- Reviews stdout contracts, exit code semantics, and error envelope design
- Designs schema-driven self-description, dry-run previews, and schema introspection
- Defines safety tiers (open / warned / hidden) for graduated command visibility
- Designs delegated authentication so agents never own the auth lifecycle
- Produces prioritized refactor plans with concrete interface examples

## Multi-Platform Support

The core `SKILL.md` is portable, and this repository includes metadata for the platforms listed below:

| Platform | Status | Details |
|----------|--------|---------|
| **Claude Code** | ✅ Full support | Native SKILL.md format |
| **OpenClaw / ClawHub** | ✅ Full support | `metadata.openclaw` namespace |
| **Hermes Agent** | ✅ Full support | `metadata.hermes` namespace, category: engineering |
| **[pi-mono](https://github.com/badlogic/pi-mono)** | ✅ Full support | `metadata.pimo` namespace |
| **OpenAI Codex** | ✅ Full support | `agents/openai.yaml` sidecar |
| **SkillsMP** | ✅ Indexed | GitHub topics configured |

## Comparison: with vs. without this skill

| Capability | Native agent | This skill |
|------------|-------------|------------|
| Evaluate whether a CLI is agent-native | No | Yes — structured diagnosis across 7 principles |
| Design stdout JSON contract | Inconsistent | Always — stable envelope with `ok`, `data`, `error` |
| Define exit code semantics | Ad hoc | Yes — documented, deterministic per failure class |
| Design layered `--help` and schema introspection | No | Yes — full self-description pattern |
| Design dry-run previews | Rarely | Always — request shape preview without execution |
| Define safety tiers for commands | No | Yes — open / warned / hidden tiers |
| Design delegated authentication | No | Yes — human manages auth lifecycle; agent uses token |
| Separate trust levels for env vs. CLI args | No | Yes — directional trust model |
| Produce prioritized refactor plan | Rarely | Always — P0 / P1 / P2 with examples |
| Score CLI across 10-criterion rubric | No | Yes — 0–2 per criterion with verdict |

## When to use

- Evaluating whether an existing CLI is usable by an AI agent
- Designing a new CLI interface for an API or SDK
- Refactoring a human-first CLI to be machine-readable
- Reviewing stdout, stderr, and exit code contract design
- Defining dry-run, schema introspection, and self-description layers
- Designing auth delegation and trust boundaries for agent safety
- Producing a SKILL.md or skill docs from a CLI schema

## Skill Installation

### Claude Code

```bash
# Global install (available in all projects)
git clone https://github.com/Agents365-ai/agent-native-cli.git ~/.claude/skills/agent-native-cli

# Project-level install
git clone https://github.com/Agents365-ai/agent-native-cli.git .claude/skills/agent-native-cli
```

### OpenClaw / ClawHub

```bash
# Via ClawHub
clawhub install agent-native-cli

# Manual install
git clone https://github.com/Agents365-ai/agent-native-cli.git ~/.openclaw/skills/agent-native-cli

# Project-level install
git clone https://github.com/Agents365-ai/agent-native-cli.git skills/agent-native-cli
```

### Hermes Agent

```bash
git clone https://github.com/Agents365-ai/agent-native-cli.git ~/.hermes/skills/engineering/agent-native-cli
```

Or add to `~/.hermes/config.yaml`:

```yaml
skills:
  external_dirs:
    - ~/myskills/agent-native-cli
```

### pi-mono

```bash
git clone https://github.com/Agents365-ai/agent-native-cli.git ~/.pimo/skills/agent-native-cli
```

### OpenAI Codex

```bash
# User-level install (default CODEX_HOME)
git clone https://github.com/Agents365-ai/agent-native-cli.git ~/.codex/skills/agent-native-cli

# Project-level install
git clone https://github.com/Agents365-ai/agent-native-cli.git .codex/skills/agent-native-cli
```

### SkillsMP

```bash
skills install agent-native-cli
```

### Installation paths summary

| Platform | Global path | Project path |
|----------|-------------|--------------|
| Claude Code | `~/.claude/skills/agent-native-cli/` | `.claude/skills/agent-native-cli/` |
| OpenClaw | `~/.openclaw/skills/agent-native-cli/` | `skills/agent-native-cli/` |
| Hermes Agent | `~/.hermes/skills/engineering/agent-native-cli/` | Via `external_dirs` config |
| pi-mono | `~/.pimo/skills/agent-native-cli/` | — |
| OpenAI Codex | `~/.codex/skills/agent-native-cli/` | `.codex/skills/agent-native-cli/` |

## Files

- `SKILL.md` — the core skill instructions. This is the primary file across platforms.
- `agents/openai.yaml` — OpenAI Codex-specific configuration (display, policy, capabilities)
- `README.md` — this file (English)
- `README_CN.md` — Chinese documentation

> **Note:** `SKILL.md` is the portable core. Some platforms, including OpenAI Codex, can also use sidecar metadata such as `agents/openai.yaml`.

## GitHub Topics

For SkillsMP indexing, this repository uses the following topics:

`claude-code` `claude-code-skill` `claude-skills` `agent-skills` `skillsmp` `skill-md` `agent-native-cli` `cli-design` `interface-design` `structured-output` `schema-driven` `dry-run` `exit-codes` `tool-design`

## License

MIT

## Support

If this skill helps your work, consider supporting the author:

<table>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/Agents365-ai/images_payment/main/qrcode/wechat-pay.png" width="180" alt="WeChat Pay">
      <br>
      <b>WeChat Pay</b>
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/Agents365-ai/images_payment/main/qrcode/alipay.png" width="180" alt="Alipay">
      <br>
      <b>Alipay</b>
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/Agents365-ai/images_payment/main/qrcode/buymeacoffee.png" width="180" alt="Buy Me a Coffee">
      <br>
      <b>Buy Me a Coffee</b>
    </td>
  </tr>
</table>

## Author

**Agents365-ai**

- Bilibili: https://space.bilibili.com/441831884
- GitHub: https://github.com/Agents365-ai
