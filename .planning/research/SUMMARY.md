# Project Research Summary

**Project:** claude-code-skill-proyecto-playwright-cli
**Domain:** Claude Code skill — protocolo de testing de browser con playwright-cli
**Researched:** 2026-03-17
**Confidence:** HIGH

## Executive Summary

Este proyecto es una Claude Code skill que envuelve el CLI `@playwright/cli` para dar a Claude un protocolo estructurado y reproducible de interaccion con browsers reales. El objetivo central no es solo exponer comandos de playwright-cli, sino resolver el problema de undertriggering (el skill no se activa cuando deberia) y reemplazar los defaults de Claude (Playwright MCP, curl, scripts Node.js ad-hoc) con un protocolo de 5 pasos que incluye diagnostico obligatorio via consola y red. La investigacion confirma que el approach correcto es: SKILL.md principal bajo 300 lineas con el protocolo al frente, referencia de comandos en archivo separado descargado del repo oficial, y descripcion "pushy" optimizada con el loop de `skill-creator`.

El riesgo principal y mas documentado es el undertriggering: Claude tiene una tendencia estructural a no activar skills cuando la descripcion del frontmatter no enumera explicitamente los contextos de uso desde la perspectiva del usuario. La diferencia entre una descripcion generica (20% trigger rate) y una con ejemplos concretos (90% trigger rate) es dramatica. Esto hace que la descripcion y el ciclo de optimizacion sean criticos para el exito. Un skill con protocolo perfecto y trigger rate bajo es inutil en la practica.

El stack es minimal: `@playwright/cli@0.1.1` (instalacion global, sin dependencias en el skill mismo), la herramienta `skill-creator` para el loop de evals y optimizacion de descripcion, Node.js 22 (ya disponible) y Python 3.12 (ya disponible). El orden de construccion tiene una dependencia critica: la referencia de comandos primero, luego el protocolo, luego las evals, y solo al final la optimizacion de descripcion.

## Key Findings

### Recommended Stack

El skill en si es un directorio de archivos markdown — no tiene dependencias npm propias. La unica instalacion externa requerida es `npm install -g @playwright/cli@latest` para el binario `playwright-cli`. El proceso de desarrollo usa `skill-creator` para ejecutar el loop de evals y optimizar la descripcion con `scripts/run_loop.py --model claude-sonnet-4-6`.

**Core technologies:**
- `@playwright/cli@0.1.1`: binario CLI de browser automation — unico punto de entrada al browser (4x mas eficiente en tokens que Playwright MCP)
- Claude Code Skills (SKILL.md format): contenedor del protocolo — discovery automatico via frontmatter, carga progresiva de referencias
- `skill-creator` (skill local): loop de eval y optimizacion — escribe, testea, gradea, optimiza descripcion hasta >80% trigger rate
- Node.js >=18 (disponible: 22.22.0): runtime para playwright-cli
- Python >=3.10 (disponible: 3.12.3): scripts de skill-creator (sin pip install, solo stdlib)

### Expected Features

La investigacion es clara: todas las features de v1 son P1 porque sin cualquiera de ellas el skill no cumple su funcion. No hay features opcionales en el MVP.

**Must have (table stakes):**
- Protocolo de 5 pasos explicito (snapshot → reproducir → console/network → fix → re-test) — sin esto no hay valor diferencial
- Reglas NUNCA/SIEMPRE con razon explicada — sin contexto "por que", Claude las ignora bajo presion de tarea
- Descripcion con trigger rate alto y ejemplos concretos — sin trigger rate el resto no importa
- Sessions nombradas por proyecto (`--session=<nombre>`) — prerequisito para flujos con estado
- Diagnostico obligatorio console + network ante errores — el nucleo del valor diferencial
- Protocolo de credenciales: buscar .env antes de preguntar — autonomia para apps con login
- Referencia de comandos en archivo separado (`references/`) — permite SKILL.md < 300 lineas
- Boundaries explicitos (cuando NO usar el skill) — evita over-triggering con APIs sin frontend

**Should have (competitive):**
- Manejo de storage state para autenticacion persistente — evita re-login en cada sesion de diagnostico
- 5 test cases con assertions para evals — mide calidad del skill objetivamente con skill-creator
- Comparacion tokens MCP vs CLI documentada — argumento concreto para elegir el skill sobre el default

**Defer (v2+):**
- Cobertura completa DevTools (trace, video recording) — beneficio incremental sobre console/network basico
- Integracion con CI/CD — fuera de scope por definicion; requiere skill separado `playwright-test-generator`

### Architecture Approach

El skill tiene tres capas con responsabilidades separadas: el frontmatter YAML (siempre en contexto, es el unico mecanismo de trigger), el cuerpo del SKILL.md (cargado al triggear, contiene el protocolo), y `references/playwright-cli-commands.md` (cargado bajo demanda cuando el protocolo lo indica). Las evals en `evals/evals.json` son artifacts de desarrollo — nunca se cargan en runtime. El patron clave es progressive disclosure: frontmatter liviano → protocolo conciso → referencia completa solo cuando se necesita.

