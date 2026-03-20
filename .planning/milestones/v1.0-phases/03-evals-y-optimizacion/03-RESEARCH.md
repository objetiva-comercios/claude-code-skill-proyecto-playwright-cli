# Phase 03: Evals y Optimización - Research

**Researched:** 2026-03-19
**Domain:** skill-creator evals y trigger rate optimization
**Confidence:** HIGH

## Summary

Esta fase agrega validación cuantitativa al skill playwright-testing. El SKILL.md está completo (Phase 2 output, 100 líneas, protocolo + reglas + triggers). El trabajo se divide en dos partes independientes: (1) crear los archivos de evals (evals.json + trigger_evals.json) con los test cases especificados en CONTEXT.md, y (2) correr el loop de optimización `run_loop.py` para mejorar la description del frontmatter hasta trigger rate >80%.

El stack está completamente definido y verificado: skill-creator ya existe, los scripts run_loop.py y run_eval.py están disponibles en `~/.claude/skills/skill-creator/scripts/`, y el directorio `~/.claude/skills/playwright-testing/evals/` existe vacío (solo `.gitkeep`). No hay ambigüedad sobre herramientas — skill-creator es obligatorio.

**Primary recommendation:** Crear los dos archivos JSON primero (evals.json y trigger_evals.json), luego correr `python -m scripts.run_loop` desde el directorio skill-creator con max 5 iteraciones, y finalmente actualizar la description en SKILL.md con el best_description del output JSON.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Test cases (5 positivos)**
- Los 5 escenarios del ROADMAP: error al guardar formulario, login roto, CRUD sin credenciales, 403 forbidden, botón sin respuesta
- Prompts en español, nivel "usuario típico" — como hablaría alguien que no sabe de playwright
- NUNCA mencionar "playwright" ni "testing" explícitamente en los prompts (EVAL-02)
- Ejemplos de tono: "el formulario no guarda", "no puedo hacer login", "me da 403 al entrar"

**Assertions por test case**
- Solo las assertions que aplican al escenario (no todas en cada test)
- Cada test tiene 3-5 assertions relevantes
- Verificación sobre el output textual (transcript), no sobre ejecución real de comandos
- 4 niveles de assertion disponibles:
  1. **Herramienta correcta**: transcript menciona playwright-cli, no curl/MCP/scripts
  2. **Protocolo completo**: session nombrada (-s=nombre), snapshot antes de interactuar, console+network ante error, ciclo re-test
  3. **Credenciales buscadas**: buscó en .env antes de preguntar (solo en casos con auth)
  4. **Diagnóstico correcto**: identificó causa raíz según la tabla (401→credenciales, 500→backend, etc.)

**Formato de evals (dos archivos)**
- **evals/evals.json**: 5 quality evals con formato skill-creator (prompt, expected_output, expectations)
- **evals/trigger_evals.json**: 8 trigger rate evals para run_loop.py (query + should_trigger) — 5 positivos + 3 negativos
- Los 3 negativos (should_trigger: false): "corré los unit tests", "hace un curl a la API de pagos", "ejecutá esta query SQL"

**Estrategia de optimización**
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

### Deferred Ideas (OUT OF SCOPE)
- README.md del repo — después de Phase 3 con skill completo
- DEPLOY.md del repo — después de Phase 3 con skill completo
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| EVAL-01 | evals/evals.json con 5 test cases del PRD (error al guardar, login, CRUD sin credenciales, 403, botón sin respuesta) | Schema verificado: `{skill_name, evals[{id, prompt, expected_output, expectations}]}`. Ubicación: `~/.claude/skills/playwright-testing/evals/evals.json` |
| EVAL-02 | Test cases incluyen prompts ambiguos que no mencionan "playwright" explícitamente | Decisión locked en CONTEXT.md. Prompts en español, tono usuario frustrado, sin mencionar "playwright" ni "testing" |
| EVAL-03 | Assertions verifican: herramienta correcta, session nombrada, snapshot primero, diagnóstico completo, credenciales, ciclo completo | 4 niveles de assertion definidos en CONTEXT.md. Verificación sobre texto del transcript, 3-5 assertions por test |
| EVAL-04 | Description optimizada via skill-creator run_loop.py con trigger rate >80% | Script verificado en `~/.claude/skills/skill-creator/scripts/run_loop.py`. Requiere trigger_evals.json con formato `[{query, should_trigger}]` |
</phase_requirements>

