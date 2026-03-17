# Feature Research

**Domain:** Claude Code skill — browser testing protocol using playwright-cli
**Researched:** 2026-03-17
**Confidence:** HIGH

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features without which the skill is effectively useless or no better than the ad-hoc defaults Claude already uses.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Protocolo de 5 pasos explícito (snapshot → reproducir → console/network → fix → re-test) | El skill existe para reemplazar el flujo ad-hoc: sin un protocolo fijo no hay valor diferencial | MEDIUM | Debe estar en el SKILL.md principal, no en referencias separadas |
| Regla NUNCA/SIEMPRE para reemplazar MCP y curl | Si el skill no desplaza los defaults, Claude vuelve a usarlos ante la menor ambigüedad | LOW | Lenguaje imperativo: "NUNCA usar Playwright MCP server ni curl para interacciones con browser" |
| Descripción que dispara ante cualquier interacción con el navegador | Sin un trigger rate alto el skill no se activa cuando debería — el problema central del proyecto | MEDIUM | Debe cubrir: bugs frontend, formularios, verificar flujos, errores visuales, cualquier URL de app |
| Comandos `snapshot` y `screenshot` como primer paso obligatorio | Herramienta central para obtener referencias de elementos (e15, e21) antes de cualquier acción | LOW | playwright-cli usa referencias cortas (e.g. e21) en lugar de selectores CSS/XPath |
| Sessions nombradas por proyecto (`--session=<nombre>`) | Sin sessions, el estado del browser se pierde entre comandos; flujos con login son imposibles | LOW | Patrón: `playwright-cli -s=nombre-proyecto open <url>` |
| Protocolo de credenciales: buscar `.env` antes de preguntar | Claude por defecto pide usuario/password al usuario; con `.env` es autónomo | LOW | Orden: `.env` → `.env.local` → preguntar |
| Diagnóstico obligatorio de consola y red ante cualquier error | Sin esto Claude propone fixes a ciegas; el diagnóstico es el núcleo del valor del skill | MEDIUM | `playwright-cli console` + `playwright-cli network` antes de cualquier hipótesis de fix |
| Referencia de comandos en archivo separado | SKILL.md principal debe ser < 300 líneas; el catálogo de 50+ comandos va en `references/` | LOW | Evita que el skill principal sea ilegible por tamaño |
| Scope universal (no limitado a un framework o stack) | El skill debe activarse para cualquier app web — React, Vue, Django, PHP, lo que sea | LOW | No mencionar stacks específicos en triggers |

### Differentiators (Competitive Advantage)

Lo que hace que este skill sea preferido sobre escribir un script de Playwright a mano o usar el MCP server.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Descripción "pushier" con ejemplos concretos de activación | Trigger rate documentado: sin optimización 20%, con optimización 50%, con ejemplos 90% — diferencia drástica | MEDIUM | Incluir ejemplos de qué dice el usuario que dispara el skill: "el botón no responde", "el form no envía", "verificá que funciona el login" |
| Protocolo reproducir-antes-de-fix (YAML replay) | playwright-cli graba YAMLs de sesión; reproducir el problema antes de proponer fix evita arreglar síntomas | MEDIUM | Diferencia clave vs MCP: el CLI guarda estado a disco, permite replay sin re-navegar |
| Comparación de tokens explícita como argumento de uso | MCP ~114k tokens por tarea típica vs CLI ~27k — argumento concreto para elegir el skill sobre el default | LOW | Incluir en descripción o comentario: "4x más eficiente que Playwright MCP" |
| Cobertura de comandos DevTools (console, network, trace, video) | El MCP restringe estos por default para no sobrecargar contexto; el CLI los expone todos | HIGH | La cobertura completa (50+ comandos) es una ventaja concreta sobre MCP |
| Manejo de estado de autenticación persistente (storage state) | `playwright-cli save-storage` / `playwright-cli load-storage` permiten no re-loginear en cada sesión | MEDIUM | Clave para apps con login en dev/staging; ahorra pasos y tokens |
| Test cases con assertions como ejemplos evaluables | 5 casos de uso con assertions definidas permiten medir el skill con evals, no solo usarlo | HIGH | Requerido por PROJECT.md para evaluar con skill-creator; los casos son el contrato de calidad |
| Boundaries explícitos de cuándo NO usar el skill | Define los casos excluidos (APIs sin frontend, unit tests, DB queries) para evitar over-triggering | LOW | Sin esto el skill puede interferir con flujos donde curl es lo correcto |

