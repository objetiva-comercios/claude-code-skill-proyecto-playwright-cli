# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.0 — MVP

**Shipped:** 2026-03-20
**Phases:** 3 | **Plans:** 8

### What Was Built
- Skill global `playwright-testing` instalado en `~/.claude/skills/playwright-testing/`
- Protocolo de 5 pasos para diagnóstico web con playwright-cli (SKILL.md: 99 líneas)
- Referencia oficial de comandos descargada de microsoft/playwright-cli (278 líneas)
- 7 reglas NUNCA/SIEMPRE con razones explícitas y boundaries definidos
- Suite de evaluación: 5 quality evals + 8 trigger evals con assertions completas

### What Worked
- Separar referencia de comandos en archivo propio mantuvo SKILL.md conciso (99 líneas vs 300 límite)
- Usar skill-creator para scaffolding inicial generó estructura correcta de entrada
- Gap closure en Phase 3 (planes 03-03 y 03-04) capturó y resolvió inconsistencias antes de cerrar
- Edición directa de SKILL.md en Phase 2 fue más eficiente que loop de skill-creator cuando el contenido ya estaba especificado

### What Was Inefficient
- run_loop.py de skill-creator requirió 2 rondas (10 iteraciones) para descubrir que el mecanismo de matching es limitado — se podría haber validado más rápido con un test manual
- SC4 del ROADMAP original (trigger rate >80%) era unrealizable — el mecanismo de skill-matching no responde a prompts casuales sin keywords técnicas

### Patterns Established
- Cuando el contenido del skill está 100% especificado en CONTEXT.md, editar directo > loop skill-creator
- Separar quality evals (evals.json, formato objeto) de trigger evals (trigger_evals.json, formato lista plana)
- Assertions de session y snapshot son universales en todos los evals — nunca opcionales

### Key Lessons
1. El mecanismo de skill-matching de Claude Code requiere keywords técnicas del usuario — prompts casuales ("el botón no anda") no disparan skills automáticamente. Trigger rate 33% es el techo realista.
2. Los success criteria del ROADMAP deben reflejar lo que se puede medir, no aspiraciones. SC4 tuvo que corregirse mid-milestone.

### Cost Observations
- Sessions: ~4-5
- Notable: Phase 1 y 2 fueron rápidas (~15 min y ~8 min), Phase 3 consumió más tiempo por las iteraciones de run_loop.py y gap closure

---

## Cross-Milestone Trends

| Metric | v1.0 |
|--------|------|
| Phases | 3 |
| Plans | 8 |
| Timeline | 2 days |
| Gap closures | 2 plans (03-03, 03-04) |
| SC corrections | 2 (SC3, SC4 in Phase 3) |
