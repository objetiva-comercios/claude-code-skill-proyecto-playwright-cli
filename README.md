# playwright-testing

Skill global para Claude Code que fuerza el uso de `playwright-cli` como unico punto de entrada al navegador web. Reemplaza el comportamiento por defecto de Claude de usar curl, Playwright MCP server o scripts ad-hoc de Node.js con un protocolo de diagnostico estructurado de 5 pasos: verificar instalacion, buscar credenciales, tomar snapshot con session nombrada, diagnosticar con console y network, y aplicar fix con re-test completo. Se instala globalmente en `~/.claude/skills/` para estar disponible en todos los proyectos sin configuracion adicional.

## Tecnologias

| Categoria | Tecnologia |
|-----------|------------|
| CLI | playwright-cli (via `@playwright/mcp@latest`) |
| Plataforma | Claude Code skills system |
| Evaluacion | skill-creator (run_loop.py) |
| Referencia | microsoft/playwright-cli (repo oficial) |

## Requisitos previos

- **Claude Code** instalado (`~/.claude/` debe existir)
- **Node.js** (cualquier version LTS)
- **playwright-cli** — se instala con `npm install -g @playwright/mcp@latest`
- **git** (para el instalador)

## Instalacion

```bash
curl -sL https://raw.githubusercontent.com/objetiva-comercios/claude-code-skill-proyecto-playwright-cli/main/install.sh | bash
```

El script clona el repo en un directorio temporal, copia los archivos necesarios a `~/.claude/skills/playwright-testing/`, y limpia. Es idempotente — correrlo dos veces actualiza sin romper nada.

Si preferis instalar manualmente:

```bash
git clone https://github.com/objetiva-comercios/claude-code-skill-proyecto-playwright-cli.git /tmp/playwright-testing-skill
mkdir -p ~/.claude/skills/playwright-testing/{references,evals}
cp /tmp/playwright-testing-skill/SKILL.md ~/.claude/skills/playwright-testing/
cp -r /tmp/playwright-testing-skill/references/. ~/.claude/skills/playwright-testing/references/
cp -r /tmp/playwright-testing-skill/evals/. ~/.claude/skills/playwright-testing/evals/
rm -rf /tmp/playwright-testing-skill
```

## Como funciona

La skill se activa automaticamente cuando Claude Code detecta que el usuario necesita interactuar con un navegador web: bugs de frontend, formularios rotos, login que no funciona, errores visuales, flujos de CRUD que fallan, o cualquier otro escenario que involucre un browser.

### Protocolo de 5 pasos

| Paso | Accion | Detalle |
|------|--------|---------|
| 0 | Verificar instalacion | `playwright-cli --version` — instala automaticamente si falta |
| 1 | URL y credenciales | Confirma entorno (dev/staging/prod), busca credenciales en `.env.local` → `.env.development` → `.env` |
| 2 | Session + snapshot | Abre session nombrada por proyecto (`-s=nombre`), toma snapshot obligatorio antes de interactuar |
| 3 | Diagnostico | Ejecuta `console` + `network` ante cualquier error, identifica causa raiz (401/403, 500, error JS, bug UI) |
| 4 | Fix | Corrige codigo, muestra diff, pide confirmacion antes de aplicar |
| 5 | Re-test | Repite el flujo completo desde paso 2 para confirmar que el fix funciona |

### Reglas

- **NUNCA** usar curl/wget para interacciones con el browser
- **NUNCA** usar Playwright MCP server (`@playwright/mcp`) — consume 4x mas tokens
- **NUNCA** usar `@playwright/test` ni scripts ad-hoc de Node.js
- **NUNCA** asumir credenciales sin verificar archivos `.env`
- **SIEMPRE** tomar snapshot antes de la primera interaccion
- **SIEMPRE** ejecutar console + network ante cualquier error
- **SIEMPRE** confirmar URL del entorno antes de abrir el browser

### Boundaries

La skill NO se activa para:
- API testing sin frontend (usar `curl`)
- Unit tests (usar `vitest` o `jest`)
- Queries directas a base de datos
- Generacion de scripts Playwright para CI/CD (`@playwright/test`)

## Arquitectura del proyecto

```
├── SKILL.md                           # Skill principal (99 lineas)
├── references/
│   └── playwright-cli-commands.md     # Referencia oficial de Microsoft (278 lineas)
├── evals/
│   ├── evals.json                     # 5 quality evals con assertions
│   └── trigger_evals.json            # 8 trigger evals (5 positivos + 3 negativos)
├── install.sh                         # Instalador automatico
├── DEPLOY.md                          # Documentacion de instalacion
└── .planning/                         # Documentacion GSD del proceso de creacion
```

Al instalarse, solo se copian `SKILL.md`, `references/` y `evals/` a `~/.claude/skills/playwright-testing/`. El resto son archivos del repositorio.

## Deploy

Ver [DEPLOY.md](DEPLOY.md) para instrucciones detalladas incluyendo instalacion por proyecto, actualizacion, desinstalacion y troubleshooting.

## Estado del proyecto

v1.0 completado — todas las fases finalizadas (2026-03-20). 3 fases, 8 planes, 27 requisitos cubiertos. Trigger rate medido: 33% con run_loop.py (hallazgo documentado: el mecanismo de skill-matching de Claude Code requiere keywords tecnicas del usuario para disparar automaticamente).
