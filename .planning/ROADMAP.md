# Roadmap: playwright-testing skill

## Overview

Construir el skill global `playwright-testing` que reemplaza los defaults de Claude (curl, Playwright MCP, scripts ad-hoc) con un protocolo de 5 pasos usando `playwright-cli`. El recorrido va de cero a un skill instalado globalmente con protocolo verificado y trigger rate medido: primero la estructura base creada con skill-creator, luego el protocolo completo con reglas y triggers, finalmente las evals y la optimizacion de descripcion hasta superar el 80% de trigger rate.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marcados con INSERTED)

- [ ] **Phase 1: Estructura Base** - Skill scaffolding creado con skill-creator, referencia oficial descargada, instalado globalmente
- [ ] **Phase 2: Protocolo y Reglas** - Protocolo de 5 pasos completo, reglas NUNCA/SIEMPRE con razones, triggers y boundaries definidos
- [ ] **Phase 3: Evals y Optimizacion** - 5 test cases con assertions, descripcion optimizada con trigger rate >80%

## Phase Details

### Phase 1: Estructura Base
**Goal**: El skill existe como directorio instalado globalmente en `~/.claude/skills/playwright-testing/` con la estructura correcta y la referencia oficial de comandos disponible
**Depends on**: Nothing (primera fase)
**Requirements**: STRUC-01, STRUC-02, STRUC-03, STRUC-04
**Success Criteria** (what must be TRUE):
  1. El directorio `~/.claude/skills/playwright-testing/` existe con SKILL.md, references/ y evals/
  2. `references/playwright-cli-commands.md` contiene la referencia descargada del repo oficial de Microsoft (no escrita de memoria)
  3. El SKILL.md fue generado usando skill-creator (evidencia en el proceso, no escrito manualmente)
  4. Claude Code reconoce el skill al preguntar "What skills are available?"
**Plans**: 2 plans

Plans:
- [ ] 01-01-PLAN.md — Crear estructura de directorios y descargar referencia oficial de comandos de Microsoft
- [ ] 01-02-PLAN.md — Generar SKILL.md con skill-creator y verificar reconocimiento por Claude Code

### Phase 2: Protocolo y Reglas
**Goal**: El SKILL.md contiene el protocolo completo de 5 pasos operativo, todas las reglas NUNCA/SIEMPRE con sus razones, el manejo de credenciales y sessions, y los triggers y boundaries definidos — todo en menos de 300 lineas
**Depends on**: Phase 1
**Requirements**: PROTO-01, PROTO-02, PROTO-03, PROTO-04, PROTO-05, PROTO-06, PROTO-07, PROTO-08, PROTO-09, RULE-01, RULE-02, RULE-03, RULE-04, RULE-05, RULE-06, TRIG-01, TRIG-02, TRIG-03, TRIG-04
**Success Criteria** (what must be TRUE):
  1. El SKILL.md tiene exactamente 5 pasos numerados: verificar instalacion → credenciales/URL → snapshot + session nombrada → console/network ante error → fix + re-test
  2. Cada regla NUNCA/SIEMPRE incluye la razon explicita de por que violarla rompe el diagnostico
  3. El protocolo de credenciales busca `.env.local` → `.env.development` → `.env` antes de preguntar al usuario
  4. El SKILL.md tiene menos de 300 lineas y referencia `references/playwright-cli-commands.md` para syntax detallada
  5. Los boundaries explicitos listan cuando NO usar el skill (API testing sin frontend, unit tests, queries DB)
**Plans**: TBD

Plans:
- [ ] 02-01: Escribir protocolo de 5 pasos con manejo de credenciales y sessions nombradas en SKILL.md via skill-creator
- [ ] 02-02: Agregar reglas NUNCA/SIEMPRE con razones y definir triggers y boundaries en SKILL.md

### Phase 3: Evals y Optimizacion
**Goal**: El skill tiene 5 test cases con assertions que miden la calidad del triggering, y la descripcion del frontmatter fue optimizada con `skill-creator run_loop.py` hasta alcanzar trigger rate >80%
**Depends on**: Phase 2
**Requirements**: EVAL-01, EVAL-02, EVAL-03, EVAL-04
**Success Criteria** (what must be TRUE):
  1. `evals/evals.json` tiene 5 test cases que incluyen prompts ambiguos sin mencionar "playwright" (ej: "el boton no responde", "no puedo hacer login")
  2. Cada test case tiene assertions que verifican: herramienta correcta, session nombrada, snapshot primero, diagnostico console+network, credenciales buscadas, ciclo completo
  3. `skill-creator run_loop.py` corre sin errores y produce un `grading.json` con trigger rate medido
  4. La descripcion del frontmatter supera el 80% de trigger rate en el benchmark de skill-creator
**Plans**: TBD

Plans:
- [ ] 03-01: Crear evals/evals.json con 5 test cases usando prompts ambiguos y assertions completas
- [ ] 03-02: Correr run_loop.py con skill-creator y optimizar descripcion hasta >80% trigger rate

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Estructura Base | 0/2 | Not started | - |
| 2. Protocolo y Reglas | 0/2 | Not started | - |
| 3. Evals y Optimizacion | 0/2 | Not started | - |
