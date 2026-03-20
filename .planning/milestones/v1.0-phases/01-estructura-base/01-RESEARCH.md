# Phase 1: Estructura Base - Research

**Researched:** 2026-03-18
**Domain:** Claude Code Skills — creación de skill con skill-creator, descarga de referencia oficial playwright-cli
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **Fuente de referencia**: Descargar el SKILL.md completo del repo `microsoft/playwright-cli` (ruta: `skills/playwright-cli/SKILL.md`) tal cual, sin modificar ni reformatear. Guardarlo como `references/playwright-cli-commands.md`.
- **Contenido inicial del SKILL.md**: Frontmatter con name + description agresiva orientada a triggering desde el día 1 (no placeholder genérico). Cuerpo con secciones esqueleto marcadas con TODO para Phase 2. Referencia explícita a `references/playwright-cli-commands.md`.
- **Estructura del directorio**: Tres elementos: `SKILL.md` en raíz, `references/` con la referencia oficial, `evals/` vacío con `.gitkeep`.
- **Ubicación de trabajo**: Directamente en `~/.claude/skills/playwright-testing/` (ubicación final). El repo del proyecto es solo para `.planning/` y documentación.
- **Verificación**: Phase 1 no se completa hasta confirmar que Claude Code reconoce el skill en la lista de skills disponibles.
- **Documentación del repo**: README.md y DEPLOY.md se generan después de Phase 3.

### Claude's Discretion

- Formato exacto de las secciones TODO en el esqueleto
- Largo y redacción específica de la description del frontmatter (se optimiza en Phase 3)
- Orden de las secciones en el SKILL.md

### Deferred Ideas (OUT OF SCOPE)

- README.md del repo — después de Phase 3 con skill completo
- DEPLOY.md del repo — después de Phase 3 con skill completo
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| STRUC-01 | Skill tiene SKILL.md principal con protocolo completo en < 300 líneas | Patron verificado: skills existentes siguen frontmatter YAML + cuerpo markdown < 500 lineas (skill-creator); constraint del proyecto: < 300. Esqueleto con TODOs permite cumplir sin exceder el limite. |
| STRUC-02 | Skill tiene references/playwright-cli-commands.md descargado del repo oficial de Microsoft | URL exacta verificada: `https://raw.githubusercontent.com/microsoft/playwright-cli/main/skills/playwright-cli/SKILL.md`. Archivo encontrado y contenido confirmado. Se descarga con curl o WebFetch directo. |
| STRUC-03 | Skill instalado globalmente en ~/.claude/skills/playwright-testing/ | Patron establecido: 12 skills existentes en ese directorio. Claude Code los descubre automaticamente. El directorio aun no existe — debe crearse. |
| STRUC-04 | Skill creado usando skill-creator (no manualmente) | skill-creator disponible en `~/.claude/skills/skill-creator/`. Proceso documentado en SKILL.md del skill-creator. Requiere invocar el skill-creator para generar el SKILL.md del nuevo skill. |
</phase_requirements>

## Summary

La Phase 1 consiste en crear el scaffolding del skill `playwright-testing` usando el proceso de skill-creator, descargar la referencia de comandos del repo oficial de Microsoft (`microsoft/playwright-cli`), e instalar el skill globalmente en `~/.claude/skills/playwright-testing/` para que Claude Code lo reconozca.

El repo oficial de Microsoft es `microsoft/playwright-cli` (no `playwright-mcp`). La URL correcta del SKILL.md oficial es `https://raw.githubusercontent.com/microsoft/playwright-cli/main/skills/playwright-cli/SKILL.md`. Este archivo fue verificado y contiene frontmatter YAML con `name: playwright-cli`, `description` y `allowed-tools: Bash(playwright-cli:*)`, seguido de referencia completa de comandos y ejemplos de uso.

La herramienta skill-creator está disponible en `~/.claude/skills/skill-creator/` y tiene documentado el proceso completo de creación. El flujo para Phase 1 es: invocar skill-creator para capturar intent y generar el SKILL.md borrador con esqueleto, descargar la referencia oficial, crear los directorios `references/` y `evals/`, y verificar que el skill aparece en la lista de Claude Code.

**Primary recommendation:** Crear `~/.claude/skills/playwright-testing/` manualmente, invocar skill-creator con el context del skill, y usar curl/WebFetch para descargar el SKILL.md oficial de Microsoft como `references/playwright-cli-commands.md`.

## Standard Stack

### Core

