# Architecture Research

**Domain:** Claude Code skill wrapping a CLI tool workflow
**Researched:** 2026-03-17
**Confidence:** HIGH (sourced directly from skill-creator SKILL.md and live skill examples in ~/.claude/skills/)

## Standard Architecture

### System Overview

```
┌──────────────────────────────────────────────────────────────┐
│                   Claude Code Runtime                         │
│                                                               │
│  [Available Skills List]  ←  name + description (always)    │
│         ↓ (when triggered)                                    │
│  [SKILL.md body loaded into context]                          │
│         ↓ (when referenced in SKILL.md)                       │
│  [references/*.md loaded on demand]                           │
│         ↓ (executed, not read)                                │
│  [scripts/* run via Bash tool]                                │
└──────────────────────────────────────────────────────────────┘
         │ commands
         ▼
┌──────────────────────────────────────────────────────────────┐
│              playwright-cli (external binary)                 │
│  npx playwright snapshot / click / fill / console / network  │
└──────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Notes |
|-----------|----------------|-------|
| YAML frontmatter (name + description) | Triggering — the only part always in context | Primary lever for "does the skill activate?" |
| SKILL.md body | Protocol instructions — the 5-step workflow, NEVER/ALWAYS rules | Loaded when skill triggers; keep under 500 lines |
| references/playwright-cli-commands.md | Full command reference for playwright-cli | Loaded on demand; can be large (>300 lines with TOC) |
| evals/evals.json | Test cases + assertions for skill validation | Used by skill-creator eval loop; not loaded at runtime |
| scripts/ (optional) | Deterministic helper scripts bundled with the skill | Executed without being read; saves every run from reinventing |
| assets/ (optional) | Templates, icons, static files returned as output | Included in packaged .skill file |

## Recommended Project Structure

```
~/.claude/skills/playwright-testing/
├── SKILL.md                          # Required — frontmatter + protocol body
│   ├── --- YAML frontmatter ---      # name, description (triggers)
│   └── Markdown protocol body        # 5-step workflow, NEVER/ALWAYS rules
├── references/
│   └── playwright-cli-commands.md   # Full CLI reference, downloaded from Microsoft repo
└── evals/
    └── evals.json                    # Test cases: prompts + assertions
```

### What each file contains

**SKILL.md frontmatter** (the critical part):
```yaml
---
name: playwright-testing
description: |
  [When to trigger AND what it does — include both.
   Must be "pushy": mention all contexts where it should fire.
   Claude undertriggers skills — be explicit about every scenario.]
---
```

**SKILL.md body** (protocol instructions):
- The 5-step diagnostic workflow (snapshot → reproduce → console+network → fix → re-test)
- NEVER rules: never use curl, Playwright MCP, ad-hoc Node scripts for browser work
- ALWAYS rules: always use --session=<project-name>, always check .env before asking for credentials
- Reference pointer: "For full command syntax, read references/playwright-cli-commands.md"

**references/playwright-cli-commands.md** (loaded on demand):
- Must include a table of contents (>300 lines requires TOC per skill-creator guidelines)
- Contains all playwright-cli subcommands, flags, output formats
- Sourced from Microsoft's official playwright-cli repo SKILL.md

**evals/evals.json** (eval-time only, not runtime):
- 5+ test case prompts covering different trigger scenarios
- Per-assertion checks (id, text fields)
- Used only when running skill-creator eval loop

### Structure Rationale

- **SKILL.md body under 500 lines:** Loaded into context on every invocation. Heavier = more tokens burned per use.
- **references/ separate from body:** Command details are looked up, not memorized. Separation keeps the main skill concise.
- **evals/ not loaded at runtime:** Pure development artifact. Never referenced by SKILL.md body.
- **No scripts/ needed for this skill:** playwright-cli is the external tool; there are no deterministic helper scripts to bundle.

## Architectural Patterns

### Pattern 1: Progressive Disclosure Loading

**What:** The skill runtime loads context in three tiers: metadata always, body on trigger, references on demand.

**When to use:** Any time reference content is large (>300 lines) or domain-specific (e.g., a full CLI man page). The SKILL.md body tells Claude when and why to read the reference file.

**Trade-offs:** Requires SKILL.md body to explicitly instruct Claude to read the reference. If the pointer is vague, Claude may skip it.

**Example pointer in SKILL.md body:**
```markdown
## Command Reference