---

## Standard Stack

### Core

| Herramienta | Versión/Path | Propósito | Por qué es estándar |
|-------------|-------------|-----------|---------------------|
| skill-creator | `~/.claude/skills/skill-creator/` | Creación y optimización de skills | Obligatorio por PROJECT.md |
| run_loop.py | `~/.claude/skills/skill-creator/scripts/run_loop.py` | Loop de optimización de trigger rate | Script oficial de skill-creator |
| run_eval.py | `~/.claude/skills/skill-creator/scripts/run_eval.py` | Evaluación individual de trigger rate | Usado internamente por run_loop.py |
| evals.json | Schema: `{skill_name, evals[{id,prompt,expected_output,expectations}]}` | Quality evals del skill | Formato oficial skill-creator |
| trigger_evals.json | Schema: `[{query, should_trigger}]` | Trigger rate evals para run_loop | Formato plano que espera run_loop.py |

### Rutas relevantes

| Path | Estado | Nota |
|------|--------|------|
| `~/.claude/skills/playwright-testing/SKILL.md` | Existe, completo | Phase 2 output — no modificar hasta run_loop |
| `~/.claude/skills/playwright-testing/evals/` | Existe vacío | Solo tiene `.gitkeep` — listo para recibir JSONs |
| `~/.claude/skills/playwright-testing/evals/evals.json` | No existe | EVAL-01 a crear |
| `~/.claude/skills/playwright-testing/evals/trigger_evals.json` | No existe | EVAL-04 a crear |
| `~/.claude/skills/skill-creator/scripts/run_loop.py` | Existe | Script de optimización verificado |

### Comando de optimización

```bash
cd ~/.claude/skills/skill-creator
python -m scripts.run_loop \
  --eval-set ~/.claude/skills/playwright-testing/evals/trigger_evals.json \
  --skill-path ~/.claude/skills/playwright-testing \
  --model claude-sonnet-4-6 \
  --max-iterations 5 \
  --runs-per-query 3 \
  --verbose
```

Output clave: `best_description` en el JSON de salida — se copia al frontmatter de SKILL.md.

---

## Architecture Patterns

### Estructura de archivos a crear

```
~/.claude/skills/playwright-testing/
├── SKILL.md                     # Ya existe — se modifica al final (description)
└── evals/
    ├── evals.json               # CREAR: 5 quality evals (EVAL-01, EVAL-02, EVAL-03)
    └── trigger_evals.json       # CREAR: 8 trigger evals (EVAL-04)
```

### Patrón 1: evals.json para quality evals

**Qué:** 5 test cases que evalúan si el skill produce output correcto (protocolo, herramientas, diagnóstico).
**Cuándo usar:** Verificación cualitativa — las assertions se checan contra el transcript textual de la respuesta.

```json
// Fuente: ~/.claude/skills/skill-creator/references/schemas.md (verificado)
{
  "skill_name": "playwright-testing",
  "evals": [
    {
      "id": 1,
      "prompt": "el formulario de contacto no guarda nada cuando le doy submit, no aparece ningún mensaje de error",
      "expected_output": "Claude usa playwright-cli con session nombrada, toma snapshot, ejecuta console + network ante el error, identifica causa raíz y muestra resumen antes de proponer fix",
      "expectations": [
        "El transcript menciona playwright-cli (no curl, no MCP, no scripts Node.js)",
        "Usa flag -s= o --session= con nombre de proyecto en los comandos",
        "Ejecuta snapshot antes de interactuar con el formulario",
        "Ejecuta console Y network ante el error (ambos)",
        "Muestra resumen de diagnóstico antes de tocar código"
      ]
    }
  ]
}
```

