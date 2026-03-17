# Pitfalls Research

**Domain:** Claude Code skill development — CLI tool enforcement (playwright-cli)
**Researched:** 2026-03-17
**Confidence:** HIGH (official Claude Code docs + confirmed community reports + first-party skill-creator SKILL.md)

---

## Critical Pitfalls

### Pitfall 1: Description demasiado vaga — el skill nunca se activa

**What goes wrong:**
Claude evalua el campo `description` del frontmatter para decidir si invocar el skill. Si la descripcion describe lo que hace el skill en terminos abstractos en lugar de los contextos concretos donde debe activarse, Claude no lo asocia con los prompts del usuario y el skill permanece dormido. El problema se llama "undertriggering" y es la falla mas frecuente en el ecosistema de skills.

**Why it happens:**
Los creadores de skills naturalmente describen el skill desde el punto de vista de su funcion ("Runs playwright-cli for browser testing") en lugar del punto de vista del usuario ("what would a user say right before needing this?"). Claude solo ve el campo `description` para decidir — no hay otro mecanismo de auto-activacion. Una descripcion que no cubre las frases naturales del usuario produce cero activaciones automaticas.

**How to avoid:**
- Escribir la descripcion desde la perspectiva de lo que el usuario dice, no de lo que el skill hace
- Incluir frases concretas: "el formulario no funciona", "verificar que el login anda", "hay un error en el browser", "abrir el navegador", etc.
- Ser explicitamente "pushy": incluir "Use cuando el usuario menciona X, Y o Z — incluso si no pide playwright explicitamente"
- Correr el description optimizer de skill-creator (`scripts/run_loop.py`) antes de dar el skill por terminado
- El target es cubrir todas las variaciones de "quiero interactuar con un navegador web"

**Warning signs:**
- En las evals, el `without_skill` baseline produce el mismo resultado que `with_skill` (nunca se lee el skill)
- Al preguntar "What skills are available?" el skill aparece pero nunca se invoca automaticamente
- Claude usa curl, Playwright MCP o scripts de Node.js ad-hoc en lugar del skill cuando se pide testing de frontend

**Phase to address:**
Fase 1 (creacion del skill) — la descripcion inicial debe ser agresiva desde el primer draft. Fase 2 (evals y optimizacion) confirma con metricas reales.

---

### Pitfall 2: Context budget excedido — skill completamente invisible

**What goes wrong:**
Claude Code tiene un budget de caracteres para las descripciones de todos los skills combinados: 2% del context window, con un fallback de ~15,500-16,000 caracteres. Cuando el total de descripciones excede este limite, algunos skills son excluidos del system prompt por completo. Claude no puede invocar lo que no ve. En instalaciones con 63+ skills, se ha documentado que 33% de los skills son completamente invisibles.

**Why it happens:**
El budget se divide entre todos los skills instalados (~109 caracteres de overhead por skill + descripcion). El usuario de este skill tiene el CLAUDE.md global listando muchos MCPs y skills (Superpowers, obsidian-*, defuddle, frontend-design, etc.). Si la descripcion del nuevo skill es larga y ya hay muchos skills instalados, puede quedar fuera del budget.

**How to avoid:**
- Mantener la descripcion en ≤130 caracteres para maximizar visibilidad (permite ~67 skills en el budget)
- Front-loadear las palabras clave de trigger en los primeros 50 caracteres
- Verificar visibilidad con `What skills are available?` en una sesion real con todos los skills activos
- Si se excede el budget, configurar: `SLASH_COMMAND_TOOL_CHAR_BUDGET=30000` en el entorno antes de lanzar Claude
- No poner informacion de "como funciona" en la description — eso va en el cuerpo del SKILL.md

**Warning signs:**
- El skill aparece en `~/.claude/skills/playwright-testing/` pero no en la lista de `/context`
- Claude responde "I don't have a skill for that" cuando se le pregunta sobre playwright-cli
- El numero de skills visibles es menor que el numero total instalado