### Anti-Features (Commonly Requested, Often Problematic)

Cosas que parecen útiles pero que deliberadamente no deben estar en este skill.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Generación de scripts de Playwright para CI/CD | Parece la extensión natural de "usar Playwright" | Fuera de scope: `@playwright/test` es una herramienta diferente con su propio ecosistema; mezclarlas confunde el propósito del skill | Skill separado: `playwright-test-generator` si se necesita |
| Cobertura de APIs sin frontend (curl, fetch directo) | Claude frecuentemente usa curl para hacer requests HTTP en debugging | curl es correcto para esto; reemplazarlo con playwright-cli sería más lento y menos semántico | Dejar curl explícitamente en la sección "cuándo NO usar" |
| Unit tests con Jest/Vitest | Se confunden con "testing de browser" | Son herramientas distintas, diferente capa, diferente propósito | Mencionar explícitamente que el skill es solo para interacciones con browser real |
| Queries directas a base de datos como parte del diagnóstico | Cuando un bug involucra datos, Claude quiere revisar la DB | Fuera del scope del skill; añadir DB queries complica el protocolo y crea dependencias de configuración | Manejar DB queries con herramientas específicas (psql, Supabase MCP) fuera de este skill |
| SKILL.md monolítico con toda la referencia de comandos inline | Parece más completo tener todo en un archivo | Viola el límite de 300 líneas; degrada la calidad del protocolo principal con documentación de referencia | Separar en `references/playwright-cli-commands.md` |
| Screenshots automáticos en cada paso | Parece útil para debugging visual | Consume tokens innecesariamente — playwright-cli ya guarda PNGs a disco sin pasarlos al contexto LLM; pedir screenshots explícitamente cuando se necesitan | Usar `playwright-cli screenshot` solo cuando la verificación visual es el objetivo |

---

## Feature Dependencies

```
Protocolo de 5 pasos
    └──requires──> Comandos snapshot/screenshot (paso 1)
    └──requires──> Diagnóstico console/network (paso 3)
    └──requires──> Sessions nombradas (para persistir estado entre pasos)

Diagnóstico console/network
    └──requires──> Session activa con --session=nombre

Manejo de autenticación (storage state)
    └──requires──> Sessions nombradas
    └──enhances──> Protocolo de 5 pasos (evita re-login en cada diagnóstico)

Test cases con assertions
    └──requires──> Protocolo de 5 pasos (los casos usan el mismo flujo)
    └──requires──> Referencia de comandos separada (los casos referencian comandos específicos)

Descripción con trigger rate alto
    └──enhances──> Todo el skill (sin trigger rate el resto no importa)

Referencia de comandos separada
    └──enables──> Cobertura DevTools completa (sin ella el SKILL.md principal superaría 300 líneas)

Boundaries explícitos (cuándo NO usar)
    └──conflicts──> Over-triggering (si no están definidos, el skill interfiere con flujos correctos)
```

### Dependency Notes

- **Protocolo de 5 pasos requires Sessions nombradas:** cada paso del protocolo opera sobre el mismo contexto de browser; sin sessions el estado se pierde entre comandos
- **Test cases requires Protocolo de 5 pasos:** los casos de evaluación verifican que el protocolo se ejecute correctamente, no comandos aislados
- **Descripción enhances todo:** la activación del skill es el prerequisito de todo lo demás; un skill con protocolo perfecto y trigger rate del 20% es inútil en práctica
- **Referencia separada conflicts con SKILL.md monolítico:** elegir uno de los dos formatos; no mezclarlos

---

## MVP Definition

### Launch With (v1)

Mínimo viable para que el skill tenga valor y sea evaluable.

- [ ] SKILL.md principal con protocolo de 5 pasos — define el comportamiento central
- [ ] Reglas NUNCA/SIEMPRE para desplazar MCP y curl — sin esto el skill no reemplaza los defaults
- [ ] Descripción optimizada con ejemplos concretos de trigger — sin esto el skill no se activa
- [ ] Sessions nombradas documentadas — prerequisito para cualquier flujo con estado
- [ ] Protocolo de credenciales (buscar .env) — autonomía básica para apps con login
- [ ] Diagnóstico obligatorio console + network — el núcleo del valor diferencial
- [ ] Referencia de comandos en archivo separado — permite SKILL.md < 300 líneas
- [ ] Boundaries explícitos (cuándo NO usar) — evita over-triggering y conflictos

