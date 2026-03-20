# Phase 2: Protocolo y Reglas - Research

**Researched:** 2026-03-19
**Domain:** Skill authoring para Claude Code — protocolo operativo, reglas NUNCA/SIEMPRE, manejo de credenciales y sesiones, triggers y boundaries
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Flujo del protocolo de 5 pasos**
- Receta concisa: 2-3 líneas por paso con comando exacto y razón. Sintaxis detallada en references/
- Paso 0: verificar instalación — si `playwright-cli --version` falla, correr `npm install -g playwright-cli` automáticamente
- Paso 2 (snapshot): obligatorio solo antes de la primera interacción. Después de cada comando playwright-cli ya devuelve snapshot automáticamente
- Paso 3 (diagnóstico): tabla de causa raíz compacta — si 401/403 → credenciales, si 500 → backend, si error JS → frontend, si nada en console/network → bug UI puro
- Paso 3 bis: resumen obligatorio antes de intentar fix — mostrar error, causa identificada y acción propuesta. El usuario confirma o redirige
- Paso 5 (re-test): repetir flujo completo desde paso 2 (snapshot → reproducir → verificar). No solo el paso que falló
- NO agregar paso de cierre. La session queda abierta. Cerrar es decisión implícita de Claude cuando termina el flujo

**Credenciales y auth**
- Lookup chain: buscar patrones conocidos (*_URL, *_USER, *_PASSWORD, *_EMAIL, *_TOKEN, *_API_KEY) en .env.local → .env.development → .env
- Si encuentra credenciales, usarlas directamente sin pedir confirmación al usuario
- Si no hay archivos .env, preguntar URL y credenciales al usuario directamente. No adivinar ni usar defaults
- Login básico (usuario/password) cubierto por el protocolo. Para OAuth/2FA, instruir a Claude a usar `state-save` después de que el usuario se loguee manualmente. No automatizar OAuth

**Sessions nombradas**
- Convención: nombre del directorio del proyecto — `playwright-cli -s=mi-app open`
- Siempre usar `--persistent` para preservar cookies/storage entre comandos
- Verificar sessions existentes con `playwright-cli list` antes de abrir una nueva. Si hay session del proyecto, reusarla
- Flag `-s=nombre` obligatorio en TODOS los comandos (click, fill, snapshot, etc.), no solo en open

**Reglas NUNCA/SIEMPRE**
- Formato: lista con razón inline después del dash. Una línea por regla
- Regla NUNCA sobre Playwright MCP: explícita y fuerte, destacada visualmente — consume 4x más tokens, menos control, no es necesario
- Regla SIEMPRE: confirmar URL del entorno (dev/staging/prod) antes de abrir browser — testear en prod por error puede causar daño real

**Boundaries**
- Formato: negativo + alternativa. "NO usar para: API testing sin frontend (usar curl), unit tests (usar vitest/jest), queries DB (usar SQL directo)"

### Claude's Discretion
- Formato exacto de la tabla de causa raíz
- Redacción específica de cada regla (el contenido semántico está decidido)
- Orden de las secciones dentro del SKILL.md
- Cómo destacar visualmente la regla anti-MCP