**Phase to address:**
Fase 1 al crear el skill. Fase 2 durante testing en entorno real con todos los skills de ~/.claude/skills/ activos.

---

### Pitfall 3: SKILL.md demasiado largo — Claude lee pero no sigue el protocolo completo

**What goes wrong:**
Cuando el cuerpo del SKILL.md supera las 300-500 lineas, Claude carga el contenido en contexto pero puede "diluirse" al procesar instrucciones distantes del comienzo. En particular, las reglas NUNCA/SIEMPRE al final del archivo son menos probables de seguirse que las del principio. Un protocolo de 5 pasos que ocupa 600 lineas produce seguimiento inconsistente del paso 4 y 5.

**Why it happens:**
Los LLMs tienen sesgo de posicion: las instrucciones al inicio del contexto tienen mas peso que las del medio o final. Un SKILL.md largo con el protocolo principal enterrado entre comandos de referencia diluye la senal. Ademas, el PROJECT.md ya establece < 300 lineas como constraint del proyecto.

**How to avoid:**
- SKILL.md principal: protocolo de 5 pasos + reglas NUNCA/SIEMPRE + referencia a archivos externos, TODO en < 300 lineas
- Comandos de playwright-cli: en `references/playwright-cli-commands.md` separado, con instruccion clara en el SKILL.md de cuando leerlo
- El protocolo de diagnostico va primero, los detalles de comandos van a la referencia
- Usar formato de lista numerada para el protocolo — es mas facil de seguir que prosa

**Warning signs:**
- En las evals, Claude ejecuta snapshot pero no ejecuta `console` + `network` ante errores (paso del diagnostico saltado)
- Claude sigue pasos 1-2 pero omite paso 4 (fix) o paso 5 (re-test)
- El SKILL.md supera 300 lineas antes de terminar la primera version

**Phase to address:**
Fase 1 al escribir el primer draft. El constraint de 300 lineas es un guardrail de diseno, no una restriccion arbitraria.

---

### Pitfall 4: Reglas NUNCA sin contexto "por que" — Claude las ignora bajo presion de tarea

**What goes wrong:**
Instrucciones como "NUNCA uses curl para testear interfaces web" o "NEVER use Playwright MCP" funcionan inicialmente pero cuando Claude enfrenta una tarea urgente o un contexto donde la alternativa parece mas eficiente, las viola. Esto es especialmente comun cuando el usuario da una instruccion directa que parece contradecir la regla del skill.

**Why it happens:**
Los LLMs priorizan completar la tarea del usuario sobre cumplir instrucciones de proceso cuando hay tension. Una regla sin razon explicada es procesada como una restriccion arbitraria. Con una razon clara ("usar playwright-cli asegura snapshots consistentes, acceso a network logs y reproducibilidad — curl no da ninguno de estos"), Claude entiende la logica y la mantiene incluso bajo presion. La skill-creator SKILL.md lo documenta explicitamente: "Try hard to explain the why behind everything".

**How to avoid:**
- Cada regla NUNCA debe incluir "porque [consecuencia de violarlo]"
- Cada regla SIEMPRE debe incluir "porque [beneficio especifico]"
- En lugar de lista de prohibiciones, describir el principio: "playwright-cli es el unico punto de entrada al navegador porque centraliza diagnostico y mantiene estado de sesion entre pasos"
- Evitar mayusculas gritadas como unico mecanismo de enforcement

**Warning signs:**
- En evals, Claude usa curl para chequear si una URL devuelve 200 en lugar de abrir con playwright-cli
- Claude propone "es mas rapido con MCP" y usa el MCP server en lugar del CLI
- Al dar feedback al skill-creator, Claude sugiere "simplificar" eliminando las restricciones

**Phase to address:**
Fase 1 al escribir el draft inicial. Fase 2 al revisar evals — buscar especificamente usos de herramientas prohibidas en los transcripts.

---

