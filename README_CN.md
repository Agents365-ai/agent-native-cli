# agent-native-cli — AI 智能体原生 CLI 设计与评审 Skill

[English](README.md)

## 功能说明

- 评估现有 CLI 是否能被 AI 智能体可靠使用
- 设计同时服务人类、智能体和编排系统的 CLI 接口
- 将 REST API 和 SDK 转换为智能体原生的 CLI 命令树
- 审查 stdout 契约、退出码语义和错误信封设计
- 设计基于 Schema 的自描述能力、dry-run 预览和 Schema 自省
- 定义安全分级（开放 / 警示 / 隐藏），实现命令可见性的渐进式控制
- 设计委托式认证，使智能体永远不拥有认证生命周期
- 生成带有具体接口示例的优先级重构计划

## 多平台支持

核心 `SKILL.md` 具备可移植性，并为下列平台提供元数据：

| 平台 | 支持状态 | 说明 |
|------|----------|------|
| **Claude Code** | ✅ 完全支持 | 原生 SKILL.md 格式 |
| **OpenClaw / ClawHub** | ✅ 完全支持 | `metadata.openclaw` 命名空间 |
| **Hermes Agent** | ✅ 完全支持 | `metadata.hermes` 命名空间，category: engineering |
| **[pi-mono](https://github.com/badlogic/pi-mono)** | ✅ 完全支持 | `metadata.pimo` 命名空间 |
| **OpenAI Codex** | ✅ 完全支持 | `agents/openai.yaml` 侧车文件 |
| **SkillsMP** | ✅ 可索引 | GitHub topics 已配置 |

## 有 skill 与无 skill 的对比

| 能力 | 原生智能体 | 本 skill |
|------|-----------|---------|
| 评估 CLI 是否具备智能体原生特性 | 否 | 是 — 基于 7 项原则的结构化诊断 |
| 设计 stdout JSON 契约 | 不稳定 | 始终 — 带 `ok`、`data`、`error` 的稳定信封 |
| 定义退出码语义 | 临时性 | 是 — 按故障类型文档化、确定性映射 |
| 设计分层 `--help` 和 Schema 自省 | 否 | 是 — 完整自描述模式 |
| 设计 dry-run 预览 | 少见 | 始终 — 不执行操作即可预览请求形态 |
| 定义命令安全分级 | 否 | 是 — 开放 / 警示 / 隐藏三级分层 |
| 设计委托式认证 | 否 | 是 — 人类管理认证生命周期；智能体使用 token |
| 区分环境变量与 CLI 参数的信任级别 | 否 | 是 — 定向信任模型 |
| 生成优先级重构计划 | 少见 | 始终 — P0 / P1 / P2，含示例 |
| 按 10 项标准对 CLI 评分 | 否 | 是 — 每项 0–2 分，含最终判定 |

## 适用场景

- 评估现有 CLI 是否可被 AI 智能体使用
- 为 API 或 SDK 设计新的 CLI 接口
- 将以人为本的 CLI 重构为机器可读的接口
- 审查 stdout、stderr 和退出码契约设计
- 定义 dry-run、Schema 自省和自描述层
- 为智能体安全设计委托式认证和信任边界
- 从 CLI Schema 生成 SKILL.md 或 skill 文档

## skill 安装

### Claude Code

```bash
# 全局安装（在所有项目中可用）
git clone https://github.com/Agents365-ai/agent-native-cli.git ~/.claude/skills/agent-native-cli

# 项目级安装
git clone https://github.com/Agents365-ai/agent-native-cli.git .claude/skills/agent-native-cli
```

### OpenClaw / ClawHub

```bash
# 通过 ClawHub
clawhub install agent-native-cli

# 手动安装
git clone https://github.com/Agents365-ai/agent-native-cli.git ~/.openclaw/skills/agent-native-cli

# 项目级安装
git clone https://github.com/Agents365-ai/agent-native-cli.git skills/agent-native-cli
```

### Hermes Agent

```bash
git clone https://github.com/Agents365-ai/agent-native-cli.git ~/.hermes/skills/engineering/agent-native-cli
```

或在 `~/.hermes/config.yaml` 中添加：

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
# 用户级安装（默认 CODEX_HOME）
git clone https://github.com/Agents365-ai/agent-native-cli.git ~/.codex/skills/agent-native-cli

# 项目级安装
git clone https://github.com/Agents365-ai/agent-native-cli.git .codex/skills/agent-native-cli
```

### SkillsMP

```bash
skills install agent-native-cli
```

### 安装路径汇总

| 平台 | 全局路径 | 项目路径 |
|------|----------|----------|
| Claude Code | `~/.claude/skills/agent-native-cli/` | `.claude/skills/agent-native-cli/` |
| OpenClaw | `~/.openclaw/skills/agent-native-cli/` | `skills/agent-native-cli/` |
| Hermes Agent | `~/.hermes/skills/engineering/agent-native-cli/` | 通过 `external_dirs` 配置 |
| pi-mono | `~/.pimo/skills/agent-native-cli/` | — |
| OpenAI Codex | `~/.codex/skills/agent-native-cli/` | `.codex/skills/agent-native-cli/` |

## 文件说明

- `SKILL.md` — skill 的核心指令文件，是跨平台的主要内容。
- `agents/openai.yaml` — OpenAI Codex 专用配置（显示名称、策略、能力列表）
- `README.md` — 英文文档
- `README_CN.md` — 本文件（中文）

> **注意：** `SKILL.md` 是可移植核心。一些平台（包括 OpenAI Codex）还可以读取 `agents/openai.yaml` 这类侧车元数据。

## GitHub Topics

用于 SkillsMP 索引，本仓库使用以下 topics：

`claude-code` `claude-code-skill` `claude-skills` `agent-skills` `skillsmp` `skill-md` `agent-native-cli` `cli-design` `interface-design` `structured-output` `schema-driven` `dry-run` `exit-codes` `tool-design`

## 开源协议

MIT

## 支持作者

如果这个 skill 对你的工作有帮助，欢迎支持作者：

<table>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/Agents365-ai/images_payment/main/qrcode/wechat-pay.png" width="180" alt="微信支付">
      <br>
      <b>微信支付</b>
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/Agents365-ai/images_payment/main/qrcode/alipay.png" width="180" alt="支付宝">
      <br>
      <b>支付宝</b>
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/Agents365-ai/images_payment/main/qrcode/buymeacoffee.png" width="180" alt="Buy Me a Coffee">
      <br>
      <b>Buy Me a Coffee</b>
    </td>
  </tr>
</table>

## 作者

**Agents365-ai**

- Bilibili: https://space.bilibili.com/441831884
- GitHub: https://github.com/Agents365-ai
