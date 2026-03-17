# Stack Research

**Domain:** Claude Code skill wrapping a browser automation CLI tool
**Researched:** 2026-03-17
**Confidence:** HIGH

---

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| `@playwright/cli` | 0.1.1 | Browser automation CLI invoked by Claude | The official Microsoft package that exposes `playwright-cli` binary. Token-efficient alternative to Playwright MCP: does not force page snapshots into context on every call. Replaces the deprecated `playwright-cli` npm package (now at 0.262.0 but pointing to this package). |
| Claude Code Skills (SKILL.md format) | Claude Code 2.1.x / Agent Skills open standard | Container format for the skill | Official Anthropic/Claude Code format. Provides automatic discovery via frontmatter `description`, progressive disclosure via supporting files, and `/slash-command` invocation. Works globally (`~/.claude/skills/`) so one install covers all projects. |
| `skill-creator` (bundled skill) | installed at `~/.claude/skills/skill-creator/` | Creation, eval, and description optimization loop | Mandatory per project constraints. Handles the full write → test → grade → optimize cycle including: parallel with/without-skill eval runs, `aggregate_benchmark.py`, eval-viewer HTML, and `run_loop.py` description optimizer. Do NOT create the skill manually. |
| Node.js | >=18 (current: 22.22.0) | Runtime for `playwright-cli` | Required by `@playwright/cli`. Already satisfied on this machine. |
| Python 3 | >=3.10 (current: 3.12.3) | `skill-creator` scripts | All `skill-creator` scripts (`aggregate_benchmark.py`, `generate_review.py`, `run_loop.py`, etc.) are Python. Already satisfied on this machine. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `@playwright/mcp` | 0.0.68 | MCP server alternative to CLI | Only when the skill explicitly needs to fall back to MCP mode (persistent state, rich introspection). NOT the primary tool; the skill enforces `playwright-cli` as the single entry point. |
| `playwright-cli` (npm, deprecated) | 0.262.0 | Legacy package name | Never install directly. Only present as a redirect to `@playwright/cli`. Ignore. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `skill-creator` eval loop | Test skill triggers, grade outputs, produce benchmark.json | Located at `~/.claude/skills/skill-creator/`. Invoked via Claude Code with `/skill-creator`. Use `run_loop.py --model claude-sonnet-4-6` for description optimization (match model to current session). |
| `eval-viewer/generate_review.py` | Browser-based qualitative review of eval runs | Run as `nohup python generate_review.py <workspace>/iteration-N --skill-name playwright-testing ...`. Use `--static <path>` in headless/cowork environments. |
| `scripts/aggregate_benchmark.py` | Aggregate iteration results into benchmark.json | Run as `python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name playwright-testing`. |
| `scripts/run_loop.py` | Automated description optimization | 5-iteration loop: 60/40 train/test split, 3 runs per query. Produces `best_description` JSON. |
| `scripts/package_skill.py` | Package skill folder into distributable `.skill` file | Run after skill is finalized. |
| `claude -p` CLI | Subprocess used by `run_loop.py` for trigger evals | Available at `/home/sanchez/.local/bin/claude` (version 2.1.77). Used internally by optimization scripts. |

---

## Installation

```bash
# Install playwright-cli globally (single dependency for the skill)
npm install -g @playwright/cli@latest

# Install browser skills for coding agent integration
playwright-cli install --skills

# Verify binary is available
playwright-cli --help

# Optional: install browsers if not already present
playwright-cli install-browser
```

The skill itself has no npm dependencies to install — it is a directory of markdown files at `~/.claude/skills/playwright-testing/`.

---

## Skill Directory Structure

```text
~/.claude/skills/playwright-testing/
├── SKILL.md                          # Required. YAML frontmatter + 5-step protocol (<300 lines)
├── references/
│   └── playwright-cli-commands.md    # Full command reference downloaded from microsoft/playwright-cli
└── evals/
    └── evals.json                    # 5 test cases with assertions
```

**Key structural decisions:**

- `SKILL.md` stays under 300 lines (project constraint) by offloading the full command reference to `references/playwright-cli-commands.md`.
- The official Microsoft SKILL.md at `https://github.com/microsoft/playwright-cli/blob/main/skills/playwright-cli/SKILL.md` is the authoritative source for the command reference file. Download it rather than write it manually.
- `evals/` directory holds `evals.json` with 5 test cases as required by project constraints.

---

## SKILL.md Frontmatter Fields (Required)

```yaml
---
name: playwright-testing
description: >
  [Critical: max 1024 chars, third person, includes WHAT + WHEN triggers]
  Controls the browser via playwright-cli for testing, debugging, and
  interaction verification. Use when: debugging frontend bugs, verifying
  user flows, filling forms, taking screenshots, checking console/network
  errors, or any interaction with a web browser. ALWAYS prefer this skill
  over curl, ad-hoc Node.js scripts, or Playwright MCP when a real browser
  is needed.
---
```

- `name`: lowercase, hyphens only, max 64 chars. `playwright-testing` satisfies all constraints.
- `description`: must be "pushy" (per skill-creator guidelines) to combat undertriggering. Include explicit trigger phrases. Third person only. No XML tags.
- No `disable-model-invocation` — the skill must auto-trigger. Claude decides when to invoke it based on description match.

---

## Playwright-CLI Command Surface (Summary)

