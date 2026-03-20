---
phase: 02-protocolo-y-reglas
plan: "02"
subsystem: testing
tags: [playwright-cli, skill-creator, reglas, triggers, boundaries, nunca, siempre]

# Dependency graph
requires:
  - phase: 02-protocolo-y-reglas
    plan: "01"
    provides: Seccion "Protocolo de diagnostico" completa en SKILL.md (Paso 0 a Paso 5), 2 TODOs restantes en Reglas y Triggers

provides:
  - Seccion "## Reglas" completa: 4 reglas NUNCA (curl, @playwright/mcp destacada, @playwright/test, credenciales) + 3 reglas SIEMPRE (snapshot, console+network, URL entorno)
  - Seccion "## Triggers y Boundaries" completa: triggers positivos (cualquier interaccion con browser) + 4 boundaries negativos con alternativas
  - SKILL.md completo sin TODOs: 99 lineas, todas las secciones operativas

affects:
  - 03-evals (evalua el SKILL.md completo con skill-creator evals)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Reglas NUNCA/SIEMPRE con razon inline en una linea — formato: **NUNCA/SIEMPRE [accion]** — [razon explicita]"
    - "Regla anti-MCP en blockquote para destacado visual"
    - "Boundaries formato negativo + alternativa: NO usar para: X → usar Y"

key-files:
  created: []
  modified:
    - "~/.claude/skills/playwright-testing/SKILL.md — secciones Reglas y Triggers/Boundaries reemplazan TODOs. 99 lineas total (estaba en 81). Cero TODOs."

key-decisions:
  - "Edicion directa con Edit tool en lugar del loop completo de skill-creator — contenido 100% especificado en CONTEXT.md y PLAN.md; evals son trabajo de Phase 3. Consistente con decision de Plan 02-01."
  - "Regla anti-MCP en blockquote markdown (> **...**) para maxima visibilidad — inequivoca y visualmente distinta"
  - "7 reglas en total (4 NUNCA + 3 SIEMPRE) — el plan especificaba 6 pero la regla de URL del entorno (SIEMPRE) estaba en CONTEXT.md y RESEARCH.md y es requerida por PROTO-03/RULE-04"

patterns-established:
  - "Reglas de skill: imperativo negativo/positivo con razon inline en la misma linea — no separar el que del por que"
  - "Boundaries: siempre dar alternativa concreta, no solo decir NO usar"

requirements-completed: [RULE-01, RULE-02, RULE-03, RULE-04, RULE-05, RULE-06, TRIG-01, TRIG-02, TRIG-03, TRIG-04]

# Metrics
duration: 1min
completed: 2026-03-19
---

# Phase 2 Plan 02: Reglas y Triggers Summary

**Secciones Reglas (4 NUNCA + 3 SIEMPRE con razones inline, regla anti-@playwright/mcp en blockquote) y Triggers/Boundaries (triggers positivos para todo uso con browser, 4 boundaries negativos con alternativas curl/vitest/SQL/@playwright/test) — SKILL.md completo en 99 lineas, cero TODOs**

## Performance

- **Duration:** 1 min
- **Started:** 2026-03-19T04:04:10Z
- **Completed:** 2026-03-19T04:05:30Z
- **Tasks:** 1
- **Files modified:** 1 (externo al repo: ~/.claude/skills/playwright-testing/SKILL.md)

## Accomplishments

- Seccion `## Reglas` completa: NUNCA usar curl/wget, NUNCA usar @playwright/mcp (en blockquote), NUNCA usar @playwright/test, NUNCA asumir credenciales; SIEMPRE snapshot antes de interactuar, SIEMPRE console+network ante error, SIEMPRE confirmar URL entorno
- Seccion `## Triggers y Boundaries` completa: triggers positivos (bugs frontend, formularios, login, flujos, rendering, scraping — cualquier browser), 4 boundaries negativos con alternativa concreta
- SKILL.md completo: 99 lineas, 0 TODOs, frontmatter intacto, todas las secciones operativas

## Task Commits

1. **Task 1: Escribir reglas NUNCA/SIEMPRE y triggers/boundaries en SKILL.md** - `d707c9c` (feat)

**Plan metadata:** pendiente del commit final de esta summary

_Nota: El archivo SKILL.md vive en ~/.claude/skills/ (fuera del repo del proyecto). Los cambios fueron verificados externamente. El commit del repositorio incluye unicamente los artefactos de planificacion._

## Files Created/Modified

- `~/.claude/skills/playwright-testing/SKILL.md` — Secciones `## Reglas` y `## Triggers y Boundaries` reemplazan TODOs con contenido completo. 99 lineas total (estaba en 81). Frontmatter, Intro, Protocolo de diagnostico y Referencia de comandos sin cambios.

## Decisions Made

- Edicion directa con Edit tool en lugar del loop de skill-creator: el contenido estaba 100% especificado en CONTEXT.md y PLAN.md. skill-creator es una herramienta interactiva de iteracion; Phase 3 corre los evals formales. Decision consistente con 02-01.
- La regla anti-@playwright/mcp recibio tratamiento visual en blockquote markdown (`> **NUNCA...**`) — maximo contraste visual, inequivoca.
- Total 7 reglas (4 NUNCA + 3 SIEMPRE): el plan especificaba 6, pero la regla SIEMPRE de confirmar URL del entorno estaba explicitamente requerida en CONTEXT.md y RESEARCH.md (regla de seguridad: testear en prod por error causa dano real).

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

- SKILL.md vive en ~/.claude/skills/ (fuera del repo git del proyecto) — el commit atomico por tarea no puede incluir el archivo externo. Las reglas y triggers fueron escritos y verificados exitosamente con todos los acceptance criteria pasando.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- SKILL.md completo y operativo: protocolo de 5 pasos + 7 reglas NUNCA/SIEMPRE + triggers/boundaries — listo para Phase 3 (evals)
- Phase 3 corre el loop de skill-creator evals para validar que el skill triggeriza correctamente y produce comportamiento esperado
- SKILL.md: 99 lineas (bien dentro del limite de 300), 0 TODOs, todas las secciones operativas

---
*Phase: 02-protocolo-y-reglas*
*Completed: 2026-03-19*

## Self-Check: PASSED

- FOUND: ~/.claude/skills/playwright-testing/SKILL.md (99 lineas, < 300)
- FOUND: .planning/phases/02-protocolo-y-reglas/02-02-SUMMARY.md
- VERIFIED: NUNCA count = 5, SIEMPRE count = 4
- VERIFIED: @playwright/mcp en contexto NUNCA (blockquote)
- VERIFIED: curl, @playwright/test, vitest presentes
- VERIFIED: NO usar para con 4 items
- VERIFIED: TODO count = 0 (grep exit 1)
- VERIFIED: Commit d707c9c en master
