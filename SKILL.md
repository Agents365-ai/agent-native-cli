---
name: agent-native-cli
description: Use when designing, reviewing, or refactoring a CLI to reliably serve AI agents alongside humans — including evaluating stdout contracts, schema introspection, dry-run, exit codes, auth delegation, safety tiers, and self-description. Use when converting an API or SDK into an agent-usable CLI interface.
license: MIT
homepage: https://github.com/Agents365-ai/agent-native-cli
compatibility: No external tool dependencies. Includes sidecar metadata for OpenClaw, Hermes, pi-mono, and OpenAI Codex; the core SKILL.md is portable to agents that support Agent Skills-style instructions.
platforms: [macos, linux, windows]
metadata: {"openclaw":{"requires":{},"emoji":"⌨️","os":["darwin","linux","win32"]},"hermes":{"tags":["cli","agent-native","interface-design","tool-design","structured-output","schema-driven","exit-codes","dry-run"],"category":"engineering","requires_tools":[],"related_skills":[]},"pimo":{"category":"engineering","tags":["cli","agent-native","interface-design","structured-output","schema-driven"]},"author":"Agents365-ai","version":"1.0.0"}
---

# agent-native-cli

## Purpose

This skill helps analyze, design, and refactor command-line tools so they can reliably serve **humans**, **AI agents**, and **orchestration systems** at the same time.

It is not a skill for merely *using* a CLI.
It is a skill for designing and reviewing a CLI as an **agent-native interface**.

The skill focuses on four goals:

1. Make CLI behavior predictable for AI agents.
2. Make CLI output readable and recoverable for humans.
3. Make CLI execution manageable for systems and orchestrators.
4. Define a complete interaction loop from authentication to error routing.

---

## When to use this skill

Use this skill when the user wants to:

* evaluate whether an existing CLI is agent-friendly
* redesign a CLI to better support AI agents
* convert an API or SDK into an agent-native CLI
* review help output, schema design, exit codes, or JSON contracts
* design dry-run, auth delegation, or safety boundaries
* generate CLI skills, docs, or interface conventions from schema
* refactor a human-oriented CLI into a machine-friendly one
* define how a CLI should interact with an agent runtime

Typical prompts include:

* "Review this CLI and tell me whether it is agent-native."
* "Design a CLI for this API that an AI agent can use reliably."
* "Refactor this tool so stdout is machine-readable and safer for agents."
* "Help me define schema introspection, dry-run, and exit code semantics."
* "Turn these design principles into a practical CLI contract."

---

## When not to use this skill

Do not use this skill when the user only wants:

* help running a specific command
* installation help for a CLI
* shell troubleshooting unrelated to interface design
* generic Linux or terminal tutorials
* agent planning or memory design unrelated to tools
* API business logic review without any CLI/tooling layer

---

## Core model

An agent-native CLI must simultaneously serve three audiences.

### 1. Human

Needs: readable output, friendly error messages, onboarding guidance

Channels: `stderr`, optional `--format table`, interactive TUI when appropriate

### 2. AI Agent

Needs: structured data, stable contracts, self-description

Channels: `stdout` as JSON, stable exit codes, schema introspection, dry-run previews, generated skills/docs

### 3. System / Orchestrator

Needs: delegated authentication, process management, deterministic error routing

Channels: environment variables, exit codes, dry-run mode, stable command semantics

### Foundational contract

| Channel | Primary audience |
|---------|-----------------|
| `stdout` | Machines and agents |
| `stderr` | Humans |
| `exit codes` | Systems and orchestrators |

---

## The complete interaction loop

| Phase | Step | Description |
|-------|------|-------------|
| 0. Bootstrap | 1 | Human/system obtains auth token or credentials |
| 0. Bootstrap | 2 | Set trusted env vars: token, profile, safety mode |
| 1. Discovery | 3 | Agent loads skills or command summaries |
| 1. Discovery | 4 | Agent queries schema/help for parameters |
| 2. Planning | 5 | Agent uses `--dry-run` to preview request shape |
| 3. Execution | 6 | Agent executes with validated inputs |
| 4. Interpretation | 7 | Agent parses structured result |
| 5. Recovery | 8 | Agent uses exit code + error object to retry, re-auth, repair, or escalate |