### Add After Validation (v1.x)

Agregar cuando v1 esté siendo usado y se tenga feedback sobre gaps.

- [ ] Manejo de storage state para autenticación persistente — trigger: usuarios reportan re-login frecuente
- [ ] 5 test cases con assertions para evals — trigger: querer medir objetivamente la calidad del skill
- [ ] Comparación de tokens MCP vs CLI en documentación — trigger: usuarios siguen usando MCP por desconocimiento

### Future Consideration (v2+)

Defer hasta validar que el skill básico funciona.

- [ ] Cobertura completa de comandos DevTools (trace, video recording) — complejidad alta, beneficio incremental sobre diagnóstico básico de console/network
- [ ] Integración con CI/CD — fuera de scope por definición; requeriría skill separado

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Protocolo de 5 pasos | HIGH | MEDIUM | P1 |
| Reglas NUNCA/SIEMPRE | HIGH | LOW | P1 |
| Descripción optimizada con triggers | HIGH | MEDIUM | P1 |
| Sessions nombradas | HIGH | LOW | P1 |
| Diagnóstico console + network | HIGH | MEDIUM | P1 |
| Protocolo de credenciales .env | MEDIUM | LOW | P1 |
| Referencia de comandos separada | MEDIUM | LOW | P1 |
| Boundaries explícitos | MEDIUM | LOW | P1 |
| Storage state / auth persistente | MEDIUM | MEDIUM | P2 |
| Test cases con assertions (evals) | HIGH | HIGH | P2 |
| Comparación tokens MCP vs CLI | LOW | LOW | P2 |
| Cobertura DevTools completa | LOW | HIGH | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

---

## Competitor Feature Analysis

| Feature | Playwright MCP (default Claude) | Goose Playwright Skill | Este skill |
|---------|--------------------------------|------------------------|------------|
| Token efficiency | LOW (~114k por tarea típica) | MEDIUM (CLI pero sin protocolo fijo) | HIGH (~27k con CLI + protocolo estructurado) |
| Protocolo de diagnóstico | Ninguno — ad-hoc | Parcial (snapshot → acción) | Completo (5 pasos con diagnóstico obligatorio) |
| Trigger rate | N/A (es el default) | No documentado | Optimizado con ejemplos concretos |
| Acceso a DevTools (console/network) | Restringido por default | Sí | Sí, obligatorio ante errores |
| Sessions nombradas | No | Sí | Sí, con protocolo de naming |
| Manejo de credenciales | No (pide al usuario) | No | Sí (busca .env primero) |
| Scope universal | N/A | Sí | Sí, explícitamente stack-agnostic |
| Límite de tamaño del skill | N/A | No documentado | < 300 líneas (archivo principal) |

---

## Sources

- [playwright-cli GitHub oficial — microsoft/playwright-cli](https://github.com/microsoft/playwright-cli) — HIGH confidence
- [playwright-cli SKILL.md oficial de Microsoft](https://github.com/microsoft/playwright-cli/blob/main/skills/playwright-cli/SKILL.md) — HIGH confidence
- [Playwright CLI: Token-Efficient Alternative to Playwright MCP — TestCollab](https://testcollab.com/blog/playwright-cli) — MEDIUM confidence (tercero verificado contra docs oficiales)
- [Agentic Testing with Playwright CLI Skill — Goose (Block)](https://block.github.io/goose/docs/tutorials/playwright-skill/) — MEDIUM confidence
- [Deep Dive into Playwright CLI — TestDino](https://testdino.com/blog/playwright-cli/) — MEDIUM confidence
- [Claude Code Skills Activation Best Practices — Gist mellanon](https://gist.github.com/mellanon/50816550ecb5f3b239aa77eef7b8ed8d) — MEDIUM confidence (múltiples fuentes concordantes)
- [Extend Claude with skills — Claude Code Docs oficial](https://code.claude.com/docs/en/skills) — HIGH confidence

---
*Feature research for: Claude Code skill playwright-testing (browser testing protocol)*
*Researched: 2026-03-17*