### Deferred Ideas (OUT OF SCOPE)
Ninguna — la discusión se mantuvo dentro del scope de la fase
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| PROTO-01 | Paso 0 — verificar instalación de playwright-cli antes de usarlo | Comando: `playwright-cli --version`; fallback: `npm install -g playwright-cli`. Verificado en references/playwright-cli-commands.md. |
| PROTO-02 | Paso 1 — buscar credenciales en .env.local → .env.development → .env antes de preguntar al usuario | Patrones de búsqueda definidos en CONTEXT.md. Bash con grep sobre los tres archivos en orden. |
| PROTO-03 | Paso 1 — confirmar URL del entorno (dev/staging/prod) antes de abrir el navegador | Regla de seguridad — testear en prod por error tiene consecuencias reales. |
| PROTO-04 | Paso 2 — ejecutar snapshot antes de cada interacción significativa | `playwright-cli -s=nombre snapshot`. Después del primer snapshot, cada comando devuelve snapshot automáticamente. |
| PROTO-05 | Paso 2 — usar sessions nombradas por proyecto con --session=<nombre> | Convención: nombre del directorio del proyecto. Flag `-s=nombre` en todos los comandos. `--persistent` obligatorio. |
| PROTO-06 | Paso 3 — ejecutar console + network obligatoriamente ante cualquier error | `playwright-cli -s=nombre console` y `playwright-cli -s=nombre network`. Ambos siempre, nunca solo uno. |
| PROTO-07 | Paso 3 — identificar causa raíz (401/403, 500, error JS, bug UI puro) y mostrar resumen | Tabla de diagnóstico compacta en el SKILL.md. Resumen obligatorio antes de fix. |
| PROTO-08 | Paso 4 — corregir código y mostrar diff de cambios | Fuera del scope de playwright-cli; el paso es: aplicar fix, mostrar diff, explicar qué cambió. |
| PROTO-09 | Paso 5 — re-test del flujo completo desde Paso 2 para confirmar fix | Repetir desde snapshot — no solo el paso que falló. El ciclo se cierra cuando el flujo pasa sin error. |
| RULE-01 | Regla NUNCA para curl/wget en interacciones de browser | Razón: curl no da console/network/estado del DOM — el diagnóstico es imposible. |
| RULE-02 | Regla NUNCA para Playwright MCP server | Razón: consume 4x más tokens, menos control, playwright-cli es suficiente y más eficiente. |
| RULE-03 | Regla NUNCA para @playwright/test o scripts ad-hoc de Node.js | Razón: playwright-cli resuelve el caso de uso sin overhead de setup y sin scripts que mantener. |
| RULE-04 | Regla NUNCA para asumir credenciales sin verificar .env | Razón: credenciales incorrectas producen diagnóstico falso (falsos 401, falsos 403). |
| RULE-05 | Regla SIEMPRE snapshot antes de interactuar | Razón: sin snapshot no hay refs disponibles (e1, e2, e3...) — los comandos click/fill fallan. |
| RULE-06 | Regla SIEMPRE console + network ante error | Razón: console solo muestra errores JS, network solo muestra HTTP — el diagnóstico requiere ambos. |
| TRIG-01 | Description activa el skill ante bugs de frontend, formularios rotos, errores visuales | Ya implementado en frontmatter Phase 1. Phase 2 debe reforzarlo en el cuerpo con ejemplos. |
| TRIG-02 | Description activa el skill ante verificación de flujos web (login, CRUD, navegación) | Cubierto por frontmatter existente. La sección Triggers/Boundaries en el cuerpo lo refuerza. |
| TRIG-03 | Description activa ante CUALQUIER interacción necesaria con el navegador web | Cobertura amplia — si hay browser de por medio, este skill aplica. |
| TRIG-04 | Skill NO se activa para API testing sin frontend, unit tests, queries DB | Boundaries explícitos con alternativas: curl, vitest/jest, SQL directo. |
</phase_requirements>

---

## Summary

Phase 2 no es una tarea de investigación técnica sobre una librería externa — es una tarea de **redacción de contenido** para un archivo SKILL.md ya existente. El trabajo central consiste en reemplazar las 3 secciones TODO del SKILL.md actual con contenido real: el protocolo de 5 pasos, las reglas NUNCA/SIEMPRE con razones, y la sección de Triggers/Boundaries.

Toda la información necesaria para escribir ese contenido está completamente definida en CONTEXT.md. No hay ambigüedad sobre qué escribir — hay decisiones tomadas para cada componente. El trabajo del planner es secuenciar correctamente las tareas y asegurar que skill-creator sea la herramienta de escritura (no edición manual).

La herramienta obligatoria es **skill-creator**. El SKILL.md resultante debe tener menos de 300 líneas en total, referenciando `references/playwright-cli-commands.md` para sintaxis detallada.

**Primary recommendation:** Un solo plan que escribe el contenido completo del SKILL.md usando skill-creator, verificando el conteo de líneas al final.

---

## Standard Stack

### Core