**Nota sobre assertions:** Las expectations son strings descriptivos que un grader lee y evalúa contra el transcript. No son regex ni code — son afirmaciones en lenguaje natural verificables en el texto de la respuesta.

### Patrón 2: trigger_evals.json para run_loop.py

**Qué:** 8 queries (5 positivos + 3 negativos) que miden si la description del frontmatter activa el skill correctamente.
**Cuándo usar:** Optimización del trigger rate — este es el formato plano que espera run_loop.py.

```json
// Fuente: ~/.claude/skills/skill-creator/scripts/run_loop.py (verificado — línea 261)
[
  {"query": "el formulario no guarda cuando le doy submit", "should_trigger": true},
  {"query": "no puedo hacer login, me dice que la contraseña está mal pero sé que es correcta", "should_trigger": true},
  {"query": "me da 403 al entrar a la sección de admin", "should_trigger": true},
  {"query": "hice un CRUD de productos pero no puedo crear nada, no sé si es un problema de permisos", "should_trigger": true},
  {"query": "el botón de pagar no hace nada cuando lo aprieto", "should_trigger": true},
  {"query": "corré los unit tests del proyecto y decime si pasan", "should_trigger": false},
  {"query": "hace un curl a la API de pagos para ver si responde", "should_trigger": false},
  {"query": "ejecutá esta query SQL en la base de datos y decime cuántos usuarios hay", "should_trigger": false}
]
```

**Diferencia crítica:** evals.json usa formato `{skill_name, evals[...]}` (objeto). trigger_evals.json es una **lista plana** `[...]` (array). Son archivos distintos con propósitos distintos.

### Patrón 3: Actualización de description post-run_loop

**Qué:** Al terminar run_loop.py, tomar `best_description` del output JSON y reemplazar el campo `description:` en el frontmatter de SKILL.md.
**Cuándo usar:** Solo si best_score es 70%+ (o es el mejor tras 5 iteraciones).

```python
# run_loop.py output (verificado — línea 228-240 del script)
{
  "exit_reason": "max_iterations (5)",
  "original_description": "...",
  "best_description": "...",   # <-- Este va al frontmatter
  "best_score": "7/8",
  "iterations_run": 5,
  ...
}
```

La actualización en SKILL.md es solo la línea `description:` del frontmatter YAML. El cuerpo del skill no cambia.

### Anti-Patterns a Evitar

- **Mencionar "playwright" en prompts de trigger_evals:** Si el prompt dice "usá playwright para debuggear el login", siempre va a triggerear — no mide la calidad de la description. Los prompts deben ser como hablaría un usuario que no conoce la herramienta.
- **Mismo prompt en evals.json y trigger_evals.json:** No es incorrecto, pero trigger_evals debe ser más variado y cubrir edge cases.
- **Correr run_loop.py desde directorio incorrecto:** El script usa `find_project_root()` que busca `.claude/` subiendo desde cwd. Correr desde `~/.claude/skills/skill-creator/` es seguro, pero verificar que encuentre el project root correcto del repo de trabajo.
- **Asumir que evals.json es input de run_loop.py:** run_loop.py SOLO acepta el formato lista plana `[{query, should_trigger}]`. evals.json es para quality evals con run_eval.py (herramienta diferente).

---

## Don't Hand-Roll

| Problema | No construir | Usar en cambio | Por qué |
|----------|-------------|----------------|---------|
| Loop de optimización de description | Script propio de eval+improve | `run_loop.py` de skill-creator | Ya maneja train/test split, paralelismo, HTML report, history tracking |
| Evaluación de trigger rate | Subprocess propio de `claude -p` | `run_eval.py` de skill-creator | Maneja múltiples runs, threshold, early detection vía stream events |
| Actualización de description | Edición manual sin verificar score | Output `best_description` de run_loop + Edit tool | run_loop elige por test score (no train) para evitar overfitting |

