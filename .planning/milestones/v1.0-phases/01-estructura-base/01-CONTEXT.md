# Phase 1: Estructura Base - Context

**Gathered:** 2026-03-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Crear el scaffolding del skill `playwright-testing` usando skill-creator, descargar la referencia oficial de comandos del repo de Microsoft, e instalar globalmente en `~/.claude/skills/playwright-testing/`. El skill debe ser reconocido por Claude Code al final de esta fase.

</domain>

<decisions>
## Implementation Decisions

### Fuente de referencia
- Descargar el SKILL.md completo del repo `microsoft/playwright-mcp` tal cual, sin modificar ni reformatear
- Guardarlo como `references/playwright-cli-commands.md`
- Nuestro protocolo de 5 pasos (Phase 2) prevalece sobre cualquier regla del skill de Microsoft — el archivo de Microsoft es referencia de sintaxis de comandos, no de protocolo de trabajo
- Facilita actualizaciones futuras: solo reemplazar el archivo

### Contenido inicial del SKILL.md
- Frontmatter con name + description agresiva orientada a triggering desde el día 1 (no placeholder genérico)
- Cuerpo con secciones esqueleto marcadas con TODO para Phase 2 (protocolo, reglas, triggers)
- Referencia explícita a `references/playwright-cli-commands.md` con instrucción de lectura para que Claude sepa dónde buscar sintaxis de comandos
- El protocolo completo se escribe en Phase 2; aquí solo la estructura

### Estructura del directorio
- Tres elementos: `SKILL.md` en raíz, `references/` con la referencia oficial, `evals/` vacío
- `evals/` con `.gitkeep` — los test cases se crean en Phase 3
- No agregar directorios extra (no examples/, no agents/, no scripts/)

### Ubicación de trabajo
- Trabajar directamente en `~/.claude/skills/playwright-testing/` (ubicación final)
- El repo del proyecto (`~/proyectos/claude-code-skill-proyecto-playwright-cli/`) es solo para `.planning/` y documentación

### Verificación
- Phase 1 no se completa hasta confirmar que Claude Code reconoce el skill en la lista de skills disponibles

### Documentación del repo
- README.md y DEPLOY.md se generan después de Phase 3, cuando el skill esté completo

### Claude's Discretion
- Formato exacto de las secciones TODO en el esqueleto
- Largo y redacción específica de la description del frontmatter (se optimiza en Phase 3)
- Orden de las secciones en el SKILL.md

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Skill creation
- `.planning/PROJECT.md` — Visión del skill, constraints (< 300 líneas, skill-creator obligatorio)
- `.planning/REQUIREMENTS.md` — Requirements STRUC-01 a STRUC-04 para esta fase
- `.planning/ROADMAP.md` §Phase 1 — Success criteria y planes definidos

### Referencia de comandos
- Repo `microsoft/playwright-mcp` SKILL.md — Fuente oficial para descargar en references/

### Patterns existentes
- `~/.claude/skills/defuddle/SKILL.md` — Ejemplo de skill existente con estructura similar (frontmatter + contenido conciso)
- `~/.claude/skills/skill-creator/SKILL.md` — Referencia del tool obligatorio para crear el skill

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- 14 skills existentes en `~/.claude/skills/` como referencia de estructura y formato de frontmatter
- skill-creator disponible con scripts, agents y references propios

### Established Patterns
- Todos los skills siguen: frontmatter YAML (name, description) + cuerpo markdown
- Descriptions varían en largo pero siempre orientadas a trigger conditions

### Integration Points
- `~/.claude/skills/playwright-testing/` — directorio destino (no existe aún, debe crearse)
- skill-creator es la herramienta de creación (no escritura manual del SKILL.md)

</code_context>

<specifics>
## Specific Ideas

- El SKILL.md de Microsoft se descarga íntegro para facilitar actualizaciones (solo reemplazar archivo)
- La description debe ser "pushier" que lo normal — el problema central es undertriggering
- El skill debe compatibilizar con el SKILL.md de Microsoft sin contradecirlo

</specifics>

<deferred>
## Deferred Ideas

- README.md del repo — después de Phase 3 con skill completo
- DEPLOY.md del repo — después de Phase 3 con skill completo

</deferred>

---

*Phase: 01-estructura-base*
*Context gathered: 2026-03-18*