### Pitfall 5: Referencias a comandos playwright-cli desactualizadas o incorrectas

**What goes wrong:**
El skill incluye comandos que no existen, flags que han cambiado, o asume comportamiento de Playwright MCP (que es diferente a playwright-cli). Por ejemplo: confundir `@playwright/mcp` (el MCP server) con `playwright-cli` (el CLI standalone); usar `playwright` en lugar de `playwright-cli` como nombre del binario; asumir que el output de snapshot va inline cuando va a archivo.

**Why it happens:**
playwright-cli (`@playwright/cli`) es relativamente nuevo (2025-2026). El knowledge de training de Claude mezcla Playwright testing framework, Playwright MCP server, y playwright-cli. La instalacion es `npm install -g @playwright/cli@latest` pero hay confusion con `npm install -g @playwright/mcp@latest` (el MCP). Los outputs no son inline — snapshots y screenshots se guardan a `.playwright-cli/` y Claude debe leer esos archivos explicitamente.

**How to avoid:**
- Descargar el SKILL.md oficial del repo microsoft/playwright-cli como fuente de verdad
- Colocar la referencia de comandos en `references/playwright-cli-commands.md` (no escribirla de memoria)
- Documentar explicitamente en el SKILL.md: "el output de snapshot va a archivo, debes leerlo con Read"
- Documentar la diferencia entre playwright-cli vs MCP vs @playwright/test
- Verificar el binario correcto: `playwright-cli --help` no `playwright --help`

**Warning signs:**
- En evals, Claude ejecuta `playwright screenshot` en lugar de `playwright-cli screenshot`
- Claude intenta leer output de snapshot "inline" sin usar la herramienta Read
- Claude usa el Playwright MCP tool en lugar del CLI cuando el skill deberia prevenir esto
- Comandos de session fallan porque Claude usa `-session` en lugar de `-s=`

**Phase to address:**
Fase 1 — descargar referencia oficial antes de escribir el SKILL.md. No inventar comandos de memoria.

---

### Pitfall 6: Evals demasiado simples — no detectan el problema real de trigger

**What goes wrong:**
Las evals de trigger usan prompts obvios ("usa playwright-cli para testear este formulario") que siempre activan el skill incluso con descripcion vaga. Las evals de ejecucion usan casos simples que no ejercitan el protocolo de diagnostico (console + network). El skill "pasa" las evals pero falla en uso real donde el usuario dice "el boton de submit no funciona" o "la pagina da error 500".

**Why it happens:**
Es natural escribir evals donde sabemos la respuesta esperada. Los prompts de trigger obvios son los mas faciles de escribir. Pero el valor del skill esta en activarse con prompts ambiguos: "hay algo raro con el checkout", "verificar que el login anda", "el usuario reporto un bug visual". La skill-creator SKILL.md documenta esto: las evals de trigger deberian ser "near-misses" que compiten con otras herramientas.

**How to avoid:**
- Incluir al menos 3-4 evals con prompts donde el usuario NO menciona playwright, browser testing, ni CLI explicitamente
- Incluir evals que competirían con MCP Playwright (para verificar que el skill gana)
- Incluir evals de diagnostico donde hay un error real: la eval debe verificar que Claude ejecuto console + network, no solo snapshot
- Usar el description optimizer con 20 queries: 10 should-trigger (mitad sin mencionar playwright), 10 should-not-trigger (near-misses)

**Warning signs:**
- Todas las evals de trigger incluyen "playwright" o "browser" en el prompt
- Las evals de ejecucion no incluyen assertions sobre si se ejecuto console y network
- Pass rate de evals es 100% desde el primer iteration (demasiado facil)

