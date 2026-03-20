# Phase 3: Evals y Optimización - Context

**Gathered:** 2026-03-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Crear evals de calidad y trigger rate para el skill playwright-testing, y optimizar la description del frontmatter con `skill-creator run_loop.py` hasta alcanzar trigger rate >80%. El SKILL.md ya está completo (protocolo, reglas, triggers) — esta fase solo agrega evals y optimiza la description.

</domain>

<decisions>
## Implementation Decisions

### Test cases (5 positivos)
- Los 5 escenarios del ROADMAP: error al guardar formulario, login roto, CRUD sin credenciales, 403 forbidden, botón sin respuesta
- Prompts en español, nivel "usuario típico" — como hablaría alguien que no sabe de playwright
- NUNCA mencionar "playwright" ni "testing" explícitamente en los prompts (EVAL-02)
- Ejemplos de tono: "el formulario no guarda", "no puedo hacer login", "me da 403 al entrar"

### Assertions por test case
- Solo las assertions que aplican al escenario (no todas en cada test)
- Cada test tiene 3-5 assertions relevantes
- Verificación sobre el output textual (transcript), no sobre ejecución real de comandos
- 4 niveles de assertion disponibles:
  1. **Herramienta correcta**: transcript menciona playwright-cli, no curl/MCP/scripts
  2. **Protocolo completo**: session nombrada (-s=nombre), snapshot antes de interactuar, console+network ante error, ciclo re-test
  3. **Credenciales buscadas**: buscó en .env antes de preguntar (solo en casos con auth)
  4. **Diagnóstico correcto**: identificó causa raíz según la tabla (401→credenciales, 500→backend, etc.)

### Formato de evals (dos archivos)
- **evals/evals.json**: 5 quality evals con formato skill-creator (prompt, expected_output, expectations) — mide si el skill produce el output correcto
- **evals/trigger_evals.json**: 8 trigger rate evals para run_loop.py (query + should_trigger) — 5 positivos (mismos escenarios) + 3 negativos
- Los 3 negativos (should_trigger: false): "corré los unit tests", "hace un curl a la API de pagos", "ejecutá esta query SQL" — los 3 boundaries del skill

### Estrategia de optimización
- Correr run_loop.py con máximo 5 iteraciones
- Si el mejor resultado es 70%+, aceptar y documentar. Si es <70%, revisar evals antes de reintentar
- Sin límite de largo para la description — run_loop puede alargarla o acortarla libremente
- Si supera 80% (o es el mejor tras 5 iteraciones), reescribir la description en SKILL.md automáticamente

### Claude's Discretion
- Redacción exacta de cada prompt (respetando tono "usuario típico" en español)
- Redacción exacta de cada expectation/assertion
- Estructura interna de los archivos JSON
- Número de runs_per_query para run_loop.py
- Modelo a usar para las evals (sonnet vs haiku)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Skill actual
- `~/.claude/skills/playwright-testing/SKILL.md` — Skill completo con protocolo, reglas y triggers (Phase 2 output)
- `~/.claude/skills/playwright-testing/references/playwright-cli-commands.md` — Referencia oficial de comandos

### skill-creator (herramienta obligatoria)
- `~/.claude/skills/skill-creator/references/schemas.md` — Schemas de evals.json, grading.json, benchmark.json
- `~/.claude/skills/skill-creator/scripts/run_loop.py` — Script de optimización de trigger rate (formato: lista de {query, should_trigger})
- `~/.claude/skills/skill-creator/scripts/run_eval.py` — Script de evaluación individual

### Requirements
- `.planning/REQUIREMENTS.md` §Validation (EVAL-01 a EVAL-04) — Los 4 requirements de esta fase

### Contexto previo
- `.planning/phases/02-protocolo-y-reglas/02-CONTEXT.md` — Decisiones de Phase 2 (protocolo, reglas, sessions)
- `.planning/PROJECT.md` — Constraints: skill-creator obligatorio

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- SKILL.md completo (100 líneas): protocolo de 5 pasos, 7 reglas, triggers y boundaries — las evals verifican que este contenido se sigue
- evals/ directorio existe con .gitkeep — listo para recibir evals.json y trigger_evals.json
- skill-creator run_loop.py: loop automático de eval + improve description

### Established Patterns
- run_loop.py espera formato lista plana: `[{"query": "...", "should_trigger": true/false}]`
- evals.json espera formato skill-creator: `{"skill_name": "...", "evals": [{"id": N, "prompt": "...", "expected_output": "...", "expectations": [...]}]}`
- Dos formatos distintos, dos propósitos distintos

### Integration Points
- `~/.claude/skills/playwright-testing/evals/evals.json` — quality evals
- `~/.claude/skills/playwright-testing/evals/trigger_evals.json` — trigger rate evals para run_loop.py
- run_loop.py reescribe la description en SKILL.md al encontrar una mejor

</code_context>

<specifics>
## Specific Ideas

- Los prompts deben sonar como un usuario frustrado hablando en español: "el formulario no guarda", "me tira 403", "el botón no hace nada"
- El caso "CRUD sin credenciales" es especialmente interesante porque combina auth + flujo funcional
- Los 3 negativos cubren exactamente los 3 boundaries del skill: unit tests, API sin frontend, queries DB

</specifics>

<deferred>
## Deferred Ideas

- README.md del repo — después de Phase 3 con skill completo (de Phase 1 deferred)
- DEPLOY.md del repo — después de Phase 3 con skill completo (de Phase 1 deferred)

</deferred>

---

*Phase: 03-evals-y-optimizacion*
*Context gathered: 2026-03-19*