| Herramienta | Versión | Propósito | Por qué es el estándar |
|-------------|---------|-----------|----------------------|
| skill-creator | global en ~/.claude/skills/ | Crear y editar skills de Claude Code | Obligatorio por decisión de proyecto. Provee el loop de draft → test → evaluate → refine |
| playwright-cli | 0.262.0 (npm) | El skill que estamos documentando | Ya instalado globalmente desde Phase 1 |
| SKILL.md existente | 27 líneas con TODOs | Base para reemplazar con contenido real | Frontmatter ya está completo — no modificar |

### Lo que NO se usa

| En vez de | No usar | Razón |
|-----------|---------|-------|
| skill-creator | Edición manual del SKILL.md con Write/Edit tool | STRUC-04 requiere skill-creator para la creación del contenido. La intención es que el proceso sea reproducible via el loop de skill-creator |
| playwright-cli | @playwright/mcp | Herramientas distintas — esta confusión es el problema que el skill resuelve |

**Instalación** (ya completa desde Phase 1 — solo referencia):
```bash
npm install -g playwright-cli
```

---

## Architecture Patterns

### Estructura del SKILL.md resultante

```
~/.claude/skills/playwright-testing/SKILL.md
```

Secciones en orden (sugerencia de Claude's Discretion — el planner puede ajustar):

```markdown
---
name: playwright-testing
description: [frontmatter existente — NO modificar]
allowed-tools: Bash(playwright-cli:*)
---

# playwright-testing
[descripción introductoria existente — NO modificar]

## Protocolo de diagnóstico
[Paso 0 a Paso 5 — contenido nuevo]

## Reglas
[NUNCA/SIEMPRE con razones — contenido nuevo]

## Triggers y Boundaries
[Cuándo usar / cuándo NO usar — contenido nuevo]

## Referencia de comandos
[Referencia a references/ — ya existe, NO modificar]
```

### Patrón de escritura de skills (de skill-creator SKILL.md)

El skill-creator recomienda:
- Usar imperativo en las instrucciones
- Explicar el **por qué** de cada regla en lugar de solo el qué
- Evitar ALWAYS/NEVER sin razón — dar contexto para que el modelo entienda
- Formato de output template: `ALWAYS use this exact template`
- Ejemplos inline con `**Example:**`

### Patrón de protocolo numerado

Basado en los requisitos y CONTEXT.md:

```markdown
## Protocolo de diagnóstico

**Paso 0 — Verificar instalación**
Correr `playwright-cli --version`. Si falla, instalar: `npm install -g playwright-cli`.

**Paso 1 — URL y credenciales**
Confirmar URL del entorno (dev/staging/prod) — nunca asumir prod. Buscar credenciales en:
1. `.env.local` (patrones: *_URL, *_USER, *_PASSWORD, *_EMAIL, *_TOKEN, *_API_KEY)
2. `.env.development`
3. `.env`
Si no hay archivos .env, preguntar URL y credenciales al usuario. No adivinar.

**Paso 2 — Session + snapshot inicial**
...
```

### Patrón de reglas con razón inline

```markdown
## Reglas

**NUNCA usar curl o wget para interacciones con el browser** — curl no da acceso a la consola JS ni al estado del DOM; el diagnóstico es imposible sin esa información.

> **NUNCA usar Playwright MCP server (@playwright/mcp)** — consume 4x más tokens que playwright-cli, da menos control sobre el flujo, y no aporta nada que playwright-cli no tenga. playwright-cli es la herramienta correcta para todo uso interactivo.

**NUNCA usar @playwright/test ni scripts ad-hoc de Node.js** — playwright-cli resuelve el caso de uso sin el overhead de setup ni scripts que mantener.
```

La regla anti-MCP recibe tratamiento visual diferenciado (blockquote, negrita adicional, o sección propia) — Claude's Discretion sobre el formato exacto.

### Patrón de tabla de diagnóstico

```markdown
| Síntoma en console/network | Causa probable | Acción |
|----------------------------|----------------|--------|
| HTTP 401 o 403 | Credenciales incorrectas o expiradas | Verificar .env, re-login |
| HTTP 500 | Error en backend | Revisar logs del servidor |
| Error JS en console | Bug en frontend | Identificar componente, revisar stack trace |
| Sin errores en console/network | Bug UI puro | Inspeccionar estado del DOM con snapshot |
```

### Patrón de boundaries negativo + alternativa

```markdown
## Triggers y Boundaries

**Usar este skill para:** bugs de frontend, formularios que no funcionan, errores visuales, login roto, flujos de signup/CRUD, verificación de que una página carga, testing de interfaces, debugging de rendering — cualquier interacción con un navegador web.

**NO usar para:**
- API testing sin frontend → usar `curl` o herramienta de HTTP testing
- Unit tests → usar `vitest` o `jest`
- Queries directas a base de datos → usar SQL directo o cliente de DB
- Generación de scripts Playwright para CI/CD → usar `@playwright/test` (herramienta distinta)
```

---

## Don't Hand-Roll

| Problema | No construir | Usar en cambio | Por qué |
|----------|-------------|----------------|---------|
| Escritura del SKILL.md | Edición manual con Write/Edit | skill-creator | STRUC-04 lo requiere. skill-creator provee el loop de evaluación |
| Detección de credenciales en .env | Script bash custom | Instrucción en el SKILL.md para que Claude use `grep` o `cat` sobre los archivos .env | El skill instruye a Claude, no necesita un script externo |
| Manejo de sessions | Lógica custom de session management | playwright-cli `-s=nombre --persistent` | playwright-cli ya maneja sessions persistentes nativamente |

---

## Common Pitfalls

### Pitfall 1: Modificar el frontmatter existente

**Qué sale mal:** El frontmatter actual (name, description, allowed-tools) fue diseñado y ajustado en Phase 1 específicamente para triggering. Modificarlo puede romper el triggering del skill.

**Por qué pasa:** Quien escribe el contenido nuevo puede querer "mejorar" la description o ajustar el frontmatter como parte del trabajo.

**Cómo evitar:** El plan debe ser explícito: **el frontmatter no se toca**. Solo se reemplazan las secciones con comentarios TODO.

**Señales de alerta:** Si el plan incluye "actualizar frontmatter" o "reescribir description".

### Pitfall 2: Superar las 300 líneas

**Qué sale mal:** El SKILL.md supera el límite de 300 líneas establecido en STRUC-01 y PROJECT.md.

**Por qué pasa:** El protocolo de 5 pasos con tabla de diagnóstico + reglas + triggers puede expandirse si no se controla.

**Cómo evitar:** El plan debe incluir una tarea de verificación de líneas como paso final: `wc -l ~/.claude/skills/playwright-testing/SKILL.md`. Si supera 300, compactar antes de completar.

**Presupuesto de líneas:** El SKILL.md actual tiene 28 líneas (incluyendo frontmatter y secciones existentes). El nuevo contenido tiene un presupuesto de ~270 líneas adicionales. Distribución orientativa:
- Protocolo de 5 pasos: ~60-80 líneas
- Reglas NUNCA/SIEMPRE: ~20-30 líneas
- Triggers y Boundaries: ~20-30 líneas
- Total contenido nuevo: ~100-140 líneas
- Total SKILL.md resultante: ~128-168 líneas (bien dentro del límite)

### Pitfall 3: Duplicar sintaxis de comandos

**Qué sale mal:** El SKILL.md replica comandos que ya están en `references/playwright-cli-commands.md`, hinchando el archivo innecesariamente.

**Por qué pasa:** Es tentador poner el comando exacto con todos sus flags en el protocolo.

**Cómo evitar:** El protocolo muestra el comando mínimo con el flag esencial (ej: `playwright-cli -s=mi-app snapshot`) y dice "ver references/playwright-cli-commands.md para opciones completas". No más de 2-3 comandos de ejemplo por paso.

### Pitfall 4: Escribir manualmente en vez de usar skill-creator

**Qué sale mal:** Se viola STRUC-04 y se pierde el loop de evaluación que skill-creator provee.

**Por qué pasa:** Es más rápido y simple editar el archivo directamente.

**Cómo evitar:** El plan debe usar skill-creator como herramienta. Sin embargo, dado que Phase 3 es la fase de evals, en Phase 2 el uso de skill-creator puede limitarse a la redacción (draft) sin correr el loop completo de evaluación — eso es trabajo de Phase 3.

### Pitfall 5: Confundir el comando de instalación

**Qué sale mal:** El SKILL.md documenta el comando incorrecto de instalación.

**Por qué pasa:** PROJECT.md (sección Context) tiene un error: dice `npm install -g @playwright/mcp@latest`, pero el paquete correcto es `npm install -g playwright-cli`.

**Cómo evitar:** El CONTEXT.md y el specifics de Phase 2 son correctos: `npm install -g playwright-cli`. El planner y ejecutor deben usar esta versión, ignorando PROJECT.md §Context.

---

## Code Examples

### Comandos clave para el protocolo (verificados en references/playwright-cli-commands.md)

```bash
# Paso 0 — verificar instalación
playwright-cli --version

# Paso 1 — listar sessions existentes antes de abrir una nueva
playwright-cli list

# Paso 2 — abrir session nombrada persistente
playwright-cli -s=mi-app open https://localhost:3000 --persistent

# Paso 2 — snapshot inicial (obligatorio antes de primera interacción)
playwright-cli -s=mi-app snapshot

# Paso 3 — diagnóstico ante error (siempre ambos)
playwright-cli -s=mi-app console
playwright-cli -s=mi-app network

# Paso 5 — re-test desde snapshot
playwright-cli -s=mi-app snapshot
# ... reproducir flujo completo
```

### Patrón de lookup de credenciales (instrucción para Claude)

```bash
# En bash, buscar credenciales en orden de precedencia
for file in .env.local .env.development .env; do
  if [ -f "$file" ]; then
    grep -E '(_URL|_USER|_PASSWORD|_EMAIL|_TOKEN|_API_KEY)=' "$file"
    break  # usar el primero que encuentre
  fi
done
```

**Nota:** Este bash es una referencia de implementación — el SKILL.md instruye a Claude a ejecutar esta búsqueda, no necesariamente con este script exacto.

### Patrón de state-save para OAuth/2FA

```bash
# Después de que el usuario se loguea manualmente
playwright-cli -s=mi-app state-save auth.json

# En sesiones futuras, cargar el estado guardado
playwright-cli -s=mi-app state-load auth.json
```

---

## State of the Art

| Aspecto | Estado actual del skill | Estado objetivo (Phase 2) |
|---------|------------------------|--------------------------|
| SKILL.md | 28 líneas con 3 secciones TODO | 130-170 líneas con protocolo completo |
| Protocolo | Inexistente (TODO) | 5 pasos numerados con tabla de diagnóstico |
| Reglas | Inexistentes (TODO) | 6 reglas NUNCA/SIEMPRE con razones |
| Triggers/Boundaries | Inexistentes (TODO) | Positivos + negativos con alternativas |

---

## Open Questions

1. **¿Cómo usar skill-creator cuando el contenido ya está completamente definido?**
   - Lo que sabemos: skill-creator está diseñado para iterar sobre contenido con feedback de usuario. Phase 2 tiene el contenido completamente especificado en CONTEXT.md.
   - Lo que no está claro: si tiene sentido correr el loop de evals de skill-creator en Phase 2, o si Phase 2 es solo redacción y Phase 3 corre los evals.
   - Recomendación: Phase 2 usa skill-creator para redactar el SKILL.md (draft del skill), pero el loop de evaluación (evals.json, benchmark, viewer) se ejecuta en Phase 3. Esto es consistente con la separación de fases en ROADMAP.md.

2. **Verificación del comportamiento de `playwright-cli snapshot` (blocker documentado en STATE.md)**
   - Lo que sabemos: STATE.md documenta "Verificar comportamiento exacto de `playwright-cli snapshot` (escribe a archivo, path exacto pendiente de confirmar con `--help`)".
   - Lo que vemos en references/playwright-cli-commands.md: la referencia muestra que si `--filename` no se provee, playwright-cli crea un archivo con timestamp en `.playwright-cli/`. El path es `.playwright-cli/page-<timestamp>.yml`.
   - Recomendación: Este blocker está resuelto por la referencia de comandos. El protocolo puede simplemente decir "snapshot" sin especificar path — playwright-cli maneja el archivo automáticamente.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | No hay framework de tests automatizados para skills en Phase 2 |
| Config file | N/A — los evals de skills son específicos de skill-creator |
| Quick run command | `wc -l ~/.claude/skills/playwright-testing/SKILL.md` (verificar límite 300 líneas) |
| Full suite command | skill-creator evals (Phase 3) |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PROTO-01 a PROTO-09 | Protocolo de 5 pasos completo en SKILL.md | Manual — revisar sección "Protocolo de diagnóstico" | `grep -c "Paso" ~/.claude/skills/playwright-testing/SKILL.md` | ✅ SKILL.md existe |
| RULE-01 a RULE-06 | Sección Reglas con 6 reglas NUNCA/SIEMPRE | Manual — revisar sección "Reglas" | `grep -c "NUNCA\|SIEMPRE" ~/.claude/skills/playwright-testing/SKILL.md` | ✅ SKILL.md existe |
| TRIG-01 a TRIG-03 | Triggers positivos en sección Triggers | Manual — revisar sección "Triggers y Boundaries" | `grep -c "NO usar" ~/.claude/skills/playwright-testing/SKILL.md` | ✅ SKILL.md existe |
| TRIG-04 | Boundaries negativos con alternativas | Manual — verificar que cada "NO usar" tiene alternativa | `grep -A1 "NO usar" ~/.claude/skills/playwright-testing/SKILL.md` | ✅ SKILL.md existe |
| STRUC-01 | SKILL.md < 300 líneas | Automated | `wc -l ~/.claude/skills/playwright-testing/SKILL.md` | ✅ SKILL.md existe |

### Sampling Rate

- **Por tarea completada:** `wc -l ~/.claude/skills/playwright-testing/SKILL.md`
- **Al final de la fase:** Review manual completo del SKILL.md contra cada success criterion
- **Phase gate:** SKILL.md con todas las secciones reemplazadas y < 300 líneas

### Wave 0 Gaps

Ninguno — la infraestructura existente (SKILL.md, references/) es suficiente para Phase 2. Los evals de skill-creator son trabajo de Phase 3.

---

## Sources

### Primary (HIGH confidence)

- `.planning/phases/02-protocolo-y-reglas/02-CONTEXT.md` — Todas las decisiones de implementación de Phase 2 (leído directo)
- `~/.claude/skills/playwright-testing/references/playwright-cli-commands.md` — Referencia oficial de comandos playwright-cli de Microsoft (leído directo, 279 líneas verificadas)
- `~/.claude/skills/playwright-testing/SKILL.md` — Estado actual del skill a modificar (leído directo)
- `.planning/REQUIREMENTS.md` — Todos los requirements PROTO/RULE/TRIG de Phase 2 (leído directo)
- `~/.claude/skills/skill-creator/SKILL.md` — Cómo usar skill-creator correctamente (leído directo)

### Secondary (MEDIUM confidence)

- `.planning/STATE.md` — Contexto de decisiones acumuladas y el blocker documentado sobre snapshot (leído directo, blocker resuelto por la referencia de comandos)
- `.planning/PROJECT.md` — Constraints del proyecto (leído directo — nota: el comando de instalación en §Context tiene un error, ignorar a favor de CONTEXT.md)

### Tertiary (LOW confidence)

Ninguna — toda la información necesaria viene de archivos del proyecto leídos directamente.

---

## Metadata

**Confidence breakdown:**
- Protocolo de 5 pasos: HIGH — completamente especificado en CONTEXT.md con decisiones bloqueadas
- Reglas NUNCA/SIEMPRE: HIGH — 6 reglas con contenido semántico definido en CONTEXT.md y REQUIREMENTS.md
- Triggers y Boundaries: HIGH — formato y contenido especificados en CONTEXT.md
- Uso de skill-creator: MEDIUM — la mecánica de usar skill-creator para contenido pre-especificado requiere juicio del ejecutor sobre hasta dónde correr el loop
- Límite de líneas: HIGH — verificable con `wc -l`

**Research date:** 2026-03-19
**Valid until:** Sin expiración — todo el conocimiento viene de archivos del proyecto, no de fuentes externas