**Phase to address:**
Fase 2 (evals y optimizacion) — definir las evals antes de correrlas, revisarlas con el usuario antes de ejecutar.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Escribir comandos playwright-cli de memoria sin verificar | Ahorra tiempo de investigacion | Comandos incorrectos que Claude aprende y replica | Nunca — siempre verificar contra referencia oficial |
| Descripcion larga y detallada en frontmatter | Parece mas completa | Consume budget de caracteres, puede quedar invisible | Nunca — la descripcion va al frontmatter, el detalle va al cuerpo |
| Un solo SKILL.md monolitico sin referencias separadas | Estructura mas simple | Cuerpo supera 300 lineas, protocolo diluido | Nunca si el protocolo tiene >3 pasos con comandos |
| Evals solo con happy path | Evals pasan rapidamente | No detecta regresiones en casos borde o trigger ambiguo | Nunca como unico conjunto de evals |
| Saltar el description optimizer (`run_loop.py`) | Ahorra tiempo de iteracion | Trigger rate sub-optimo en produccion | Solo si hay deadline extremo — siempre correrlo antes del release |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| playwright-cli vs Playwright MCP | Confundir los dos — MCP usa tools como `browser_snapshot`, CLI usa comandos de bash | Documentar explicitamente la diferencia en el SKILL.md. CLI = Bash tool. MCP = tool calls. |
| playwright-cli vs @playwright/test | Pensar que el skill aplica a tests de CI/CD con `npx playwright test` | Dejar claro en el scope: este skill es para interaccion interactiva con browser, no para escribir archivos `.spec.ts` |
| Output de snapshot | Asumir que snapshot imprime al stdout y Claude lo lee inline | `playwright-cli snapshot` escribe a `.playwright-cli/` — Claude debe leer el archivo con Read explicitamente |
| Sesiones nombradas | Usar el mismo nombre de sesion por defecto en todos los proyectos | Usar `--session=<nombre-del-proyecto>` para aislar estado entre proyectos |
| Estado de autenticacion | Pedir credenciales al usuario antes de buscar en .env | Verificar primero `.env`, `.env.local`, variables de entorno — preguntar solo si no se encuentran |

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Re-snapshot innecesario | Claude ejecuta snapshot antes de cada comando aunque no hubo navegacion | Documentar en el SKILL.md: re-snapshot solo despues de navegacion o cambios DOM | No "rompe" pero aumenta tokens innecesariamente |
| Session leak — abrir browsers sin cerrar | Acumulacion de procesos browser en background | Documentar cierre de sesion al finalizar el flujo de diagnostico | Despues de varias sesiones de debug sin cerrar |
| Screenshot para todo en lugar de snapshot | Claude toma screenshots para "ver" la pagina, consumiendo muchos tokens | El snapshot es la herramienta de diagnostico primaria — screenshot es para reportes visuales finales | Desde el primer uso si no se especifica en el protocolo |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Skill se activa para testing de API sin frontend | Claude abre browser para chequear un endpoint REST en lugar de usar curl | Delimitar el scope: "solo aplica cuando hay una interfaz web que un usuario interactua visualmente" |
| Skill se activa en proyectos sin servidor corriendo | Claude intenta navegar a localhost y falla con connection refused | Incluir en el protocolo: verificar que el servidor este corriendo antes de abrir el browser |
| Protocolo de 5 pasos aplicado a verificaciones triviales | Claude ejecuta todo el protocolo para verificar que un link existe | Indicar en el SKILL.md que el protocolo completo aplica ante errores/bugs — verificaciones simples pueden ser mas directas |

---

## "Looks Done But Isn't" Checklist