**Major components:**
1. YAML frontmatter (`name` + `description`) — unico mecanismo de trigger; debe ser "pushy" con ejemplos de frases del usuario
2. SKILL.md body (protocolo de 5 pasos + reglas NUNCA/SIEMPRE) — cargado en cada invocacion; < 300 lineas obligatorio
3. `references/playwright-cli-commands.md` — referencia completa descargada del repo oficial; cargada solo al necesitar syntax
4. `evals/evals.json` — 5+ casos con assertions; usado solo por skill-creator; no referenciado en runtime
5. `playwright-cli` binary (externo) — unico punto de entrada al browser; ejecutado via Bash tool

### Critical Pitfalls

1. **Descripcion vaga que nunca triggerea** — escribir la descripcion desde la perspectiva de lo que el usuario dice ("el boton no responde", "verificar que el login anda"), no desde la funcion del skill; correr `run_loop.py` hasta >80% trigger rate
2. **Context budget excedido — skill invisible** — mantener descripcion en ≤130 caracteres; verificar visibilidad con `What skills are available?` en sesion con todos los skills activos; si se excede, usar `SLASH_COMMAND_TOOL_CHAR_BUDGET=30000`
3. **SKILL.md > 300 lineas — protocolo diluido** — protocolo y reglas NUNCA/SIEMPRE en el cuerpo principal; comandos completos solo en `references/`; el constraint de 300 lineas es un guardrail de diseno
4. **Reglas NUNCA sin contexto "por que" — ignoradas bajo presion** — cada regla debe incluir la consecuencia de violarla: "NUNCA uses curl porque curl no ejecuta JavaScript ni captura console errors — sin eso el diagnostico es ciego"
5. **Comandos playwright-cli incorrectos o confundidos con MCP** — descargar la referencia oficial del repo `microsoft/playwright-cli` antes de escribir el SKILL.md; nunca escribir comandos de memoria; documentar que snapshot escribe a archivo y debe leerse con Read

## Implications for Roadmap

La investigacion revela un orden de construccion con dependencias criticas. No se puede optimizar la descripcion sin evals. No se pueden escribir evals sin el protocolo. La referencia de comandos es el unico artefacto independiente. Esto sugiere 3 fases claras con una secuencia obligatoria.

### Phase 1: Estructura y Protocolo Base

**Rationale:** Construir las bases antes de evaluar. La referencia de comandos descargada del repo oficial es el prerequisito de todo lo demas porque garantiza que el protocolo usa comandos reales. Sin esto, cada paso siguiente puede estar construido sobre comandos inventados.
**Delivers:** Skill funcional instalado en `~/.claude/skills/playwright-testing/` con protocolo de 5 pasos, reglas NUNCA/SIEMPRE con razon, sessions nombradas, protocolo de credenciales, boundaries de scope, y referencia de comandos oficial.
**Addresses:** Todas las features P1 de FEATURES.md — protocolo de 5 pasos, reglas NUNCA/SIEMPRE, sessions nombradas, diagnostico console + network, boundaries explicitos, referencia separada
**Avoids:** Pitfall 3 (SKILL.md > 300 lineas), Pitfall 4 (reglas sin razon), Pitfall 5 (comandos incorrectos)

### Phase 2: Evals y Optimizacion de Descripcion

**Rationale:** Las evals no se pueden escribir sin conocer el protocolo (fase 1). La optimizacion de descripcion no se puede correr sin evals. Esta fase convierte el skill funcional en un skill confiable con trigger rate medido.
**Delivers:** `evals/evals.json` con 5+ casos que incluyen prompts ambiguos sin mencionar "playwright", descripcion optimizada con >80% trigger rate verificado, visibilidad confirmada en entorno real con todos los skills activos.
**Uses:** `skill-creator` con `run_loop.py --model claude-sonnet-4-6`, `aggregate_benchmark.py`, `eval-viewer`
**Implements:** Loop de evaluacion y optimizacion descrito en ARCHITECTURE.md — eval loop data flow y description optimization flow
**Avoids:** Pitfall 1 (undertriggering), Pitfall 2 (context budget), Pitfall 6 (evals demasiado simples)

### Phase 3: Features P2 y Validacion Final

**Rationale:** Las features P2 (storage state, comparacion tokens) son mejoras sobre un skill ya validado. Agregarlas antes de tener trigger rate confirmado es prematuro — si el skill no triggerea bien, no importa cuan buenas sean las features adicionales.
**Delivers:** Manejo de autenticacion persistente con storage state documentado en el protocolo, comparacion de tokens MCP vs CLI como argumento de adopcion, checklist "Looks Done But Isn't" verificada, skill empaquetado con `scripts/package_skill.py`.
**Avoids:** Deuda tecnica documentada en PITFALLS.md — "Saltar el description optimizer" y "Evals solo con happy path"

### Phase Ordering Rationale