---

## Seven principles

### Principle 0. One CLI, Three Audiences

The CLI must serve human, agent, and system simultaneously. A design that serves only one audience is incomplete.

### Principle 1. Structured Output Is the Interface

`stdout` should always be parseable and stable. Both success and failure are structured JSON.

```json
{ "ok": true, "data": { "id": "abc123", "name": "report.csv" } }
```

```json
{
  "ok": false,
  "error": {
    "code": "not_found",
    "message": "File not found",
    "retryable": false
  }
}
```

### Principle 2. Trust Is Directional

CLI arguments are not inherently trusted — they may come from a hallucinating or prompt-injected agent. Environment-level configuration set by the human or system is more trusted. The agent chooses *what to do* within a bounded surface; the human defines *where and how it is allowed to operate*.

### Principle 3. The CLI Must Describe Itself

The CLI must be self-describing enough that an agent can use it without reading external README files.

```bash
tool --help                          # top-level overview
tool resource --help                 # resource-level
tool resource action --help          # action-level
tool schema resource.action          # full parameter schema
tool resource action --dry-run --params '{}'  # preview without execution
```

### Principle 4. Safety Through Graduated Visibility

| Tier | Commands | Exposure |
|------|----------|----------|
| preview | all commands | dry-run available everywhere |
| open | list / get / search | full docs, easy to discover |
| warned | create / update / send | explicit warning in help and skills |
| hidden | delete / purge / empty | excluded from skills, gated separately |

### Principle 5. Validate at the Boundary, Not in the Middle

Inputs are validated once at the CLI entry point. Internal code operates on validated, typed, trusted structures. Validation functions are centralized and tested for both pass and reject cases.

### Principle 6. The Schema Is the Source of Truth

If a schema exists, everything derives from it: CLI command structure, validation rules, help text, generated docs, generated skills, type definitions, dry-run contracts. The schema is never manually duplicated.

### Principle 7. Authentication Must Be Delegatable

Authentication is obtained and refreshed by human/system-managed flows. The agent uses credentials; it never owns the auth lifecycle.

Preferred mechanisms: environment variables, config files, OS keychain integration, externally refreshed tokens.

---

## Standard review workflow

### Step 1. Classify the input

Decide whether the user is providing: an existing CLI, an API to be wrapped, a conceptual design, a partial interface, or a failure case.

### Step 2. Map the three audiences

**Human:** Is there readable output? Are errors understandable? Is onboarding supported?

**Agent:** Is stdout stable JSON? Can the CLI describe itself? Is there schema introspection and dry-run?

**System:** Is auth delegatable? Are exit codes stable? Can failures be routed deterministically?

### Step 3. Review the interaction loop

Check whether the CLI supports: bootstrap, discovery, parameter understanding, preview, execution, parsing, recovery.

### Step 4. Score the CLI with the rubric, then map back to principles

Use the 10-criterion rubric to score the CLI. Then summarize how those results map to the seven principles with evidence, risk, and recommendation.

### Step 5. Produce a refactor plan

- **P0** must fix
- **P1** should improve
- **P2** long-term enhancements

---

## Default output format

### 1. Overall verdict

State whether the CLI is: **agent-native** / **partially agent-native** / **not yet agent-native**

### 2. Three-audience contract review

Assess support for human, agent, system.

### 3. Interaction loop coverage

Assess each phase: auth bootstrap → env setup → skill/help discovery → schema introspection → dry-run → execution → parsing and recovery.

### 4. Rubric score + seven-principle review

Report the 10-criterion rubric score first, then summarize the seven principles as: status · evidence · issue · recommendation.

### 5. Key risks

Summarize design failures: human-only output, unstable JSON, no schema introspection, destructive commands overexposed, auth coupled to agent, ambiguous exit codes.

### 6. Refactor plan

Prioritized recommendations with examples.

---

## Examples

### Example 1 — Good: structured error with routing fields

```json
{
  "ok": false,
  "error": {
    "code": "auth_expired",
    "message": "Token expired. Re-authenticate to continue.",
    "retryable": true,
    "retry_after_auth": true
  }
}
```

