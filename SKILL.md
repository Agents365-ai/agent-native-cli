---
name: agent-native-cli
description: Use when designing, reviewing, or refactoring a CLI that must serve AI agents alongside humans, or when converting an API or SDK into an agent-usable CLI interface.
license: MIT
homepage: https://github.com/Agents365-ai/agent-native-cli
compatibility: Includes sidecar metadata for OpenClaw, Hermes, pi-mono, and OpenAI Codex; the core SKILL.md is portable to any agent runtime that supports Agent Skills-style instructions.
platforms: [macos, linux, windows]
metadata: {"openclaw":{"requires":{},"emoji":"⌨️","os":["darwin","linux","win32"]},"hermes":{"tags":["cli","agent-native","interface-design","structured-output","schema-driven"],"category":"engineering","requires_tools":[],"related_skills":[]},"pimo":{"category":"engineering","tags":["cli","agent-native","interface-design","structured-output","schema-driven"]},"author":"Agents365-ai","version":"1.0.0"}
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

## Reducing agent round-trips

The cost of every CLI invocation an agent makes is paid twice: once in latency, once in context tokens. A CLI that takes three calls to surface what an agent needs in order to plan its next step is, for the agent, *worse* than one that takes one call — even if every individual call is faster. Optimize for round-trip count, not just per-call performance.

Concrete tactics:

- **Pre-compute aggregates in list responses.** A `list` that returns `{ "ok": true, "data": [...], "count": 7, "has_more": false }` saves a follow-up `count` call.
- **Definitive empty states.** Return `{ "ok": true, "data": [], "count": 0 }`, never `null`. The agent should never have to disambiguate "no results" from "missing field."
- **Field selection on the response side.** Borrow from `gh --json title,number,state`: let callers ask for only the fields they need so list responses stay small and a follow-up "give me more detail on item N" is the exception, not the rule.
- **Compact default, `--full` escape hatch.** List items should carry 3–4 fields by default; agents that need more pass an opt-in flag rather than parsing huge default payloads on every call.
- **Next-step hints in success responses.** When the agent's likely next action is predictable, include a `next` slot, e.g. `{ "ok": true, "data": { ... }, "next": ["healthkit sleep summary --start-date 2026-01-01 --end-date 2026-01-07"] }`. The agent saves a discovery turn.
- **Cursor pagination in the envelope.** `{ "ok": true, "data": [...], "page": { "next_cursor": "...", "has_more": true } }` so the agent can decide whether to continue without parsing prose pagination markers.

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

**The CLI must decide for itself which audience is reading.** Detect at startup whether stdout is a TTY: when stdout is *not* a TTY (piped, redirected, captured by an agent runtime), default to JSON; when stdout *is* a TTY, default to a human-readable format. `NO_COLOR` and an explicit `--format json|table` flag override the auto-detection. Agents should never have to remember to pass `--format json` — if they have to, they will forget, and the run will silently produce un-parseable prose. This is the mechanical lever that makes Principle 0 work.

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

**Self-description must be progressive, not eager.** A CLI with hundreds of commands should not dump its full schema into the agent's context on the first call. Top-level `--help` should be small enough to fit in a few hundred tokens; deeper detail (resource help, action help, full schema) is loaded on demand only when the agent has narrowed its target. Anthropic's *Code execution with MCP: Building more efficient agents* (Nov 2025) reports the same insight from the MCP world: "Models are great at navigating filesystems. Presenting tools as code on a filesystem allows models to read tool definitions on-demand, rather than reading them all up-front." In one Google-Drive→Salesforce case the technique reduced token usage "from 150,000 tokens to 2,000 tokens — a time and cost saving of 98.7%." The CLI equivalent is the layered help tree above plus response-side field selection (`gh pr list --json number,title,state`): the agent asks only for the fields it needs, and the CLI returns only what was asked for.

### Principle 4. Safety Through Graduated Visibility

| Tier | Commands | Exposure |
|------|----------|----------|
| preview | all commands | dry-run available everywhere |
| open | list / get / search | full docs, easy to discover |
| warned | create / update / send | explicit warning in help and skills |
| hidden | delete / purge / empty | excluded from skills, gated separately |