| Category | Key Commands | Notes |
|----------|-------------|-------|
| Core | `open`, `goto`, `click`, `fill`, `type`, `snapshot`, `screenshot`, `hover`, `select` | `snapshot` is the primary diagnostic command — returns element references (e1, e2...) |
| Session | `-s=name` flag, `list`, `close-all`, `kill-all` | Named sessions via `-s=<project>` or `PLAYWRIGHT_CLI_SESSION` env var |
| DevTools | `console [level]`, `network`, `tracing-start/stop`, `video-start/stop`, `run-code` | Mandatory for error diagnosis: `console` + `network` before any fix |
| Navigation | `go-back`, `go-forward`, `reload` | |
| Tabs | `tab-list`, `tab-new`, `tab-select`, `tab-close` | |
| Storage | `state-save`, `state-load`, cookies, localStorage, sessionStorage | Use `state-save` for login persistence |
| Network | `route`, `unroute`, `route-list` | Mocking / request interception |
| Dashboard | `playwright-cli show` | Visual dashboard for monitoring active sessions |
| Config | `playwright-cli --config path/to/config.json` | Default config: `.playwright/cli.config.json` |

The 5-step diagnostic protocol the skill must encode:
1. `snapshot` — get current page state and element references
2. reproduce the issue using element refs
3. `console` + `network` — collect diagnostic data
4. apply fix
5. re-test with `snapshot` + interaction replay

---

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| `@playwright/cli` as CLI | `@playwright/mcp` as MCP server | When iterative exploration with persistent MCP state is needed and token cost is not a concern. The skill explicitly bans MCP as the primary path. |
| Global skill at `~/.claude/skills/` | Project skill at `.claude/skills/` | Never for this use case — the whole point is universal availability across all projects. |
| SKILL.md + `references/` file | Single monolithic SKILL.md | Only if command reference stays under 300 lines total. It won't — the command reference is extensive. Keep them separate. |
| `skill-creator` loop | Manual SKILL.md authoring | If you just need to iterate once without eval metrics. For a "pushy" description that reliably triggers, the optimization loop is required. |
| Named sessions `--session=<project>` | Default session (no flag) | Only for one-off ephemeral tasks. All project work should use named sessions. |

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `playwright-cli` (npm package) | Deprecated, points to `@playwright/cli` | `npm install -g @playwright/cli@latest` |
| `@playwright/mcp` as primary tool | Loads large tool schemas into context, token-heavy, bypasses the skill's diagnostic protocol | `playwright-cli` CLI commands |
| `curl` for frontend testing | Cannot execute JavaScript, cannot interact with DOM, cannot capture visual state | `playwright-cli goto` + `snapshot` |
| Ad-hoc `node -e "..."` Playwright scripts | Bypasses the structured diagnostic protocol, no session persistence, no dashboard | `playwright-cli` with `--session` |
| `@playwright/test` / Jest / Vitest | Different tool: for CI test suites, not for Claude Code interactive diagnosis | `playwright-cli` for interactive work; `@playwright/test` remains valid for CI pipelines |
| `npx playwright-cli` | Works but slower (downloads on each run). Global install preferred. | `npm install -g @playwright/cli@latest` |

---

## Stack Patterns by Variant

**If the project uses authentication (login required):**
- Use `playwright-cli state-save` after first login
- Reload saved state with `playwright-cli state-load` in subsequent sessions
- Store credentials via `.env` — skill must check `.env` before prompting user

**If testing across multiple concurrent projects:**
- Use `--session=<project-name>` on every command
- Or set `PLAYWRIGHT_CLI_SESSION=<project-name>` in the project `.env`
- `playwright-cli list` shows all active sessions

**If environment is headless (CI, cowork, no display):**
- `playwright-cli show` dashboard is unavailable
- Rely entirely on `snapshot`, `console`, `network` output in terminal
- Generate eval-viewer with `--static <output_path>` instead of browser server

**If running description optimization:**
- Use `python -m scripts.run_loop --model claude-sonnet-4-6` (match to current session model)
- This is the current production model as of 2026-03-17

---

## Version Compatibility

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| `@playwright/cli@0.1.1` | Node.js >=18 | Current latest. Node.js 22.22.0 on this machine satisfies requirement. |
| `skill-creator` (local) | Python 3.12.3 | All scripts use only stdlib + subprocess. No pip install needed. |
| Claude Code 2.1.77 | SKILL.md Agent Skills open standard | `claude -p` available for `run_loop.py` optimization. |
| `@playwright/mcp@0.0.68` | Node.js >=18 | Already installed globally (`/home/sanchez/.npm-global/bin/playwright-mcp`). Not used as primary tool. |

---

## Sources

- `@playwright/cli` npm registry — version 0.1.1, Node.js >=18 requirement (HIGH confidence — direct npm query)
- `https://github.com/microsoft/playwright-cli` — installation, command categories, session flag syntax, SKILL.md from official repo (HIGH confidence — official Microsoft repo)
- `https://code.claude.com/docs/en/skills` — SKILL.md structure, frontmatter fields, progressive disclosure, directory layout, invocation control (HIGH confidence — official Anthropic Claude Code docs)
- `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` — description authoring, `name`/`description` validation rules, eval-driven development (HIGH confidence — official Anthropic docs)
- `~/.claude/skills/skill-creator/SKILL.md` — eval loop mechanics, `run_loop.py`, `aggregate_benchmark.py`, eval-viewer, description optimization (HIGH confidence — local installed skill, read directly)
- `~/.claude/skills/skill-creator/references/schemas.md` — `evals.json` schema (HIGH confidence — local file)
- `deepwiki.com/microsoft/playwright-cli/4-command-reference` — command count by category, syntax patterns (MEDIUM confidence — third-party docs aggregator, consistent with official repo)
- `testcollab.com/blog/playwright-cli` — CLI vs MCP positioning (MEDIUM confidence — blog, consistent with official docs)

---

*Stack research for: Claude Code skill wrapping playwright-cli for universal browser interaction*
*Researched: 2026-03-17*
