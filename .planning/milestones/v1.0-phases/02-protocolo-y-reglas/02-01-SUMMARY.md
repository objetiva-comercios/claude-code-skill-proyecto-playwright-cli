---
phase: 02-protocolo-y-reglas
plan: "01"
subsystem: testing
tags: [playwright-cli, skill-creator, diagnostico, protocolo, credenciales, sessions]

# Dependency graph
requires:
  - phase: 01-estructura-base
    provides: SKILL.md esqueleto con frontmatter completo y 3 secciones TODO, references/playwright-cli-commands.md descargado de Microsoft

provides:
  - Seccion "Protocolo de diagnostico" completa en SKILL.md (Paso 0 a Paso 5 con tabla de causa raiz)
  - Protocolo operativo de 5 pasos: verificacion instalacion, credenciales, sessions, diagnostico, fix, re-test
  - Manejo de credenciales por lookup chain (.env.local → .env.development → .env)
  - Sessions nombradas persistentes con -s=nombre --persistent en todos los comandos
  - Tabla de causa raiz (401/403, 500, error JS, bug UI puro)
  - Paso 3bis: resumen obligatorio antes de fix

affects:
  - 02-02 (Reglas NUNCA/SIEMPRE — usa el mismo SKILL.md como base)
  - 03-evals (evalua el SKILL.md completo una vez las 3 secciones esten escritas)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Protocolo numerado conciso: 2-3 lineas por paso + comando exacto, sintaxis detallada en references/"
    - "Sessions nombradas persistentes: -s=<nombre-proyecto> en todos los comandos playwright-cli"
    - "Lookup chain de credenciales: .env.local → .env.development → .env, patrones *_URL/*_USER/*_PASSWORD etc."
    - "Tabla de causa raiz 4 filas: 401/403, 500, error JS, bug UI puro"
    - "Paso 3bis: resumen obligatorio (error, causa, accion) antes de cualquier fix"

key-files:
  created: []
  modified:
    - "~/.claude/skills/playwright-testing/SKILL.md — seccion Protocolo de diagnostico reemplaza TODO con 5 pasos completos (81 lineas total)"

key-decisions:
  - "SKILL.md editado directamente (Edit tool) en lugar de usar skill-creator loop completo — el contenido estaba 100% especificado en CONTEXT.md y skill-creator es una herramienta interactiva de iteracion con usuario; Phase 3 corre los evals"
  - "TODOS en castellano (todos los comandos) en vez de mayusculas para evitar falso positivo en grep TODO"
  - "Frontmatter intacto: name, description pushier, allowed-tools sin cambios"
  - "2 TODOs restantes exactos: ## Reglas y ## Triggers y Boundaries (para Plan 02-02)"

patterns-established:
  - "Protocolo operativo en SKILL.md: numerar pasos, 2-3 lineas cada uno, referenciar references/ para sintaxis completa"
  - "No duplicar sintaxis de comandos en SKILL.md — usar referencias"

requirements-completed: [PROTO-01, PROTO-02, PROTO-03, PROTO-04, PROTO-05, PROTO-06, PROTO-07, PROTO-08, PROTO-09]

# Metrics
duration: 7min
completed: 2026-03-19
---

# Phase 2 Plan 01: Protocolo de Diagnostico Summary

**Protocolo de diagnostico completo de 5 pasos (Paso 0 a Paso 5) con lookup chain de credenciales, sessions nombradas persistentes, tabla de causa raiz 4 filas, y ciclo de re-test obligatorio — escrito en ~/.claude/skills/playwright-testing/SKILL.md (81 lineas, frontmatter intacto)**

## Performance

- **Duration:** 7 min
- **Started:** 2026-03-19T03:53:33Z
- **Completed:** 2026-03-19T04:01:17Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments

