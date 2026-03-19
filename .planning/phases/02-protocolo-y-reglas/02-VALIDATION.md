---
phase: 2
slug: protocolo-y-reglas
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-19
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | grep + wc (no test framework — skill content validation) |
| **Config file** | none — structural checks only |
| **Quick run command** | `wc -l ~/.claude/skills/playwright-testing/SKILL.md` |
| **Full suite command** | `wc -l ~/.claude/skills/playwright-testing/SKILL.md && grep -c "Paso" ~/.claude/skills/playwright-testing/SKILL.md && grep -c "NUNCA\|SIEMPRE" ~/.claude/skills/playwright-testing/SKILL.md` |
| **Estimated runtime** | ~1 second |

---

## Sampling Rate

- **After every task commit:** Run `wc -l ~/.claude/skills/playwright-testing/SKILL.md`
- **After every plan wave:** Run full suite command
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 1 second

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | PROTO-01 to PROTO-09 | automated | `grep -c "Paso" ~/.claude/skills/playwright-testing/SKILL.md` (expect 5) | ✅ | ⬜ pending |
| 02-01-02 | 01 | 1 | PROTO-06 | automated | `grep "\.env\.local" ~/.claude/skills/playwright-testing/SKILL.md` | ✅ | ⬜ pending |
| 02-01-03 | 01 | 1 | PROTO-07,PROTO-08 | automated | `grep -c "\-s=" ~/.claude/skills/playwright-testing/SKILL.md` (expect ≥1) | ✅ | ⬜ pending |
| 02-02-01 | 02 | 1 | RULE-01 to RULE-06 | automated | `grep -c "NUNCA\|SIEMPRE" ~/.claude/skills/playwright-testing/SKILL.md` (expect ≥6) | ✅ | ⬜ pending |
| 02-02-02 | 02 | 1 | TRIG-01 to TRIG-03 | automated | `grep -c "trigger\|Trigger" ~/.claude/skills/playwright-testing/SKILL.md` (expect ≥1) | ✅ | ⬜ pending |
| 02-02-03 | 02 | 1 | TRIG-04 | automated | `grep -c "NO usar" ~/.claude/skills/playwright-testing/SKILL.md` (expect ≥3) | ✅ | ⬜ pending |
| 02-XX-XX | all | 1 | STRUC-01 | automated | `wc -l ~/.claude/skills/playwright-testing/SKILL.md` (expect < 300) | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

*Existing infrastructure covers all phase requirements.* SKILL.md and references/ already exist from Phase 1.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Cada regla NUNCA/SIEMPRE tiene razón explícita | RULE-01 to RULE-06 | Semantic check — grep can count but not verify reasons are meaningful | Read each rule, verify reason follows the dash |
| Tabla de causa raíz es diagnósticamente útil | PROTO-04 | Content quality requires human judgment | Verify table maps symptoms to causes correctly |
| References link is correct | PROTO-09 | Path correctness needs context | Verify `references/playwright-cli-commands.md` is referenced and file exists |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 1s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