The agent can read `retry_after_auth: true` and escalate to re-authentication without parsing prose.

### Example 2 — Good: layered self-description

```bash
$ healthkit --help
Usage: healthkit <resource> <action> [options]

Resources:
  sleep       Sleep records and stages
  steps       Step count and activity
  heart       Heart rate and HRV

$ healthkit sleep --help
Actions:
  list        List sleep records by date range
  summary     Aggregate sleep statistics

$ healthkit sleep list --help
Flags:
  --start-date  ISO date (required)
  --end-date    ISO date (required)
  --format      json|table (default: json)
  --dry-run     Preview request, do not execute
```

An agent can traverse this tree to discover valid commands without reading external docs.

### Example 3 — Good: delegated auth with env trust boundary

```bash
# Human runs once:
healthkit auth login        # browser OAuth2 flow, stores token in keychain

# Agent uses always:
HEALTHKIT_TOKEN=$(healthkit auth token) healthkit sleep list --start-date 2026-01-01 --end-date 2026-01-07
```

The agent never touches the browser flow. The human-set token is the trust boundary.

### Example 4 — Good: dry-run preview before execution

```bash
$ healthkit sleep list --start-date 2026-01-01 --end-date 2026-01-07 --dry-run
{
  "ok": true,
  "dry_run": true,
  "would_request": {
    "method": "GET",
    "url": "https://health.api/v1/sleep",
    "params": { "startDate": "2026-01-01", "endDate": "2026-01-07" }
  }
}
```

The agent can verify the request shape before committing to execution.

### Example 5 — Good: schema introspection

```bash
$ healthkit schema sleep.list
{
  "method": "sleep.list",
  "params": {
    "startDate": { "type": "string", "format": "date", "required": true },
    "endDate":   { "type": "string", "format": "date", "required": true },
    "pageSize":  { "type": "integer", "default": 20, "max": 100 }
  }
}
```

---

## Non-Examples

### Non-Example 1 — Bad: prose-only error

```
Error: something went wrong with your request. Please check your input and try again.
```

The agent cannot determine: what went wrong, whether to retry, what to fix, which field failed. It must guess or give up.

### Non-Example 2 — Bad: mixed stdout

```
Fetching sleep records...
Found 7 records.
{"records": [...]}
Done.
```

The agent cannot reliably parse JSON because stdout contains prose mixed with data.

### Non-Example 3 — Bad: no self-description

```bash
$ mytool --help
Usage: mytool [OPTIONS] COMMAND [ARGS]...

Options:
  --help  Show this message and exit.
```

No resources, no actions, no schema. An agent must guess or hallucinate command names.

### Non-Example 4 — Bad: auth via agent-supplied argument

```bash
mytool --token $AGENT_GENERATED_TOKEN delete --id abc123
```

The agent controls the token. A compromised agent can use any token it manufactures, bypassing human trust boundaries.

### Non-Example 5 — Bad: destructive commands fully exposed

```bash
$ mytool --help
Commands:
  list    List records
  get     Get a record
  delete  Delete a record        ← appears at same level as read commands
  purge   Purge all records      ← no warning, no gate
```

An agent browsing help can trivially discover and invoke destructive commands.

### Non-Example 6 — Bad: ambiguous exit codes

```bash
$ mytool list; echo $?
# Returns 1 on API error
# Returns 1 on validation error
# Returns 1 on auth error
# Returns 1 on network error
```

Exit code 1 means everything. The orchestrator cannot route failures deterministically.

---

## Output rubric

Use this rubric when scoring a CLI review. Each criterion is scored 0–2.