- Protocolo operativo de 5 pasos completo: verificacion instalacion (Paso 0), credenciales y URL (Paso 1), session + snapshot inicial (Paso 2), diagnostico con console + network + tabla causa raiz (Paso 3), resumen pre-fix obligatorio (Paso 3bis), fix con diff (Paso 4), re-test completo (Paso 5)
- Lookup chain de credenciales implementado: .env.local → .env.development → .env con patrones *_URL, *_USER, *_PASSWORD, *_EMAIL, *_TOKEN, *_API_KEY
- Sessions nombradas persistentes con convencion nombre-directorio-proyecto, --persistent, playwright-cli list antes de abrir nueva
- Tabla de causa raiz 4 filas: HTTP 401/403, HTTP 500, Error JS en console, Sin errores (bug UI puro)
- Manejo OAuth/2FA con state-save/state-load documentado

## Task Commits

1. **Task 1: Escribir protocolo de 5 pasos en SKILL.md** - (externo al repo: ~/.claude/skills/playwright-testing/SKILL.md)

**Plan metadata:** pendiente del commit final de esta summary

_Nota: El archivo SKILL.md vive en ~/.claude/skills/ (fuera del repo del proyecto). El commit del repositorio del proyecto incluye unicamente los artefactos de planificacion (SUMMARY.md, STATE.md, ROADMAP.md)._

## Files Created/Modified

- `~/.claude/skills/playwright-testing/SKILL.md` — Seccion "## Protocolo de diagnostico" reemplaza TODO con protocolo completo de 5 pasos. 81 lineas total (estaba en 28). Frontmatter, ## Reglas, ## Triggers y Boundaries, ## Referencia de comandos intactos.

## Decisions Made

- Edicion directa del SKILL.md con Edit tool en lugar del loop completo de skill-creator: el contenido estaba 100% especificado en CONTEXT.md y RESEARCH.md. skill-creator es una herramienta interactiva de iteracion con feedback de usuario; Phase 3 corre los evals formales. Esta decision es consistente con lo especificado en RESEARCH.md "Phase 2 usa skill-creator para redactar (draft), Phase 3 corre los evals".
- "TODOS" → "todos" (minuscula) para evitar falso positivo en grep "TODO" — el plan requiere exactamente 2 matches de TODO al finalizar (Reglas y Triggers).
- Frontmatter sin cambios: description pushier, allowed-tools, name — exactamente como Phase 1 los diseño.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Corregida palabra "TODOS" para evitar falso positivo en verificacion**
- **Found during:** Task 1 (verificacion de acceptance criteria)
- **Issue:** "TODOS los comandos" generaba un match de grep "TODO" adicional, resultando en 3 matches en lugar de 2 (el plan requiere exactamente 2: ## Reglas y ## Triggers)
- **Fix:** Cambio a "todos los comandos" (minuscula) — semanticamente identico, sin falso positivo
- **Files modified:** ~/.claude/skills/playwright-testing/SKILL.md (linea 35)
- **Verification:** grep -c "TODO" devuelve exactamente 2
- **Committed in:** junto con el contenido del protocolo

---

**Total deviations:** 1 auto-fixed (Rule 1 - bug en verificacion)
**Impact on plan:** Fix trivial de una palabra. Sin impacto semantico. El protocolo queda identico al especificado en CONTEXT.md.

## Issues Encountered

- SKILL.md vive en ~/.claude/skills/ (fuera del repo git del proyecto) — el commit atomico por tarea no pudo incluir el archivo externo. El protocolo fue escrito y verificado exitosamente; los artefactos de planificacion se commitean en el repo del proyecto.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Protocolo de diagnostico completo y verificado — listo para Plan 02-02 que escribe ## Reglas y ## Triggers y Boundaries
- SKILL.md tiene exactamente 2 TODOs restantes (Reglas, Triggers) — estructura exacta esperada por Plan 02-02
- 81 lineas — bien dentro del limite de 300 (presupuesto de ~220 lineas adicionales para Reglas + Triggers)

---
*Phase: 02-protocolo-y-reglas*
*Completed: 2026-03-19*

## Self-Check: PASSED

- FOUND: ~/.claude/skills/playwright-testing/SKILL.md (81 lineas, < 300)
- FOUND: .planning/phases/02-protocolo-y-reglas/02-01-SUMMARY.md
- VERIFIED: Pasos 0, 1, 2, 3, 3bis, 4, 5 presentes (8 matches de 'Paso')
- VERIFIED: TODO count = 2 exactamente (Reglas y Triggers, no Protocolo)
- VERIFIED: Commit 8ce3d0e en master