**Key insight:** skill-creator ya resuelve el problema de undertriggering con un loop probado. No hay que inventar métricas ni scripts de evaluación — el tooling existe y está verificado en producción.

---

## Common Pitfalls

### Pitfall 1: Formato incorrecto en trigger_evals.json

**Qué va mal:** run_loop.py lanza error `json.loads` o procesa 0 queries si el archivo tiene formato de evals.json (objeto con `skill_name` y `evals`).
**Por qué ocurre:** Hay dos formatos distintos (quality evals vs trigger evals) y la documentación del CONTEXT.md los distingue, pero es fácil mezclarlos.
**Cómo evitar:** trigger_evals.json es una **lista JSON** en el top level: `[{...}, {...}]`. evals.json es un **objeto**: `{skill_name: ..., evals: [...]}`.
**Señales de alerta:** run_loop.py imprime `0 queries` o error de parsing inmediatamente.

### Pitfall 2: run_loop.py corre desde directorio incorrecto

**Qué va mal:** `ModuleNotFoundError: No module named 'scripts'` o `find_project_root()` retorna directorio incorrecto.
**Por qué ocurre:** run_loop.py usa `python -m scripts.run_loop` que requiere que el cwd sea `~/.claude/skills/skill-creator/`.
**Cómo evitar:** Siempre hacer `cd ~/.claude/skills/skill-creator/` antes de correr el script.
**Señales de alerta:** Error de import al iniciar el script.

### Pitfall 3: Prompts de quality evals demasiado cortos

**Qué va mal:** Claude no triggerear el skill para prompts de una línea simples ("arreglá el formulario").
**Por qué ocurre:** Según la documentación de skill-creator (SKILL.md, sección "How skill triggering works"): Claude solo consulta skills para tareas complejas o multi-step. Prompts simples de una línea pueden no triggerear aunque la description matchee.
**Cómo evitar:** Los prompts de trigger_evals deben tener suficiente contexto y detalle — "el formulario de contacto no guarda nada cuando le doy submit, no aparece ningún mensaje de error" es mejor que "el formulario no guarda".
**Señales de alerta:** Trigger rate 0% para prompts debería-triggerear en la iteración 1.

### Pitfall 4: Aceptar result <70% sin revisar evals primero

**Qué va mal:** run_loop llega a 5 iteraciones con score 60% y se actualiza la description igualmente.
**Por qué ocurre:** La decisión del usuario es clara: si es <70%, revisar los evals antes de reintentar. El problema puede ser en los evals (mal redactados) no en la description.
**Cómo evitar:** Evaluar el score antes de updatear SKILL.md. Si best_score < 70%, reportar al usuario antes de modificar nada.

### Pitfall 5: run_loop modifica SKILL.md automáticamente

**Qué va mal:** run_loop.py NO modifica SKILL.md automáticamente — solo retorna `best_description` en el JSON de output.
**Por qué ocurre:** Confusión del CONTEXT.md que dice "run_loop puede alargarla o acortarla libremente" — esto se refiere a la description que propone, no a que edite el archivo.
**Cómo evitar:** Después de run_loop.py, leer el JSON output, extraer `best_description`, y actualizar manualmente el frontmatter de SKILL.md con Edit tool.
**Verificación:** Revisar SKILL.md antes y después — el campo `description:` debe cambiar; el cuerpo no.

---

## Code Examples

### evals.json — Estructura completa verificada

```json
// Fuente: ~/.claude/skills/skill-creator/references/schemas.md
{
  "skill_name": "playwright-testing",
  "evals": [
    {
      "id": 1,
      "prompt": "el formulario de contacto no guarda nada cuando le doy submit",
      "expected_output": "Claude usa playwright-cli para abrir el browser, toma snapshot inicial, toma snapshot del formulario, hace submit, ejecuta console y network ante el error, identifica causa raíz y propone fix",
      "expectations": [
        "El transcript menciona playwright-cli y no curl ni fetch ni MCP",
        "Usa flag -s= con nombre de proyecto (no abre browser sin session)",
        "Toma snapshot antes de interactuar con el formulario",
        "Ejecuta tanto playwright-cli console como playwright-cli network (ambos)",
        "Muestra resumen de error + causa + acción antes de modificar código"
      ]
    }
  ]
}
```