**Tiers are necessary but not sufficient.** Graduated visibility is a prompt-side defense — it works only when the agent reads the warning and respects it, and approval fatigue degrades that defense quickly. Anthropic's *Beyond permission prompts: making Claude Code more secure and autonomous* (Oct 2025) observes that "constantly clicking 'approve' slows down development cycles and can lead to 'approval fatigue', where users might not pay close attention to what they're approving" and reports that OS-level sandboxing "safely reduces permission prompts by 84%." An agent-native CLI should assume the agent runtime will additionally sandbox it at the OS level (filesystem, network, processes), and design destructive commands to fail closed inside that sandbox rather than relying on a single layer of warnings.

### Principle 5. Validate at the Boundary, Not in the Middle

Inputs are validated once at the CLI entry point. Internal code operates on validated, typed, trusted structures. Validation functions are centralized and tested for both pass and reject cases.

### Principle 6. The Schema Is the Source of Truth

If a schema exists, everything derives from it: CLI command structure, validation rules, help text, generated docs, generated skills, type definitions, dry-run contracts. The schema is never manually duplicated.

**The schema must also carry its own version and deprecation signals.** A schema response should declare which CLI version produced it, when each method was introduced, and whether any field is deprecated and what to use instead. Agents that have cached an older view of the schema can then notice the drift and re-discover, rather than calling a removed method and surfacing a confusing error:

```json
{
  "method": "sleep.list",
  "since": "1.2.0",
  "deprecated": false,
  "params": {
    "startDate": { "type": "string", "format": "date", "required": true },
    "endDate":   { "type": "string", "format": "date", "required": true },
    "page_size": { "type": "integer", "default": 20, "max": 100, "deprecated": true, "replaced_by": "pageSize" }
  }
}
```

API stability is a contract you owe the agent: a CLI that renames flags between point releases forces every agent that depends on it to re-discover and re-plan. Treat the schema as a versioned, append-mostly surface.

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

Use the 14-criterion rubric to score the CLI. Every one of the seven principles has at least one rubric row backing it, so the score-to-principle mapping is total: Principle 0 → Three-audience support, Non-interactive operation; Principle 1 → Stdout contract, Stderr separation, Idempotent retries, Error recoverability; Principle 2 → Trust boundary; Principle 3 → Self-description (help), Dry-run; Principle 4 → Safety tiers; Principle 5 → Boundary validation; Principle 6 → Schema introspection; Principle 7 → Auth delegation. Then summarize the results per principle with evidence, risk, and recommendation.

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

Report the 14-criterion rubric score first, then summarize the seven principles as: status · evidence · issue · recommendation.

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
# Human / system runs once, out of band (shell profile, systemd unit, supervisor):
healthkit auth login                          # browser OAuth2 flow, stores token in keychain
export HEALTHKIT_TOKEN="$(healthkit auth token)"  # token is injected into the agent's environment