| Criterion | 0 — Fail | 1 — Partial | 2 — Pass |
|-----------|----------|-------------|----------|
| **Stdout contract** | Prose or mixed output | JSON sometimes, not always | Always parseable JSON with stable envelope |
| **Stderr separation** | Diagnostics mixed into stdout | Some separation | Diagnostics always on stderr |
| **Exit code semantics** | All errors map to same code | Some codes defined | Documented, stable, distinct codes per failure class |
| **Self-description (help)** | No `--help` or single flat page | Layered help exists but incomplete | Full progressive help: top → resource → action → schema |
| **Schema introspection** | Not available | Partial or undocumented | `tool schema <resource.action>` returns full typed schema |
| **Dry-run** | Not available | Available for some commands | Available for all mutating commands |
| **Safety tiers** | Destructive ops at same level as reads | Some warning on destructive ops | Read/write/destructive clearly tiered; destructive hidden from skills |
| **Auth delegation** | Agent manages token lifecycle | Token via env var but refreshed by agent | Human/system manages token; agent receives pre-fetched credential |
| **Error recoverability** | No error fields | `code` + `message` only | `code` + `message` + `retryable` + context fields |
| **Trust boundary** | CLI args used for auth/config | Mixed | Env vars / config set by human; agent supplies only runtime params |

**Scoring guide:**
- 18–20: Agent-native
- 12–17: Partially agent-native — specific gaps, actionable fixes
- 0–11: Not yet agent-native — structural redesign needed

---

## Review checklist

Use this checklist when evaluating any CLI for agent readiness.

### Output

- [ ] `stdout` is always valid JSON (success and failure)
- [ ] `stderr` carries human-readable diagnostics only
- [ ] JSON envelope is stable: `{ "ok": bool, "data": ... }` or `{ "ok": false, "error": ... }`
- [ ] Error object includes: `code`, `message`, `retryable`
- [ ] No prose mixed into `stdout`

### Exit codes

- [ ] Exit codes are documented
- [ ] Exit codes are stable across versions
- [ ] Distinct codes for: success (0), runtime error, auth error, validation error
- [ ] Exit code mapping is available via `--help` or `schema`

### Self-description

- [ ] Top-level `--help` lists all resources/commands
- [ ] Resource-level `--help` lists actions
- [ ] Action-level `--help` lists all flags with types
- [ ] Schema introspection command available (`tool schema <resource.action>`)
- [ ] Dry-run available for all mutating commands

### Safety

- [ ] Read commands clearly discoverable
- [ ] Write/mutating commands carry explicit warning in help
- [ ] Destructive commands (delete/purge) hidden from skills or gated
- [ ] Dry-run covers all write operations

### Auth

- [ ] Human/system manages token acquisition (browser flow, keychain)
- [ ] Agent receives credential via env var or pre-fetched token
- [ ] Agent never navigates OAuth2 or browser flows
- [ ] Token refresh handled outside agent runtime

### Trust

- [ ] CLI args treated as untrusted (validated at boundary)
- [ ] Environment variables used for config/safety settings (human-set)
- [ ] Agent cannot escalate its own privileges via CLI args

### Schema

- [ ] Schema is the single source of truth
- [ ] CLI command structure derives from schema
- [ ] Validation derives from schema
- [ ] Help text derives from schema
- [ ] Generated skills derive from schema (if applicable)

---

## Design guidance

### Output envelopes

```json
{ "ok": true, "data": {} }
```

```json
{
  "ok": false,
  "error": {
    "code": "validation_error",
    "message": "Missing required field: email",
    "field": "email",
    "retryable": false
  }
}
```

### Exit code model

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Runtime / API error |
| `2` | Auth error |
| `3` | Validation error |

Exact codes may vary — the mapping must be documented and deterministic.

### Help design

Progressive, not monolithic: capability overview → resource → action → schema → examples → dry-run.

### Safety design

Read actions: easy to discover. Write actions: clearly marked. Destructive actions: hidden, gated, or separately enabled. Dry-run: everywhere feasible.

### Auth design

Human/system-managed token acquisition. Environment/config-based delegation. No agent involvement in browser auth flows. Separation between auth bootstrap and agent execution.

---

## Things this skill should avoid recommending

* Human-readable prose as the only output contract
* README required for basic command discovery
* Schema and validation that drift apart
* Auth supplied primarily via agent-generated arguments
* Destructive actions exposed by default
* CLI behavior that depends on undocumented conventions
* Errors that are only textual and not machine-routable

---

## One-sentence summary

This skill helps turn a CLI into a trustworthy execution interface for **humans, AI agents, and systems** through **structured output, self-description, delegated authentication, safety boundaries, and a complete interaction loop**.
