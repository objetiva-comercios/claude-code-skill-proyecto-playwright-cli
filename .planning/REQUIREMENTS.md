# Requirements: playwright-testing skill

**Defined:** 2026-03-17
**Core Value:** Claude SIEMPRE usa playwright-cli como único punto de entrada al navegador, con protocolo de diagnóstico estructurado

## v1 Requirements

### Skill Structure

- [x] **STRUC-01**: Skill tiene SKILL.md principal con protocolo completo en < 300 líneas
- [x] **STRUC-02**: Skill tiene references/playwright-cli-commands.md descargado del repo oficial de Microsoft
- [x] **STRUC-03**: Skill instalado globalmente en ~/.claude/skills/playwright-testing/
- [x] **STRUC-04**: Skill creado usando skill-creator (no manualmente)

### Protocol

- [x] **PROTO-01**: Paso 0 — verificar instalación de playwright-cli antes de usarlo
- [x] **PROTO-02**: Paso 1 — buscar credenciales en .env.local → .env.development → .env antes de preguntar al usuario
- [x] **PROTO-03**: Paso 1 — confirmar URL del entorno (dev/staging/prod) antes de abrir el navegador
- [x] **PROTO-04**: Paso 2 — ejecutar snapshot antes de cada interacción significativa
- [x] **PROTO-05**: Paso 2 — usar sessions nombradas por proyecto con --session=<nombre>
- [x] **PROTO-06**: Paso 3 — ejecutar console + network obligatoriamente ante cualquier error
- [x] **PROTO-07**: Paso 3 — identificar causa raíz (401/403, 500, error JS, bug UI puro) y mostrar resumen
- [x] **PROTO-08**: Paso 4 — corregir código y mostrar diff de cambios
- [x] **PROTO-09**: Paso 5 — re-test del flujo completo desde Paso 2 para confirmar fix

### Rules

- [x] **RULE-01**: Regla NUNCA para curl/wget en interacciones de browser (con razón: no da console/network/estado)
- [x] **RULE-02**: Regla NUNCA para Playwright MCP server (con razón: 4x más tokens, menos control)
- [x] **RULE-03**: Regla NUNCA para @playwright/test o scripts ad-hoc de Node.js (con razón: playwright-cli es suficiente)
- [x] **RULE-04**: Regla NUNCA para asumir credenciales sin verificar .env (con razón: credenciales incorrectas = diagnóstico falso)
- [x] **RULE-05**: Regla SIEMPRE snapshot antes de interactuar (con razón: sin snapshot no hay refs disponibles)
- [x] **RULE-06**: Regla SIEMPRE console + network ante error (con razón: diagnóstico incompleto sin ambos)

### Triggers

- [x] **TRIG-01**: Description del frontmatter activa el skill ante bugs de frontend, formularios rotos, errores visuales
- [x] **TRIG-02**: Description activa el skill ante verificación de flujos web (login, CRUD, navegación)
- [x] **TRIG-03**: Description activa el skill ante CUALQUIER interacción necesaria con el navegador web
- [x] **TRIG-04**: Skill NO se activa para API testing sin frontend, unit tests, queries DB

### Validation

- [x] **EVAL-01**: evals/evals.json con 5 test cases del PRD (error al guardar, login, CRUD sin credenciales, 403, botón sin respuesta)
- [x] **EVAL-02**: Test cases incluyen prompts ambiguos que no mencionan "playwright" explícitamente
- [x] **EVAL-03**: Assertions verifican: herramienta correcta, session nombrada, snapshot primero, diagnóstico completo, credenciales, ciclo completo
- [x] **EVAL-04**: Description optimizada via skill-creator run_loop.py con trigger rate >80%

## v2 Requirements

### Advanced Features

- **ADV-01**: Storage state (state-save/state-load) para preservar sesión entre conversations
- **ADV-02**: Comparación de tokens playwright-cli vs MCP en output de diagnóstico
- **ADV-03**: Checklist de verificación post-fix antes de cerrar ciclo

## Out of Scope

| Feature | Reason |
|---------|--------|
| Generación de scripts @playwright/test para CI/CD | Herramienta distinta, otro propósito |
| Testing de APIs con curl | Sin frontend involucrado, curl está bien |
| Unit tests con Jest/Vitest | Herramientas distintas, no browser |
| Queries directas a base de datos | Sin interacción con browser |
| Screenshots guardados en disco | Uso interno solamente, snapshot es suficiente |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| STRUC-01 | Phase 1 | Complete (01-02) |
| STRUC-02 | Phase 1 | Complete (01-01) |
| STRUC-03 | Phase 1 | Complete (01-01) |
| STRUC-04 | Phase 1 | Complete (01-02) |
| PROTO-01 | Phase 2 | Complete |
| PROTO-02 | Phase 2 | Complete |
| PROTO-03 | Phase 2 | Complete |
| PROTO-04 | Phase 2 | Complete |
| PROTO-05 | Phase 2 | Complete |
| PROTO-06 | Phase 2 | Complete |
| PROTO-07 | Phase 2 | Complete |
| PROTO-08 | Phase 2 | Complete |
| PROTO-09 | Phase 2 | Complete |
| RULE-01 | Phase 2 | Complete |
| RULE-02 | Phase 2 | Complete |
| RULE-03 | Phase 2 | Complete |
| RULE-04 | Phase 2 | Complete |
| RULE-05 | Phase 2 | Complete |
| RULE-06 | Phase 2 | Complete |
| TRIG-01 | Phase 2 | Complete |
| TRIG-02 | Phase 2 | Complete |
| TRIG-03 | Phase 2 | Complete |
| TRIG-04 | Phase 2 | Complete |
| EVAL-01 | Phase 3 | Complete |
| EVAL-02 | Phase 3 | Complete |
| EVAL-03 | Phase 3 | Complete |
| EVAL-04 | Phase 3 | Complete |

**Coverage:**
- v1 requirements: 27 total
- Mapped to phases: 27
- Unmapped: 0

---
*Requirements defined: 2026-03-17*
*Last updated: 2026-03-18 after plan 01-02 execution (STRUC-01, STRUC-04 complete — Phase 1 completa)*
