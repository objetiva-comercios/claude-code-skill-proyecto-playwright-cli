# Skill: playwright-testing

## What This Is

Un skill global para Claude Code que establece un protocolo obligatorio de testing e interacción con el navegador web usando `playwright-cli`. Reemplaza el comportamiento por defecto de Claude de usar curl, Playwright MCP server, o scripts ad-hoc de Node.js. Se instala en `~/.claude/skills/playwright-testing/` para estar disponible en todos los proyectos.

## Core Value

Claude SIEMPRE usa `playwright-cli` como único punto de entrada al navegador, con un protocolo de diagnóstico estructurado (snapshot → reproducir → console/network → fix → re-test).

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Skill creado con skill-creator (no manualmente)
- [ ] SKILL.md principal con protocolo de 5 pasos (< 300 líneas)
- [ ] references/playwright-cli-commands.md descargado del repo oficial de Microsoft
- [ ] Description optimizada para maximizar trigger rate ante interacciones con navegador
- [ ] Reglas NUNCA/SIEMPRE claramente definidas en el skill
- [ ] Triggers cubren: bugs frontend, formularios rotos, verificación de flujos, errores visuales, cualquier interacción con el browser
- [ ] Scope universal: aplica a TODAS las interacciones con navegador, no limitado a un stack
- [ ] Sessions nombradas por proyecto con --session=<nombre>
- [ ] Protocolo de credenciales: buscar .env antes de preguntar
- [ ] Diagnóstico obligatorio: console + network ante cualquier error
- [ ] 5 test cases con assertions definidas para evaluación
- [ ] Instalado globalmente en ~/.claude/skills/playwright-testing/

### Out of Scope

- Testing de APIs sin frontend (curl está bien para eso)
- Unit tests con Jest/Vitest (herramientas distintas)
- Queries directas a base de datos
- Creación de scripts de Playwright para CI/CD (@playwright/test es otra cosa)

## Context

- `playwright-cli` se instala via `npm install -g @playwright/mcp@latest`
- El repo oficial (https://github.com/microsoft/playwright-cli) tiene su propio SKILL.md con referencia de comandos
- El problema central: Claude sabe QUÉ no hacer pero no sabe CÓMO hacer el flujo correcto de diagnóstico
- El skill extiende el conocimiento base de playwright-cli con un protocolo de trabajo específico
- Entornos típicos: dev/staging/prod en dominios propios, apps con login/password

## Constraints

- **Herramienta**: skill-creator obligatorio para creación, evals y optimización
- **Tamaño**: SKILL.md principal < 300 líneas, detalle de comandos en referencia
- **Instalación**: ~/.claude/skills/playwright-testing/ (global, no por proyecto)
- **Dependencia**: playwright-cli debe estar instalado (`npm install -g @playwright/mcp@latest`)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Skill global en ~/.claude/skills/ | Disponible en todos los proyectos sin configuración per-project | — Pending |
| Referencia de comandos como archivo separado | Evita duplicar contenido del SKILL.md oficial de Microsoft, mantiene SKILL.md principal conciso | — Pending |
| Description "pushier" que lo normal | El problema central es que el skill no se activa cuando debería | — Pending |
| Scope universal (no limitado a un stack) | El skill debe activarse para CUALQUIER interacción con el navegador web | — Pending |

---
*Last updated: 2025-03-17 after initialization*