| Herramienta | Version | Proposito | Por que es estandar |
|-------------|---------|-----------|---------------------|
| skill-creator | disponible en `~/.claude/skills/skill-creator/` | Generacion y optimizacion de skills | Requerimiento explicito del proyecto (STRUC-04), skill global del usuario |
| playwright-cli | 0.1.1 (`@playwright/cli`) | Automatizacion de browser — la herramienta que el skill enseña a usar | Ya instalado globalmente en el sistema |
| curl / WebFetch | sistema | Descarga del SKILL.md oficial de Microsoft | Metodo simple para descargar archivos crudos de GitHub |

### Estructura del directorio objetivo

```
~/.claude/skills/playwright-testing/
├── SKILL.md                         # Generado con skill-creator (STRUC-01, STRUC-04)
├── references/
│   └── playwright-cli-commands.md   # Descargado del repo oficial (STRUC-02)
└── evals/
    └── .gitkeep                     # Directorio vacio, evals en Phase 3
```

**Instalacion de playwright-cli** (ya instalado, solo para verificacion):
```bash
npm install -g @playwright/cli@latest
```

## Architecture Patterns

### Pattern 1: Estructura de skill Claude Code

**What:** Todo skill en `~/.claude/skills/` sigue: directorio con nombre del skill, `SKILL.md` con frontmatter YAML (campos `name` y `description` obligatorios), cuerpo markdown con instrucciones.

**When to use:** Siempre. Es la convencion del sistema de skills de Claude Code.

**Ejemplo de frontmatter (patron verificado en skills existentes):**
```yaml
---
name: playwright-testing
description: [description agresiva orientada a triggering — ver Claude's Discretion]
---
```

**Referencia:** `/home/sanchez/.claude/skills/defuddle/SKILL.md` y `/home/sanchez/.claude/skills/skill-creator/SKILL.md`

### Pattern 2: Progressive Disclosure (de skill-creator)

**What:** Skills usan 3 niveles de carga:
1. **Metadata** (name + description) — siempre en contexto (~100 palabras)
2. **SKILL.md body** — en contexto cuando el skill se activa (< 500 lineas, constraint del proyecto: < 300)
3. **Bundled resources** — cargados cuando se necesitan (references/, scripts/)

**When to use:** Para Phase 1 el SKILL.md tiene esqueleto con TODOs, aprovechando que el protocolo real va en Phase 2. Esto permite cumplir el limite de 300 lineas con holgura.

**Patron de referencia en SKILL.md:**
```markdown
## Referencia de comandos

Lee `references/playwright-cli-commands.md` para la sintaxis completa de comandos playwright-cli.
```

### Pattern 3: Description "pushy" para triggering

**What:** Segun el SKILL.md de skill-creator (linea 67), Claude tiende a "undertrigger" skills. La description debe ser explicitamente inclusiva: mencionar contextos donde el skill aplica aunque el usuario no lo nombre directamente.

**When to use:** En el frontmatter del SKILL.md de playwright-testing.

**Patron de referencia (del skill-creator SKILL.md):**
> "make the skill descriptions a little bit 'pushy'. So for instance, instead of 'How to build a simple fast dashboard...', you might write 'How to build a simple fast dashboard... Make sure to use this skill whenever the user mentions dashboards, data visualization, internal metrics...'"

### Anti-Patterns a Evitar

- **Escribir SKILL.md manualmente sin invocar skill-creator:** Viola STRUC-04 y pierde el proceso de iteracion/evaluacion del skill-creator.
- **Copiar solo parte del SKILL.md de Microsoft:** La decision es descargarlo completo para facilitar actualizaciones futuras.
- **Agregar directorios extra (examples/, agents/, scripts/):** El CONTEXT.md lo prohibe explicitamente.
- **Poner el skill en otra ubicacion:** Debe estar en `~/.claude/skills/playwright-testing/`, no en el repo del proyecto.

## Don't Hand-Roll

| Problema | No construir | Usar en cambio | Por que |
|----------|-------------|----------------|---------|
| Creacion del SKILL.md | Escribirlo manualmente desde cero | skill-creator (invocar el skill) | Es el requerimiento STRUC-04; ademas skill-creator tiene el proceso de optimizacion de description incorporado |
| Referencia de comandos playwright-cli | Escribir lista de comandos de memoria | Descargar `skills/playwright-cli/SKILL.md` del repo microsoft/playwright-cli | La informacion descargada es authoritative, actualizable, y sin errores de memoria |

## Common Pitfalls

### Pitfall 1: Repo incorrecto para la referencia de comandos