# Agent's own commands — it never invokes `auth login` or `auth token`:
healthkit sleep list --start-date 2026-01-01 --end-date 2026-01-07
```

The agent inherits `HEALTHKIT_TOKEN` from an environment it did not build. It never runs the login subcommand, never runs the `auth token` retrieval subcommand, and never handles refresh — those belong to the human or the orchestrator. The env var is the trust boundary; the agent consumes credentials, it does not fetch them.

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

### Example 6 — Good: idempotent batch with partial success, next hint, and meta

```bash
$ healthkit alerts send-bulk \
    --recipients "user1,user2,user3" \
    --message "Reminder: log today's sleep" \
    --idempotency-key "alert-batch-2026-04-11-am"
{
  "ok": "partial",
  "data": {
    "succeeded": [
      { "recipient": "user1", "alert_id": "alrt_abc" },
      { "recipient": "user2", "alert_id": "alrt_def" }
    ],
    "failed": [
      {
        "recipient": "user3",
        "error": {
          "code": "rate_limited",
          "message": "Per-recipient rate limit exceeded",
          "retryable": true,
          "retry_after_seconds": 60
        }
      }
    ]
  },
  "next": [
    "healthkit alerts send-bulk --recipients user3 --message 'Reminder: log today\\'s sleep' --idempotency-key alert-batch-2026-04-11-am"
  ],
  "meta": {
    "request_id": "req_8fa9c1",
    "latency_ms": 412,
    "schema_version": "1.4.0"
  }
}
```

This single response carries everything an agent needs to recover without a discovery turn:

- `ok: "partial"` tells the agent some items succeeded and some failed — it does **not** need to re-process `user1` or `user2`.
- The failed item carries `code: "rate_limited"`, `retryable: true`, and `retry_after_seconds: 60` — the agent knows *what* failed, *whether* to retry, and *when*.
- Re-invoking the exact same command with the same `--idempotency-key` is safe: the CLI will return the same envelope, and only `user3` will actually be re-attempted on the upstream side.
- The `next` slot suggests the precise follow-up command, so the agent does not need a planning turn to construct it.
- The `meta` slot carries `request_id` for log correlation, `latency_ms` for SLO tracking, and `schema_version` so the agent can detect drift against any cached schema (Principle 6).

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

Use this rubric when scoring a CLI review. Each criterion is scored 0–2. Every criterion is tagged with the principle it backs, so scoring the rubric is the same act as auditing the seven principles.

| Criterion | Principle | 0 — Fail | 1 — Partial | 2 — Pass |
|-----------|-----------|----------|-------------|----------|
| **Three-audience support** | P0 | Designed for only one audience (human-only, or agent-only) | Serves two audiences well; the third is an afterthought or broken | Deliberately designed for human + agent + system with documented trade-offs |
| **Stdout contract** | P1 | Prose or mixed output | JSON sometimes, not always | Always parseable JSON with stable envelope |
| **Stderr separation** | P1 | Diagnostics mixed into stdout | Some separation | Diagnostics always on stderr |
| **Exit code semantics** | P1/P2 | All errors map to same code | Some codes defined | Documented, stable, distinct codes per failure class |
| **Self-description (help)** | P3 | No `--help` or single flat page | Layered help exists but incomplete | Full progressive help: top → resource → action → schema |
| **Schema introspection** | P6 | Not available | Partial or undocumented | `tool schema <resource.action>` returns full typed schema |
| **Dry-run** | P3/P4 | Not available | Available for some commands | Available for all mutating commands |
| **Idempotent retries** | P1 | Mutating commands have no idempotency story; retries create duplicates | `--idempotency-key` exists on some commands, or retry semantics are inconsistent | Every mutating command accepts `--idempotency-key`; retried calls return the original result; the `retryable` flag in the error envelope is meaningful and correct |
| **Non-interactive operation** | P0 | CLI prompts on confirmation or password input regardless of TTY state; no `--yes`/`--force` flags | Some commands support `--yes` but TTY detection is incomplete or pagers still block | CLI never prompts when stdin is not a TTY; `--yes` / `--no-input` supported on every confirmation; pagers disabled when stdout is not a TTY; structured `confirmation_required` error returned instead of blocking |
| **Safety tiers** | P4 | Destructive ops at same level as reads | Some warning on destructive ops | Read/write/destructive clearly tiered; destructive hidden from skills |
| **Boundary validation** | P5 | Validation scattered across internal functions, or missing | Boundary validation exists but internal code still re-validates or accepts raw input | All input validated once at the CLI entry point; internal code operates on typed, trusted structures; validators are centralized and tested for pass and reject cases |
| **Auth delegation** | P7 | Agent manages token lifecycle, runs login or token-retrieval subcommands | Token via env var but refreshed by the agent | Human/system manages token acquisition and refresh; agent receives a pre-fetched credential and never invokes the auth retrieval path |
| **Error recoverability** | P1 | No error fields | `code` + `message` only | `code` + `message` + `retryable` + context fields |
| **Trust boundary** | P2 | CLI args used for auth/config | Mixed | Env vars / config set by human; agent supplies only runtime params |

**Scoring guide (max 28):**
- 26–28: Agent-native
- 17–25: Partially agent-native — specific gaps, actionable fixes
- 0–16: Not yet agent-native — structural redesign needed

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

### Retry and interaction mode

- [ ] Every mutating command accepts `--idempotency-key`
- [ ] Retried calls with the same idempotency key return the original result
- [ ] `retryable` field in error envelope is meaningful and correct
- [ ] CLI never prompts for input when stdin is not a TTY
- [ ] `--yes` / `--no-input` / `--force` supported on every command that would otherwise prompt
- [ ] Returns structured `confirmation_required` error instead of blocking on missing confirmation
- [ ] stdout defaults to JSON when stdout is not a TTY (no `--format json` required)
- [ ] Pagers (`less`, `more`) disabled when stdout is not a TTY

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

Success:

```json
{ "ok": true, "data": {} }
```

Failure:

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

Partial success (batch operations):

```json
{
  "ok": "partial",
  "data": {
    "succeeded": [
      { "id": "msg_001", "status": "sent" },
      { "id": "msg_002", "status": "sent" }
    ],
    "failed": [
      {
        "id": "msg_003",
        "error": { "code": "rate_limited", "message": "Rate limit exceeded for recipient", "retryable": true }
      }
    ]
  }
}
```

A batch command that collapses any per-item failure into a top-level `ok: false` forces every agent to re-process its successful items on retry. AWS SQS's `ReportBatchItemFailures` and similar APIs settled on this per-item shape for the same reason: agents need to know exactly which items to retry. Pair partial success with an idempotency key on the batch as a whole so that re-running with the same key only re-issues the *failed* items.

Optional `meta` slot for observability:

```json
{
  "ok": true,
  "data": { "id": "abc123" },
  "meta": {
    "request_id": "req_8fa9c1",
    "latency_ms": 412,
    "schema_version": "1.4.0"
  }
}
```

`meta` is a freeform slot for telemetry the orchestrator may want without polluting `data`: a stable `request_id` for log correlation, `latency_ms` for SLO tracking, `schema_version` so an agent can detect drift against a cached schema (see Principle 6). When the underlying call has a token / quota cost the CLI knows about, surface it here too — `tokens_used`, `quota_remaining`. The slot is optional and additive: agents that don't need it ignore it; agents that do gain observability without an extra round-trip. This aligns with where the OpenTelemetry GenAI semantic conventions are heading for tool-call traces.

### Exit code model

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Runtime / API error |
| `2` | Auth error |
| `3` | Validation error |

Exact codes may vary — the mapping must be documented and deterministic. (`sysexits.h` defines a richer pre-agent vocabulary — `EX_USAGE=64`, `EX_DATAERR=65`, `EX_NOPERM=77`, `EX_CONFIG=78` — and a CLI is free to use it. The 0–3 mapping above is a deliberate simplification for agent routing; what matters is that codes are documented, stable, and distinct per failure class.)

### Idempotency and retry

Agents retry. Networks fail, processes get killed, exit codes get misread. A CLI that is not idempotent forces every agent that uses it to write special-case retry logic — and most agents will get it wrong.

Every mutating command should accept `--idempotency-key <string>`. A retried call carrying the same key must be a safe no-op that returns the original result, in the same `ok` / `error` shape. The CLI is responsible for storing the key↔result mapping for long enough that legitimate retries can find it (typically minutes; the upper bound belongs to the underlying API).

This pairs with the `retryable` field in the error envelope: `retryable: true` tells the agent it is *safe* to call again with the same idempotency key, and that doing so will eventually converge; `retryable: false` tells the agent that retrying will not change the outcome.

> "Agents retry. Networks fail. Commands get interrupted. If your `create` command fails on the second run because the resource already exists, the agent has to write special-case retry logic." — Ugo Enyioha, *Writing CLI Tools That AI Agents Actually Want to Use* (Feb 2026)

### Non-interactive operation

An agent cannot answer a confirmation prompt, cannot type a password into a TTY, and cannot navigate a curses-style menu. A CLI that hangs waiting for stdin when stdin is not a TTY is, from the agent's perspective, broken.

Rules:

- **Never prompt when stdin is not a TTY.** Detect at startup; if a confirmation would normally fire but `isatty(stdin) == false`, return a structured error instead of blocking:
  ```json
  { "ok": false, "error": { "code": "confirmation_required", "message": "Pass --yes to confirm.", "retryable": false } }
  ```
- **Always support `--yes` / `--no-input` / `--force`** (or an equivalent) on every command that would otherwise prompt, so a human running interactively can opt out and an agent always runs without prompts.
- **Never read secrets from interactive prompts in agent contexts.** Secrets come from environment variables or pre-set config (see Principle 7).
- **Pagers off when stdout is not a TTY.** Detect at startup; never invoke `less` / `more` style pagers that would block on a non-TTY consumer.

> "An agent cannot type 'y' at a confirmation prompt. If your CLI hangs waiting for input, the agent's workflow is dead." — Ugo Enyioha (Feb 2026)

### Long-running commands and streaming

A command that takes minutes to finish is a hazard for an agent: the agent does not know whether the CLI is making progress, stuck, or dead, and it cannot afford to wait blind on a single JSON envelope at the end. Two patterns work:

**Structured progress on stderr, final JSON on stdout.** The agent reads stderr for liveness and stdout for the result. Progress events are themselves structured (one JSON object per line) so the orchestrator can parse them, but they never pollute the stdout JSON envelope:

```
$ healthkit export run --dataset sleep --since 2026-01-01 > result.json
# stderr (line by line):
{ "event": "progress", "phase": "fetch", "done": 120, "total": 730 }
{ "event": "progress", "phase": "fetch", "done": 365, "total": 730 }
{ "event": "progress", "phase": "write", "done": 730, "total": 730 }
# stdout (single envelope at the end):
{ "ok": true, "data": { "rows": 730, "path": "/tmp/sleep.parquet" } }
```

**NDJSON streaming for long lists.** When a list command might return thousands of items, offer a `--stream` (or `--ndjson`) mode that emits one JSON object per line on stdout, with a final summary line. Agents can process the stream incrementally and stop when they have enough:

```
$ healthkit sleep list --since 2024-01-01 --stream
{ "ok": true, "data": { "id": "sl_001", "date": "2024-01-01", "minutes": 412 } }
{ "ok": true, "data": { "id": "sl_002", "date": "2024-01-02", "minutes": 388 } }
...
{ "ok": true, "summary": { "count": 730, "has_more": false } }
```

Either way: the agent must be able to tell, from output alone, whether the command is *making progress*, *finished*, or *failed*. Silent multi-minute waits are an availability bug, not a UX preference.

### Help design

Progressive, not monolithic: capability overview → resource → action → schema → examples → dry-run.

### Safety design

Read actions: easy to discover. Write actions: clearly marked. Destructive actions: hidden, gated, or separately enabled. Dry-run: everywhere feasible.

### Auth design

Human/system-managed token acquisition. Environment/config-based delegation. No agent involvement in browser auth flows. Separation between auth bootstrap and agent execution.

### Locale, time, and determinism

Agent behavior breaks subtly when CLI output depends on the host's locale or timezone. Pin determinism at the CLI boundary so the agent never has to second-guess what `2026-04-11` means or whether `1,234.56` is one number or two.

- **All timestamps are UTC ISO-8601** with explicit timezone (`2026-04-11T14:30:00Z`), not local time and not Unix epoch unless explicitly requested.
- **All dates are ISO-8601** (`2026-04-11`), never `04/11/2026` or `11/04/2026`.
- **Numeric formats are locale-independent.** Decimal point `.`, no thousands separators in JSON output. (`1234.56`, never `1,234.56` or `1.234,56`.)
- **Internal subprocess calls run under `LC_ALL=C`** (or equivalent), so any tool the CLI shells out to — `date`, `sort`, `awk` — produces the same bytes on every host.
- **Sort orders are documented and stable.** Default sort is byte-wise unless the schema says otherwise.

---

## When CLI is the right answer (and when it isn't)

This skill teaches how to make a CLI a first-class interface for agents — but a CLI is not always the right interface, and pretending otherwise is dishonest. The honest summary of where the field has landed in 2025–2026:

| Situation | Better fit |
|-----------|------------|
| Single-user / developer-owned workflow on the same machine as the agent | **CLI** — process model is cheap, auth is local, output is composable, the SKILL pattern works |
| Large multi-tenant SaaS with per-user OAuth and scoped access | **MCP server** — centralized auth, per-user scoping, network-attachable, no need to ship a binary |
| Hundreds of tools where eager schema dumps would blow the context window | **Hybrid** — expose tools as CLI commands or filesystem-discoverable scripts; load definitions on demand. Anthropic's [code-execution-MCP pattern](https://www.anthropic.com/engineering/code-execution-with-mcp) and `mcp-cli`-style bridges are concrete instances. |

Mario Zechner's [empirical benchmark](https://mariozechner.at/posts/2025-08-15-mcp-vs-cli/) (Aug 2025) of MCP vs CLI for coding agents lands on a one-line conclusion that's worth taking seriously: *a lot of MCPs could have been CLI invocations.* That doesn't make MCP wrong; it means the default has been wrong. For the workflows this skill targets — developer tools, infrastructure CLIs, single-user data and research workflows — CLI is the lighter, more inspectable, more composable choice. For the workflows it doesn't target — multi-tenant SaaS exposing per-user data — MCP earns its complexity.

If you reach a design where you'd be fighting the CLI process model (per-request user context, fine-grained per-call authorization, network-attached without local install), that's the signal to switch interfaces, not to bend this skill out of shape.

---

## Things this skill should avoid recommending

* Human-readable prose as the only output contract
* README required for basic command discovery
* Schema and validation that drift apart
* Auth supplied primarily via agent-generated arguments
* Destructive actions exposed by default
* CLI behavior that depends on undocumented conventions
* Errors that are only textual and not machine-routable
* Mutating commands that are not idempotent under retry
* Confirmation prompts with no `--yes` escape and no TTY-aware fallback
* Eager schema dumps in top-level `--help`

---

## References

The conventions in this skill draw on several primary sources in the agent-CLI design space. These are the sources actually quoted or directly relied on above; the broader landscape (clig.dev, MCP, the gh / aws / kubectl design corpus) is implicit background.

- Anthropic, [*Code execution with MCP: Building more efficient agents*](https://www.anthropic.com/engineering/code-execution-with-mcp) (Nov 4, 2025) — progressive disclosure of tool definitions; the 150K → 2K token reduction case study cited in Principle 3.
- Anthropic, [*Beyond permission prompts: making Claude Code more secure and autonomous*](https://www.anthropic.com/engineering/claude-code-sandboxing) (Oct 20, 2025) — approval fatigue and the 84% prompt-reduction figure cited in Principle 4.
- Ugo Enyioha, [*Writing CLI Tools That AI Agents Actually Want to Use*](https://dev.to/uenyioha/writing-cli-tools-that-ai-agents-actually-want-to-use-39no) (Feb 27, 2026, dev.to) — idempotency-on-retry and "agents cannot type 'y'" framings cited in the Idempotency and Non-interactive sections.
- Thibault Le Ouay Ducasse / openstatus, [*Building a CLI That Works for Humans and Machines*](https://www.openstatus.dev/blog/building-cli-for-human-and-agents) (Apr 2, 2026) — TTY detection as the human/machine switch cited in Principle 1.
- Mario Zechner, [*MCP vs CLI: Benchmarking Tools for Coding Agents*](https://mariozechner.at/posts/2025-08-15-mcp-vs-cli/) (Aug 15, 2025) — empirical case that many MCP servers could be CLI invocations.
- Armin Ronacher, [*Skills vs Dynamic MCP Loadouts*](https://lucumr.pocoo.org/2025/12/13/skills-vs-mcp/) (Dec 13, 2025) — schema/API stability as a first-class concern cited in Principle 6.
- GitHub Engineering, [*Scripting with GitHub CLI*](https://github.blog/engineering/engineering-principles/scripting-with-github-cli/) (Mar 11, 2021) — `gh --json field1,field2,field3` as the canonical response-side field-selection pattern.
- [*Command Line Interface Guidelines*](https://clig.dev/) (clig.dev) — the pre-agent baseline for human-first CLI design. This skill extends it; it does not replace it.
- [`sysexits.h`](https://manpages.ubuntu.com/manpages/noble/man3/sysexits.h.3head.html) — the BSD exit-code vocabulary that the Exit code model section deliberately simplifies away from.

The term "agent-native CLI" used in this skill is one of several competing framings in current writing. *Agent-first CLI* (Propel, Keyboards Down) is more common; *CLI for humans and machines* (openstatus, Linearis) is the most descriptive. "Native" is chosen here to emphasize that agent support is a first-class design goal, not a retrofit on top of a human-only CLI.

---

## One-sentence summary

This skill helps turn a CLI into a trustworthy execution interface for **humans, AI agents, and systems** through **structured output, self-description, delegated authentication, safety boundaries, and a complete interaction loop**.