For full playwright-cli syntax (snapshot, click, fill, console, network flags),
read `references/playwright-cli-commands.md`. Read it before composing any
playwright-cli command you are unsure about.
```

### Pattern 2: Description as the Primary Trigger

**What:** The `description` field in YAML frontmatter is the sole signal Claude uses to decide whether to load the skill. It must describe both what the skill does AND when to invoke it.

**When to use:** Always. There is no secondary trigger mechanism.

**Trade-offs:** Too narrow = undertriggering (skill never fires). Too broad = overtriggering (skill loads when irrelevant, burning context tokens).

**The "pushy" heuristic (from skill-creator):** Because Claude has a structural tendency to undertrigger skills, descriptions must enumerate contexts explicitly. "Use this when the user mentions X, Y, Z, or anything involving the browser" outperforms "use for browser automation."

**Example for playwright-testing:**
```yaml
description: |
  Establishes a mandatory browser testing protocol using playwright-cli.
  Use whenever the user needs to: interact with a web browser, debug a
  frontend issue, test a user flow, fill a form, check for console errors,
  verify that a UI element works, take a screenshot, or reproduce a bug
  seen in a browser. Also use when the user mentions playwright, Cypress,
  Selenium, or any end-to-end testing. Do NOT use curl, Playwright MCP
  server, or ad-hoc Node.js scripts for browser tasks.
```

### Pattern 3: NEVER/ALWAYS Rules for Tool Replacement

**What:** When a skill enforces replacement of a default tool/pattern, explicit NEVER and ALWAYS directives reduce ambiguity.

**When to use:** Skills that change how Claude approaches an entire category of task. Without explicit prohibition, Claude defaults to its training behavior (curl, MCP, etc.).

**Trade-offs:** Heavy use of all-caps directives can make skills feel rigid. The skill-creator philosophy suggests explaining WHY, not just WHAT — this leads to better generalization across unforeseen edge cases.

**Pattern:**
```markdown
## Rules

NEVER use:
- curl to interact with browser-rendered pages
- Playwright MCP server (@playwright/mcp) when playwright-cli is available
- Ad-hoc Node.js scripts to automate browser tasks

ALWAYS use:
- `npx playwright <command>` as the single entry point
- `--session=<project-name>` to persist browser state
```

## Data Flow

### Trigger and Execution Flow

```
User prompt
    ↓
Claude evaluates available_skills list
(only name + description in context)
    ↓
Description match? → YES → SKILL.md body loaded into context
                  → NO  → skill ignored
    ↓
Claude follows protocol in SKILL.md body
    ↓
Protocol step requires command details?
    → YES → Read references/playwright-cli-commands.md
    → NO  → Execute directly
    ↓
Bash tool: npx playwright <command> --session=<project>
    ↓
playwright-cli executes against real browser
    ↓
Output (snapshot, console log, screenshot) returned to Claude
    ↓
Claude follows next protocol step (diagnose → fix → re-test)
```

### Eval Loop Data Flow (development-time only)

```
evals/evals.json (prompts + assertions)
    ↓
skill-creator spawns subagents:
  [with_skill run]  vs  [without_skill / old_skill run]
    ↓
<workspace>/iteration-N/eval-<ID>/with_skill/outputs/
    ↓
grader.md agent reads outputs + transcript
    ↓
grading.json (passed/failed per assertion)
    ↓
scripts/aggregate_benchmark.py → benchmark.json
    ↓
eval-viewer/generate_review.py → browser UI for human review
    ↓
feedback.json → next iteration of SKILL.md
```

### Description Optimization Flow (development-time only)

```
SKILL.md frontmatter description (initial)
    ↓
skill-creator generates 20 trigger eval queries
(8-10 should-trigger, 8-10 should-not-trigger)
    ↓
scripts/run_loop.py:
  - 60% train / 40% held-out test split
  - Run each query 3x for reliable trigger rate
  - Claude proposes description improvements
  - Re-evaluate on train + test
  - 5 iterations max
    ↓
best_description (selected by test score, not train)
    ↓
Updated SKILL.md frontmatter
```

## Build Order (What Depends on What)

```
1. playwright-cli-commands.md (reference)
   └── No dependencies — can be drafted/downloaded first

2. SKILL.md body (protocol)
   └── Depends on: knowing what playwright-cli commands exist
   └── Informs: what to put in evals

3. YAML frontmatter description (trigger)
   └── Can be drafted with SKILL.md body
   └── Optimized LAST with run_loop.py (needs eval queries first)

4. evals/evals.json (test cases)
   └── Depends on: SKILL.md body (need to know what to test)
   └── Required before: any eval run or description optimization

5. Description optimization (run_loop.py)
   └── Depends on: evals/evals.json + installed skill
   └── Final step — don't run until skill content is stable