- [ ] **Descripcion optimizada:** Verificar que el description optimizer se ejecuto y la descripcion final supero 80%+ trigger rate en evals — no solo que "suena bien"
- [ ] **Comandos verificados:** Cada comando en el SKILL.md fue verificado contra la referencia oficial de microsoft/playwright-cli, no escrito de memoria
- [ ] **Visibilidad en entorno real:** Correr `What skills are available?` en una sesion con TODOS los skills de ~/.claude/skills/ activos y confirmar que playwright-testing aparece
- [ ] **Reglas NUNCA probadas:** Evals incluyen casos donde Claude tendria la opcion de usar MCP o curl y verifican que los usa playwright-cli en su lugar
- [ ] **Protocolo completo:** Evals incluyen assertions que confirman que console + network se ejecutaron ante errores, no solo snapshot
- [ ] **Archivo de referencia incluido:** `references/playwright-cli-commands.md` existe y contiene la referencia descargada del repo oficial

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Skill no triggering por descripcion vaga | LOW | Reescribir descripcion con skill-creator, correr optimizer, redeployar — 1-2 horas |
| Skill invisible por budget excedido | LOW | Agregar `SLASH_COMMAND_TOOL_CHAR_BUDGET=30000` al entorno o comprimir descripcion a <130 chars — 30 min |
| Comandos incorrectos en el skill | MEDIUM | Descargar referencia oficial, corregir todos los comandos, re-correr evals para verificar — 2-3 horas |
| SKILL.md demasiado largo y fragmentado | MEDIUM | Extraer comandos a references/, reescribir cuerpo con protocolo al frente, re-evaluar — 2-4 horas |
| Evals demasiado faciles — no detectaron problema real | MEDIUM | Reescribir evals con casos borde, correr nuevamente, comparar contra without_skill baseline — 3-4 horas |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Descripcion vaga sin trigger keywords | Fase 1 (draft) + Fase 2 (description optimizer) | Pass rate >80% en trigger evals con prompts sin mencionar "playwright" |
| Context budget excedido | Fase 1 (descripcion <=130 chars) + Fase 2 (test en entorno real) | Skill visible en lista cuando todos los skills estan activos |
| SKILL.md > 300 lineas | Fase 1 (diseno y estructura) | `wc -l SKILL.md` < 300, referencia en archivo separado |
| Reglas NUNCA sin razon | Fase 1 (primer draft) | Evals muestran cero uso de MCP/curl para interacciones con browser |
| Comandos playwright-cli incorrectos | Fase 1 (pre-requisito: descargar referencia oficial) | Cada comando en SKILL.md tiene correspondencia exacta en referencia oficial |
| Evals demasiado simples | Fase 2 (diseno de evals antes de correrlas) | Conjunto de evals incluye >=3 prompts ambiguos sin mencionar playwright |

---

## Sources

- [Extend Claude with skills — Claude Code Docs](https://code.claude.com/docs/en/skills) — documentacion oficial sobre descripcion, budget, longitud
- [skill-creator SKILL.md](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md) — documentacion de primer parte sobre undertriggering y "pushy descriptions"
- [Claude Code skills not triggering?](https://blog.fsck.com/2025/12/17/claude-code-skills-not-triggering/) — descripcion del bug de budget de caracteres con solucion
- [claude-code-skill-budget-research.md](https://gist.github.com/alexey-pelykh/faa3c304f731d6a962efc5fa2a43abe1) — investigacion detallada del budget de ~15,500-16,000 chars
- [microsoft/playwright-cli README](https://github.com/microsoft/playwright-cli/blob/main/README.md) — referencia oficial de comandos
- [Command Reference — DeepWiki playwright-cli](https://deepwiki.com/microsoft/playwright-cli/4-command-reference) — documentacion estructurada de comandos
- [How to Activate Claude Skills Automatically](https://dev.to/oluwawunmiadesewa/claude-code-skills-not-triggering-2-fixes-for-100-activation-3b57) — fixes documentados para undertriggering
- [CLAUDE.md instructions not reliably followed — GitHub Issue #18660](https://github.com/anthropics/claude-code/issues/18660) — issue oficial sobre instrucciones ignoradas
- [How to Write Skills for Claude Code and Cowork — Sherlock](https://sherlock.xyz/post/how-to-write-skills-for-claude-code-and-cowork) — mejores practicas de la comunidad

---
*Pitfalls research for: Claude Code skill playwright-testing (playwright-cli enforcement)*
*Researched: 2026-03-17*
