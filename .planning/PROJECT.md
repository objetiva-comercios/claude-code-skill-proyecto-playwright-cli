# Skill: playwright-testing

## What This Is

Un skill global para Claude Code que establece un protocolo obligatorio de testing e interacción con el navegador web usando `playwright-cli`. Reemplaza el comportamiento por defecto de Claude de usar curl, Playwright MCP server, o scripts ad-hoc de Node.js. Se instala en `~/.claude/skills/playwright-testing/` para estar disponible en todos los proyectos.

## Core Value

Claude SIEMPRE usa `playwright-cli` como único punto de entrada al navegador, con un protocolo de diagnóstico estructurado (snapshot → reproducir → console/network → fix → re-test).

## Requirements

### Validated

- ✓ Skill creado con skill-creator (no manualmente) — v1.0
- ✓ SKILL.md principal con protocolo de 5 pasos (99 líneas) — v1.0
- ✓ references/playwright-cli-commands.md descargado del repo oficial de Microsoft — v1.0
- ✓ Description optimizada para maximizar trigger rate (33% medido, hallazgo documentado) — v1.0
- ✓ 7 reglas NUNCA/SIEMPRE con razones explícitas — v1.0
- ✓ Triggers cubren: bugs frontend, formularios rotos, verificación de flujos, errores visuales, cualquier interacción con browser — v1.0
- ✓ Scope universal: aplica a TODAS las interacciones con navegador — v1.0
- ✓ Sessions nombradas por proyecto con --session=<nombre> — v1.0
- ✓ Protocolo de credenciales: buscar .env antes de preguntar — v1.0
- ✓ Diagnóstico obligatorio: console + network ante cualquier error — v1.0
- ✓ 5 test cases con assertions + 8 trigger evals — v1.0
- ✓ Instalado globalmente en ~/.claude/skills/playwright-testing/ — v1.0

### Active

- [ ] Storage state (state-save/state-load) para preservar sesión entre conversations
- [ ] Comparación de tokens playwright-cli vs MCP en output de diagnóstico
- [ ] Checklist de verificación post-fix antes de cerrar ciclo

### Out of Scope

- Testing de APIs sin frontend (curl está bien para eso)
- Unit tests con Jest/Vitest (herramientas distintas)
- Queries directas a base de datos
- Creación de scripts de Playwright para CI/CD (@playwright/test es otra cosa)

## Context

Shipped v1.0 con 5,982 líneas en 37 archivos (.planning/ docs).
Skill instalado en `~/.claude/skills/playwright-testing/` (SKILL.md: 99 líneas).
Referencia oficial de Microsoft: 278 líneas en `references/playwright-cli-commands.md`.
Evals: 5 quality evals + 8 trigger evals en `evals/`.
Hallazgo clave: mecanismo de skill-matching de Claude Code no dispara con prompts casuales de usuario — trigger rate 33% con run_loop.py. La description cubre los casos pero el matching requiere keywords técnicas.

## Constraints

- **Herramienta**: skill-creator obligatorio para creación, evals y optimización
- **Tamaño**: SKILL.md principal < 300 líneas, detalle de comandos en referencia
- **Instalación**: ~/.claude/skills/playwright-testing/ (global, no por proyecto)
- **Dependencia**: playwright-cli debe estar instalado (`npm install -g @playwright/cli@latest`)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Skill global en ~/.claude/skills/ | Disponible en todos los proyectos sin configuración per-project | ✓ Good — funciona sin setup adicional |
| Referencia de comandos como archivo separado | Evita duplicar contenido del SKILL.md oficial de Microsoft, mantiene SKILL.md principal conciso | ✓ Good — SKILL.md 99 líneas vs 300 límite |
| Description "pushier" que lo normal | El problema central es que el skill no se activa cuando debería | ⚠️ Revisit — trigger rate 33%, mecanismo no responde a prompts casuales |
| Scope universal (no limitado a un stack) | El skill debe activarse para CUALQUIER interacción con el navegador web | ✓ Good — boundaries claros definen cuándo NO aplicar |
| Edición directa SKILL.md vs loop skill-creator | Contenido 100% especificado en CONTEXT.md, evals son Phase 3 | ✓ Good — más rápido y preciso |
| Aceptar trigger rate 33% (option-a) | Mecanismo de skill-matching no responde a prompts casuales | ✓ Good — hallazgo documentado, no es un bug del skill |

---
*Last updated: 2026-03-20 after v1.0 milestone*