**What goes wrong:** Se intenta descargar de `microsoft/playwright-mcp` en vez de `microsoft/playwright-cli`.
**Why it happens:** El MCP es el proyecto historico conocido; playwright-cli es mas reciente (v0.1.1).
**How to avoid:** La URL correcta es `https://raw.githubusercontent.com/microsoft/playwright-cli/main/skills/playwright-cli/SKILL.md`.
**Warning signs:** 404 al intentar descargar el archivo.

### Pitfall 2: CLAUDE.md del repo playwright-mcp confundido con la referencia

**What goes wrong:** Se descarga el `CLAUDE.md` de `microsoft/playwright-mcp` (que solo tiene convencion de commits) en vez del SKILL.md de comandos.
**Why it happens:** El repo playwright-mcp tiene un CLAUDE.md pero NO tiene SKILL.md.
**How to avoid:** La fuente correcta es el repo `playwright-cli`, archivo en `skills/playwright-cli/SKILL.md`.

### Pitfall 3: Verificacion de reconocimiento omitida

**What goes wrong:** El skill se crea pero no se verifica que Claude Code lo lista en "What skills are available?".
**Why it happens:** Parece obvio que si el directorio existe, funciona — pero puede haber problemas de permisos o naming.
**How to avoid:** Verificar explicitamente al final de la fase preguntando a Claude Code por los skills disponibles.

### Pitfall 4: Description placeholder en lugar de description agresiva

**What goes wrong:** Se escribe una description generica ("Use for browser testing") que no activa el skill en los casos de uso clave.
**Why it happens:** La tendencia es escribir descripciones conservadoras.
**How to avoid:** La description debe nombrar explicitamente: bugs de frontend, formularios rotos, errores visuales, verificacion de flujos web, login, CRUD, navegacion multi-pagina, cualquier interaccion con el navegador.

## Code Examples

### Descarga del SKILL.md oficial de Microsoft

```bash
# Source: verificado en https://github.com/microsoft/playwright-cli/tree/main/skills/playwright-cli
curl -s "https://raw.githubusercontent.com/microsoft/playwright-cli/main/skills/playwright-cli/SKILL.md" \
  -o ~/.claude/skills/playwright-testing/references/playwright-cli-commands.md
```

### Creacion del directorio con estructura

```bash
mkdir -p ~/.claude/skills/playwright-testing/references
mkdir -p ~/.claude/skills/playwright-testing/evals
touch ~/.claude/skills/playwright-testing/evals/.gitkeep
```

### Frontmatter del SKILL.md (estructura minima, a generar via skill-creator)

```yaml
---
name: playwright-testing
description: [A definir con skill-creator — debe ser "pushy" y cubrir: bugs frontend, formularios rotos, errores visuales, verificacion de flujos, login, CRUD, cualquier interaccion con el navegador]
---
```

### Referencia al archivo de comandos en el SKILL.md

```markdown
## Referencia de comandos

Lee `references/playwright-cli-commands.md` para la sintaxis completa de comandos playwright-cli (descargado del repo oficial de Microsoft).
```

### Contenido del SKILL.md oficial de Microsoft (preview)

El archivo `skills/playwright-cli/SKILL.md` del repo microsoft/playwright-cli contiene:
- Frontmatter: `name: playwright-cli`, `description`, `allowed-tools: Bash(playwright-cli:*)`
- Quick start con secuencia completa de comandos
- Referencia de todos los comandos core (open, goto, click, type, fill, drag, hover, select, snapshot, etc.)
- Open parameters (--browser, --persistent, --profile, --config)
- Browser Sessions con flag `-s=nombre`
- Ejemplos: form submission, multi-tab workflow, debugging con DevTools
- Referencias a archivos adicionales en `references/` (request-mocking, running-code, session-management, storage-state, test-generation, tracing, video-recording)

## State of the Art

| Enfoque anterior | Enfoque actual | Cambio | Impacto |
|-----------------|----------------|--------|---------|
| `microsoft/playwright-mcp` (servidor MCP) | `microsoft/playwright-cli` (CLI) | 2025 — nuevo repo y enfoque | playwright-cli es mas token-eficiente; el SKILL.md oficial esta en playwright-cli, no playwright-mcp |
| playwright-cli sin skills | `playwright-cli install --skills` para instalar skills en el proyecto | 2025 — nuevo flujo de instalacion | Para nuestro caso usamos el skill global en `~/.claude/skills/`, no el skill local del proyecto |

## Open Questions