```

**Critical dependency:** The description cannot be optimized before evals exist. Evals cannot be written before the protocol body exists. The reference file is the only artifact that can be prepared in parallel with everything else.

## Scaling Considerations

This is a single-file skill, not a multi-user service. "Scaling" means: how does the skill stay maintainable as playwright-cli evolves?

| Concern | Approach |
|---------|----------|
| playwright-cli command changes | Reference file is the single point of update; SKILL.md body is stable |
| New trigger contexts discovered | Update description + re-run description optimization loop |
| Protocol improvements from field use | Edit SKILL.md body + re-run evals to verify no regression |
| Multiple browser tool variants | Add references/playwright-mcp-commands.md as separate variant file |

## Anti-Patterns

### Anti-Pattern 1: Embedding the Full Command Reference in SKILL.md Body

**What people do:** Paste the entire CLI man page directly into the SKILL.md body to "make sure Claude has it."

**Why it's wrong:** Every invocation burns those tokens. The body is always loaded. A 500-line body of pure command flags wastes context on every trigger, including triggers where the user just says "check if the login page loads."

**Do this instead:** Keep the body to protocol steps (<300 lines), put commands in `references/playwright-cli-commands.md`, and add an explicit pointer to read it when command syntax is needed.

### Anti-Pattern 2: Description That Only Describes, Not Triggers

**What people do:** Write a description like "Playwright testing protocol for browser automation."

**Why it's wrong:** Claude undertriggers skills structurally. A short, accurate description will fire only when the user explicitly mentions playwright. Bug reports ("the login button is broken"), feature requests ("can you check if the form submits correctly"), and any frontend debugging will miss the skill.

**Do this instead:** Enumerate every context where the skill should fire. Be explicit about adjacent scenarios (debugging frontend issues, verifying UI flows, checking console errors, reproducing browser bugs).

### Anti-Pattern 3: Writing Evals After the Skill Is "Done"

**What people do:** Ship the skill, then add evals later "if time allows."

**Why it's wrong:** Without evals, description optimization (run_loop.py) cannot run. Without a trigger eval set, you have no way to measure whether the description actually fires in real scenarios. The skill may look correct but undertrigger systematically.

**Do this instead:** Write 5+ test cases (prompts + assertions) before the first eval run. The skill-creator process treats this as part of the creation loop, not a separate QA phase.

### Anti-Pattern 4: Single NEVER Rule Without Explaining Why

**What people do:** "NEVER use curl." Full stop.

**Why it's wrong:** Claude generalizes from reasoning, not from bans. If a scenario arises that isn't covered by the rule literally, the model falls back to default behavior. The why is the actual instruction.

**Do this instead:** "Use playwright-cli instead of curl for browser-rendered pages because curl cannot execute JavaScript, handle cookies, or capture console errors — all of which are required for reliable frontend debugging."

## Integration Points

### External Tool Boundary

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Claude → playwright-cli | Bash tool: `npx playwright <command>` | playwright-cli must be globally installed (`npm install -g @playwright/mcp@latest`) |
| playwright-cli → browser | Managed internally by the tool | Uses Chromium; sessions persisted by `--session=<name>` |
| SKILL.md → references/ | Read tool, triggered by explicit pointer in body | Claude decides when to read based on need |
| skill-creator → evals | reads `evals/evals.json` + spawns subagents | Only during development; not at runtime |

### Skill Installation Boundary

The skill lives at `~/.claude/skills/playwright-testing/` (global). This makes it available in every project without per-project configuration. The tradeoff is that the skill cannot be project-scoped — it fires for all browser interactions everywhere. This is intentional per the project's "scope universal" requirement.

## Sources

- `/home/sanchez/.claude/skills/skill-creator/SKILL.md` — Definitive source on skill anatomy, progressive disclosure, description optimization, eval loop (HIGH confidence)
- `/home/sanchez/.claude/skills/skill-creator/references/schemas.md` — JSON schemas for evals.json, grading.json, benchmark.json (HIGH confidence)
- `/home/sanchez/.claude/skills/git-pushear/` — Live example of a skill with evals/ (HIGH confidence)
- `/home/sanchez/.claude/skills/ui-ux-pro-max/` — Live example of a skill with data/ (reference variant) (HIGH confidence)
- `/home/sanchez/proyectos/claude-code-skill-proyecto-playwright-cli/.planning/PROJECT.md` — Project requirements and constraints (HIGH confidence)

---
*Architecture research for: Claude Code skill wrapping playwright-cli CLI workflow*
*Researched: 2026-03-17*
