# Phase 2: Protocolo y Reglas - Context

**Gathered:** 2026-03-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Escribir el contenido completo del SKILL.md: protocolo de 5 pasos operativo, reglas NUNCA/SIEMPRE con razones explícitas, manejo de credenciales y sessions, triggers y boundaries. Todo en menos de 300 líneas, referenciando `references/playwright-cli-commands.md` para sintaxis detallada.

</domain>

<decisions>
## Implementation Decisions

### Flujo del protocolo de 5 pasos
- Receta concisa: 2-3 líneas por paso con comando exacto y razón. Sintaxis detallada en references/
- Paso 0: verificar instalación — si `playwright-cli --version` falla, correr `npm install -g playwright-cli` automáticamente
- Paso 2 (snapshot): obligatorio solo antes de la primera interacción. Después de cada comando playwright-cli ya devuelve snapshot automáticamente
- Paso 3 (diagnóstico): tabla de causa raíz compacta — si 401/403 → credenciales, si 500 → backend, si error JS → frontend, si nada en console/network → bug UI puro
- Paso 3 bis: resumen obligatorio antes de intentar fix — mostrar error, causa identificada y acción propuesta. El usuario confirma o redirige
- Paso 5 (re-test): repetir flujo completo desde paso 2 (snapshot → reproducir → verificar). No solo el paso que falló
- NO agregar paso de cierre. La session queda abierta. Cerrar es decisión implícita de Claude cuando termina el flujo

### Credenciales y auth
- Lookup chain: buscar patrones conocidos (*_URL, *_USER, *_PASSWORD, *_EMAIL, *_TOKEN, *_API_KEY) en .env.local → .env.development → .env
- Si encuentra credenciales, usarlas directamente sin pedir confirmación al usuario
- Si no hay archivos .env, preguntar URL y credenciales al usuario directamente. No adivinar ni usar defaults
- Login básico (usuario/password) cubierto por el protocolo. Para OAuth/2FA, instruir a Claude a usar `state-save` después de que el usuario se loguee manualmente. No automatizar OAuth

### Sessions nombradas
- Convención: nombre del directorio del proyecto — `playwright-cli -s=mi-app open`
- Siempre usar `--persistent` para preservar cookies/storage entre comandos
- Verificar sessions existentes con `playwright-cli list` antes de abrir una nueva. Si hay session del proyecto, reusarla
- Flag `-s=nombre` obligatorio en TODOS los comandos (click, fill, snapshot, etc.), no solo en open

### Reglas NUNCA/SIEMPRE
- Formato: lista con razón inline después del dash. Una línea por regla
- Regla NUNCA sobre Playwright MCP: explícita y fuerte, destacada visualmente — consume 4x más tokens, menos control, no es necesario
- Regla SIEMPRE: confirmar URL del entorno (dev/staging/prod) antes de abrir browser — testear en prod por error puede causar daño real

### Boundaries
- Formato: negativo + alternativa. "NO usar para: API testing sin frontend (usar curl), unit tests (usar vitest/jest), queries DB (usar SQL directo)"

### Claude's Discretion
- Formato exacto de la tabla de causa raíz
- Redacción específica de cada regla (el contenido semántico está decidido)
- Orden de las secciones dentro del SKILL.md
- Cómo destacar visualmente la regla anti-MCP

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Skill actual
- `~/.claude/skills/playwright-testing/SKILL.md` — Esqueleto actual con TODOs a reemplazar con contenido completo
- `~/.claude/skills/playwright-testing/references/playwright-cli-commands.md` — Referencia oficial de sintaxis de comandos (descargada de Microsoft)

### Requirements
- `.planning/REQUIREMENTS.md` §Protocol (PROTO-01 a PROTO-09) — Los 5 pasos con criterios específicos
- `.planning/REQUIREMENTS.md` §Rules (RULE-01 a RULE-06) — Reglas NUNCA/SIEMPRE requeridas
- `.planning/REQUIREMENTS.md` §Triggers (TRIG-01 a TRIG-04) — Triggers y boundaries

### Contexto previo
- `.planning/phases/01-estructura-base/01-CONTEXT.md` — Decisiones de Phase 1 (referencia de Microsoft es para sintaxis, nuestro protocolo prevalece)
- `.planning/PROJECT.md` — Constraints: < 300 líneas, skill-creator obligatorio

### Instalación de playwright-cli
- Paquete npm: `playwright-cli` (v0.262.0) — instalado con `npm install -g playwright-cli`
- Repo: `microsoft/playwright-cli` — NO confundir con `@playwright/mcp` que es otra herramienta

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- SKILL.md actual: 28 líneas con frontmatter completo y 3 secciones TODO — el contenido se reemplaza, el frontmatter se mantiene
- references/playwright-cli-commands.md: 279 líneas con sintaxis completa de todos los comandos — el protocolo referencia este archivo

### Established Patterns
- Frontmatter ya definido con description "pushier" orientada a triggering — no modificar en esta fase
- `allowed-tools: Bash(playwright-cli:*)` ya configurado
- Referencia de Microsoft como archivo separado — el SKILL.md principal no duplica sintaxis

### Integration Points
- Las 3 secciones TODO del SKILL.md actual se reemplazan con contenido real: Protocolo, Reglas, Triggers/Boundaries
- El protocolo debe referenciar `references/playwright-cli-commands.md` para sintaxis detallada
- skill-creator es la herramienta obligatoria para escribir el contenido (no edición manual)

</code_context>

<specifics>
## Specific Ideas

- playwright-cli NO es @playwright/mcp — son herramientas distintas. El skill existe precisamente por esta confusión. La regla anti-MCP debe ser inequívoca
- El comando de instalación correcto es `npm install -g playwright-cli`, NO `npm install -g @playwright/mcp@latest`
- Paso 0 (verificar instalación) instala automáticamente si falta, sin preguntar
- Sessions siempre persistent + nombradas + flag -s en todos los comandos — máxima consistencia
- Resumen de diagnóstico obligatorio antes de tocar código — el usuario siempre confirma la causa raíz

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-protocolo-y-reglas*
*Context gathered: 2026-03-18*
