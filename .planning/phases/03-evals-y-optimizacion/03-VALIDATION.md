---
phase: 03
slug: evals-y-optimizacion
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-19
---

# Phase 03 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | skill-creator run_eval.py / run_loop.py (trigger rate evaluation) |
| **Config file** | `~/.claude/skills/playwright-testing/evals/trigger_evals.json` (a crear en Wave 1) |
| **Quick run command** | `cd ~/.claude/skills/skill-creator && python -m scripts.run_eval --eval-set ~/.claude/skills/playwright-testing/evals/trigger_evals.json --skill-path ~/.claude/skills/playwright-testing --model claude-sonnet-4-6 --runs-per-query 1 --verbose` |
| **Full suite command** | `cd ~/.claude/skills/skill-creator && python -m scripts.run_loop --eval-set ~/.claude/skills/playwright-testing/evals/trigger_evals.json --skill-path ~/.claude/skills/playwright-testing --model claude-sonnet-4-6 --max-iterations 5 --runs-per-query 3 --verbose` |
| **Estimated runtime** | ~120 seconds (quick), ~600 seconds (full loop) |

---

## Sampling Rate

- **After every task commit:** Verificar estructura JSON del archivo creado (schema correcto, ids únicos)
- **After every plan wave:** Run `quick run command` para verificar trigger rate parcial
- **Before `/gsd:verify-work`:** Full suite must be green (best_score ≥ 6/8)
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | EVAL-01 | manual | Inspección de evals.json (5 test cases) | ❌ W0 | ⬜ pending |
| 03-01-02 | 01 | 1 | EVAL-02 | automated | `grep -ci "playwright" ~/.claude/skills/playwright-testing/evals/evals.json` (debe dar 0 en prompts) | ❌ W0 | ⬜ pending |
| 03-01-03 | 01 | 1 | EVAL-03 | manual | Inspección de expectations (4 niveles cubiertos) | ❌ W0 | ⬜ pending |
| 03-01-04 | 01 | 1 | EVAL-01 | manual | Inspección de trigger_evals.json (8 entries: 5 true + 3 false) | ❌ W0 | ⬜ pending |
| 03-02-01 | 02 | 2 | EVAL-04 | automated | `cd ~/.claude/skills/skill-creator && python -m scripts.run_loop ...` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `~/.claude/skills/playwright-testing/evals/evals.json` — quality evals (EVAL-01, EVAL-02, EVAL-03)
- [ ] `~/.claude/skills/playwright-testing/evals/trigger_evals.json` — trigger rate evals (EVAL-04)

*Ambos archivos se crean en Wave 1 (Plan 01). Wave 0 no requiere instalación de framework — skill-creator ya existe.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 5 test cases con prompts ambiguos | EVAL-01 | Requiere juicio humano sobre calidad de prompts | Revisar que cada prompt suene como "usuario típico frustrado" |
| Assertions cubren 4 niveles | EVAL-03 | Requiere revisión semántica de expectations | Verificar presencia de: herramienta correcta, protocolo completo, credenciales, diagnóstico |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
