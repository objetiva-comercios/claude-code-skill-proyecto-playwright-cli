---
phase: 1
slug: estructura-base
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-18
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual verification (no automated test framework for Claude Code skills) |
| **Config file** | none |
| **Quick run command** | `ls ~/.claude/skills/playwright-testing/SKILL.md` |
| **Full suite command** | `ls -la ~/.claude/skills/playwright-testing/ && head -10 ~/.claude/skills/playwright-testing/SKILL.md` |
| **Estimated runtime** | ~2 seconds |

---

## Sampling Rate

- **After every task commit:** Run `ls -la ~/.claude/skills/playwright-testing/`
- **After every plan wave:** Run `ls ~/.claude/skills/playwright-testing/ && head -10 ~/.claude/skills/playwright-testing/SKILL.md`
- **Before `/gsd:verify-work`:** Full suite must be green + manual confirmation Claude Code lists the skill
- **Max feedback latency:** 2 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | STRUC-02 | smoke | `ls ~/.claude/skills/playwright-testing/references/playwright-cli-commands.md && grep "playwright" ~/.claude/skills/playwright-testing/references/playwright-cli-commands.md \| head -3` | ❌ W0 | ⬜ pending |
| 01-02-01 | 02 | 1 | STRUC-01, STRUC-03 | smoke | `ls ~/.claude/skills/playwright-testing/SKILL.md && head -5 ~/.claude/skills/playwright-testing/SKILL.md` | ❌ W0 | ⬜ pending |
| 01-02-02 | 02 | 1 | STRUC-04 | manual | Review execution transcript for skill-creator usage | manual-only | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `~/.claude/skills/playwright-testing/` — directory to create
- [ ] `~/.claude/skills/playwright-testing/references/` — subdirectory for reference docs
- [ ] `~/.claude/skills/playwright-testing/evals/` — subdirectory for future test cases

*Wave 0 is implicit in the plans — directory creation is part of the first tasks.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| skill-creator was used to generate SKILL.md | STRUC-04 | Process verification, not file content | Review execution logs for `/skill-creator` invocation |
| Claude Code recognizes the skill | STRUC-01 | Requires interactive Claude Code session | Ask Claude Code "What skills are available?" and verify playwright-testing appears |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 2s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