1. **Verificacion exacta del comportamiento de `playwright-cli snapshot`**
   - What we know: El README y SKILL.md oficial confirman que snapshot escribe a `.playwright-cli/page-TIMESTAMP.yml` por defecto, o al path especificado con `--filename=`
   - What's unclear: Si el path relativo `.playwright-cli/` es relativo al CWD o al home del usuario
   - Recommendation: Esta pregunta es para Phase 2 (protocolo); para Phase 1 es irrelevante — la referencia descargada de Microsoft lo documenta

2. **Context budget con 12+ skills activos**
   - What we know: El CONTEXT.md menciona como concern la visibilidad del skill con todos los skills activos del usuario
   - What's unclear: Si 13 skills activos consumen demasiado context para que el nuevo skill se active
   - Recommendation: Verificar en el criterio de exito de Phase 1 (pregunta "What skills are available?"); si no aparece, investigar en Phase 3 al optimizar la description

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Verificacion manual (no hay test framework automatico para skills de Claude Code) |
| Config file | none |
| Quick run command | `claude "What skills are available?"` (manual check) |
| Full suite command | `claude "What skills are available?"` seguido de inspeccion del directorio |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| STRUC-01 | SKILL.md existe en `~/.claude/skills/playwright-testing/` con frontmatter valido | smoke | `ls ~/.claude/skills/playwright-testing/SKILL.md && head -5 ~/.claude/skills/playwright-testing/SKILL.md` | ❌ Wave 0 |
| STRUC-02 | `references/playwright-cli-commands.md` existe y tiene contenido del repo oficial | smoke | `ls ~/.claude/skills/playwright-testing/references/playwright-cli-commands.md && grep "playwright-cli" ~/.claude/skills/playwright-testing/references/playwright-cli-commands.md | head -3` | ❌ Wave 0 |
| STRUC-03 | Directorio `~/.claude/skills/playwright-testing/` existe con estructura completa | smoke | `ls -la ~/.claude/skills/playwright-testing/` | ❌ Wave 0 |
| STRUC-04 | Evidencia de uso de skill-creator en el proceso (no verificable por archivo, verificar en el proceso) | manual | Revision manual del transcript de ejecucion | manual-only |

### Sampling Rate

- **Per task commit:** `ls -la ~/.claude/skills/playwright-testing/`
- **Per wave merge:** `ls ~/.claude/skills/playwright-testing/ && head -10 ~/.claude/skills/playwright-testing/SKILL.md`
- **Phase gate:** Todos los archivos presentes + confirmacion manual que Claude Code lista el skill

### Wave 0 Gaps

- [ ] `~/.claude/skills/playwright-testing/` — directorio a crear
- [ ] `~/.claude/skills/playwright-testing/SKILL.md` — a generar via skill-creator
- [ ] `~/.claude/skills/playwright-testing/references/playwright-cli-commands.md` — a descargar de Microsoft
- [ ] `~/.claude/skills/playwright-testing/evals/.gitkeep` — directorio vacio

## Sources

### Primary (HIGH confidence)

- Inspeccion directa de `/home/sanchez/.claude/skills/skill-creator/SKILL.md` — proceso de creacion de skills, estructura de directorios, description "pushy"
- Inspeccion directa de `/home/sanchez/.claude/skills/defuddle/SKILL.md` — ejemplo de skill existente con estructura real
- `https://github.com/microsoft/playwright-cli/blob/main/skills/playwright-cli/SKILL.md` — contenido verificado via WebFetch; es el archivo que se descargara como referencia
- `ls /home/sanchez/.claude/skills/` — listado real de los 12 skills existentes

### Secondary (MEDIUM confidence)

- `https://github.com/microsoft/playwright-cli` — estructura del repo verificada via WebFetch; confirma que el SKILL.md esta en `skills/playwright-cli/SKILL.md`
- `npm list -g @playwright/cli` — confirma version 0.1.1 instalada globalmente
- README.md de playwright-cli via WebFetch — comandos disponibles y flujo de instalacion

### Tertiary (LOW confidence)

- WebSearch "microsoft playwright-mcp SKILL.md github 2025" — confirmo que el SKILL.md NO esta en playwright-mcp sino en playwright-cli (triangulado con verificacion directa)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — skills existentes inspeccionados directamente, herramientas verificadas
- Architecture: HIGH — patron de skills verificado en 12 skills existentes, proceso de skill-creator documentado
- Pitfalls: HIGH — pitfalls derivados de investigacion directa (404 en playwright-mcp, CLAUDE.md incorrecto)
- URL de descarga: HIGH — verificada con WebFetch al repo real de Microsoft

**Research date:** 2026-03-18
**Valid until:** 2026-06-18 (estable — el patron de skills de Claude Code cambia poco; playwright-cli puede tener releases frecuentes pero el SKILL.md es estable)