### trigger_evals.json — Estructura completa verificada

```json
// Fuente: ~/.claude/skills/skill-creator/scripts/run_loop.py línea 261
[
  {"query": "el formulario no guarda cuando le doy submit, no sé qué está pasando", "should_trigger": true},
  {"query": "no puedo hacer login, me dice que la contraseña está mal pero sé que es correcta", "should_trigger": true},
  {"query": "me da 403 al entrar a la sección de admin de la app", "should_trigger": true},
  {"query": "hice un CRUD de productos pero no puedo crear nada, no sé si es permisos o qué", "should_trigger": true},
  {"query": "el botón de pagar no hace nada cuando lo aprieto, ni siquiera gira el spinner", "should_trigger": true},
  {"query": "corré los unit tests del proyecto y decime si pasan todos", "should_trigger": false},
  {"query": "hace un curl a la API de pagos para ver si responde bien", "should_trigger": false},
  {"query": "ejecutá esta query SQL en la base de datos y decime cuántos usuarios hay registrados", "should_trigger": false}
]
```

### Comando run_loop.py — Parámetros recomendados

```bash
# Desde ~/.claude/skills/skill-creator/
python -m scripts.run_loop \
  --eval-set ~/.claude/skills/playwright-testing/evals/trigger_evals.json \
  --skill-path ~/.claude/skills/playwright-testing \
  --model claude-sonnet-4-6 \
  --max-iterations 5 \
  --runs-per-query 3 \
  --trigger-threshold 0.5 \
  --verbose
```

**Parámetros clave:**
- `--runs-per-query 3`: Cada query se corre 3 veces para trigger rate confiable. Con 8 queries = 24 runs por iteración.
- `--trigger-threshold 0.5`: Un query "pasa" si triggerear ≥ 50% de las veces (≥2 de 3 runs).
- `--max-iterations 5`: Locked decision del CONTEXT.md.
- El script automáticamente hace 60/40 train/test split.

### Actualización de SKILL.md post-optimización

```bash
# Leer output de run_loop.py y extraer best_description
# Luego con Edit tool: reemplazar solo la línea description: en el frontmatter

# Frontmatter actual (antes):
---
name: playwright-testing
description: Fuerza el uso de playwright-cli como unico punto de entrada...
allowed-tools: Bash(playwright-cli:*)
---

# Después de run_loop (best_description reemplaza description):
---
name: playwright-testing
description: <best_description del output de run_loop.py>
allowed-tools: Bash(playwright-cli:*)
---
```

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | skill-creator run_eval.py (trigger rate evaluation) |
| Config file | trigger_evals.json (a crear en Wave 1) |
| Quick run command | `cd ~/.claude/skills/skill-creator && python -m scripts.run_eval --eval-set ~/.claude/skills/playwright-testing/evals/trigger_evals.json --skill-path ~/.claude/skills/playwright-testing --model claude-sonnet-4-6 --runs-per-query 1 --verbose` |
| Full suite command | `cd ~/.claude/skills/skill-creator && python -m scripts.run_loop --eval-set ~/.claude/skills/playwright-testing/evals/trigger_evals.json --skill-path ~/.claude/skills/playwright-testing --model claude-sonnet-4-6 --max-iterations 5 --runs-per-query 3 --verbose` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| EVAL-01 | evals.json con 5 test cases | manual | Inspección del archivo JSON | ❌ Wave 0 |
| EVAL-02 | Prompts no mencionan "playwright" | manual | `grep -i "playwright" ~/.claude/skills/playwright-testing/evals/evals.json` (debe dar 0 en los prompts) | ❌ Wave 0 |
| EVAL-03 | Assertions cubren 4 niveles | manual | Inspección de expectations en evals.json | ❌ Wave 0 |
| EVAL-04 | Trigger rate >80% via run_loop | automated | `python -m scripts.run_loop ... --max-iterations 5` (score en output JSON) | ❌ Wave 0 |