- La referencia oficial debe descargarse antes de escribir un solo comando en SKILL.md — evita el pitfall mas costoso (comandos incorrectos) desde el principio
- El protocolo y las reglas NUNCA/SIEMPRE van al frente del SKILL.md por el sesgo de posicion de los LLMs (instrucciones al inicio tienen mas peso)
- Las evals se disefian con prompts ambiguos antes de correrlas — no se agregan despues como afterthought
- La optimizacion de descripcion es el ultimo paso de creacion, no el primero — necesita evals estables para optimizar contra ellas

### Research Flags

Phases con patrones bien documentados (skip research-phase):
- **Phase 1:** El formato SKILL.md, la estructura de directorios y los comandos playwright-cli estan completamente documentados en fuentes oficiales (microsoft/playwright-cli, Claude Code docs). No necesita investigacion adicional.
- **Phase 2:** El loop de skill-creator esta documentado en `~/.claude/skills/skill-creator/SKILL.md` con schemas exactos. No necesita investigacion adicional.

Phases que podrian necesitar validacion durante ejecucion:
- **Phase 2:** El trigger rate objetivo (>80%) es una metrica de la comunidad — verificar contra el comportamiento real del modelo `claude-sonnet-4-6` ya que puede variar.
- **Phase 3:** El comportamiento de `playwright-cli state-save`/`state-load` no esta extensamente documentado en el SKILL.md oficial de Microsoft — puede requerir verificacion manual del comando exacto.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Fuentes oficiales directas: npm registry, repo Microsoft, docs Claude Code oficiales. Binarios verificados en la maquina. |
| Features | HIGH | Derivadas del repo oficial de Microsoft + docs skill-creator + comportamiento documentado de Claude. Prioridades P1 sin ambiguedad. |
| Architecture | HIGH | Basado en `skill-creator/SKILL.md` leido directamente + skills de ejemplo en `~/.claude/skills/`. Patrones verificados en primera persona. |
| Pitfalls | HIGH | Documentados en fuentes oficiales (GitHub Issues de Anthropic, Claude Code docs) + primera persona desde skill-creator. Metricas concretas (20%/50%/90% trigger rates). |

**Overall confidence:** HIGH

### Gaps to Address

- **Comportamiento exacto de `playwright-cli snapshot`:** La investigacion indica que escribe a archivo en `.playwright-cli/` en lugar de stdout, pero el path exacto y el formato del archivo deben verificarse con `playwright-cli snapshot --help` antes de escribir el protocolo en SKILL.md.
- **Limite real del context budget en el entorno de este usuario:** La investigacion cita ~15,500-16,000 caracteres para el total de descriptions, pero el usuario tiene muchos skills y MCPs instalados — la visibilidad del nuevo skill debe verificarse empiricamente en Phase 2.
- **Version exacta del output format de `playwright-cli@0.1.1`:** La version es 0.1.1 (muy reciente) y la documentacion de terceros puede describir versiones anteriores. Siempre usar el SKILL.md oficial del repo como fuente de verdad.

## Sources

### Primary (HIGH confidence)
- `https://github.com/microsoft/playwright-cli` — comandos, flags, SKILL.md oficial, instalacion
- `https://code.claude.com/docs/en/skills` — SKILL.md structure, frontmatter fields, progressive disclosure
- `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` — description authoring, validation rules
- `/home/sanchez/.claude/skills/skill-creator/SKILL.md` — eval loop, run_loop.py, aggregate_benchmark.py, description optimizer
- `/home/sanchez/.claude/skills/skill-creator/references/schemas.md` — evals.json, grading.json, benchmark.json schemas
- `https://npm.im/@playwright/cli` — version 0.1.1, Node.js >=18

### Secondary (MEDIUM confidence)
- `https://testcollab.com/blog/playwright-cli` — CLI vs MCP positioning, token comparison (~27k vs ~114k)
- `https://block.github.io/goose/docs/tutorials/playwright-skill/` — Goose playwright skill como referencia de skill existente
- `https://gist.github.com/mellanon/50816550ecb5f3b239aa77eef7b8ed8d` — best practices de activacion de skills
- `https://blog.fsck.com/2025/12/17/claude-code-skills-not-triggering/` — bug de context budget con solucion
- `https://gist.github.com/alexey-pelykh/faa3c304f731d6a962efc5fa2a43abe1` — investigacion detallada del budget (~15,500-16,000 chars)

### Tertiary (MEDIUM-LOW confidence)
- `https://deepwiki.com/microsoft/playwright-cli/4-command-reference` — referencia estructurada de comandos (verificar contra repo oficial)
- `https://testdino.com/blog/playwright-cli/` — ejemplos de uso, consistente con docs oficiales
- `https://dev.to/oluwawunmiadesewa/claude-code-skills-not-triggering-2-fixes-for-100-activation-3b57` — fixes documentados para undertriggering

---
*Research completed: 2026-03-17*
*Ready for roadmap: yes*