### Sampling Rate

- **Por tarea completada:** Verificar estructura JSON del archivo creado (schema correcto, ids únicos, sin errores)
- **Validación final:** Correr run_loop.py completo — el score `best_score` en el output JSON es la métrica de éxito de la fase
- **Phase gate:** `best_score` ≥ 6/8 (75%+) antes de updatear SKILL.md y cerrar la fase

### Wave 0 Gaps

- [ ] `~/.claude/skills/playwright-testing/evals/evals.json` — cubre EVAL-01, EVAL-02, EVAL-03
- [ ] `~/.claude/skills/playwright-testing/evals/trigger_evals.json` — cubre EVAL-04

*(Ningún gap de infraestructura — skill-creator ya instalado, scripts verificados, directorio evals existe)*

---

## State of the Art

| Approach Anterior | Approach Actual | Impacto |
|-------------------|-----------------|---------|
| Description escrita manualmente (Phase 1) | Description optimizada con run_loop.py (Phase 3) | Trigger rate medido vs. intuitivo |
| SKILL.md con TODO placeholders | SKILL.md completo (Phase 2) | Evals pueden verificar protocolo real |
| Sin evals | evals.json + trigger_evals.json | Calidad verificable y reproducible |

---

## Open Questions

1. **¿Cuántas iteraciones necesitará run_loop para superar 80%?**
   - Lo que sabemos: description actual es "pushy" por diseño (Phase 1), protocolo completo en SKILL.md
   - Lo que no está claro: si la description actual ya supera 80% en la iteración 1
   - Recomendación: correr las 5 iteraciones de todas formas para explorar el espacio — el fallback de "aceptar 70%+ o el mejor de 5" está definido

2. **¿runs-per-query 1 vs 3 para run_eval rápido?**
   - Con `--runs-per-query 1` se puede verificar trigger rate en ~2 min por iteración (sin warmup completo)
   - Con `--runs-per-query 3` (default) el resultado es más confiable estadísticamente
   - Recomendación: usar 3 en el run final (run_loop), aceptar 1 en verificaciones rápidas

---

## Sources

### Primary (HIGH confidence)
- `~/.claude/skills/skill-creator/scripts/run_loop.py` — verificado: formato de entrada, parámetros CLI, estructura de output JSON
- `~/.claude/skills/skill-creator/scripts/run_eval.py` — verificado: cómo evalúa trigger rate, threshold, formato de resultado
- `~/.claude/skills/skill-creator/references/schemas.md` — verificado: schema de evals.json (skill_name + evals array)
- `~/.claude/skills/skill-creator/SKILL.md` — verificado: instrucciones de uso, sección "Description Optimization"
- `~/.claude/skills/playwright-testing/SKILL.md` — verificado: contenido completo Phase 2, description actual
- `.planning/phases/03-evals-y-optimizacion/03-CONTEXT.md` — fuente de todas las decisiones locked

### Secondary (MEDIUM confidence)
- `.planning/REQUIREMENTS.md` — definición de EVAL-01 a EVAL-04 verificada contra CONTEXT.md

### Tertiary (LOW confidence)
- Ninguno — todas las afirmaciones tienen fuente primaria verificada

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — scripts verificados con lectura directa del código fuente
- Architecture patterns: HIGH — schemas verificados contra código real de run_loop.py
- Pitfalls: HIGH — derivados del código fuente (run_loop.py línea 261, schemas.md formato exacto)
- Validation: HIGH — comandos tomados directamente de los scripts

**Research date:** 2026-03-19
**Valid until:** 2026-06-19 (herramientas estables, sin versiones en vuelo)
