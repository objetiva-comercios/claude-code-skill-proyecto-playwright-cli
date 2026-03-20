---
name: playwright-testing
description: Fuerza el uso de playwright-cli como unico punto de entrada al navegador para cualquier interaccion con la web. Usa este skill siempre que el usuario mencione bugs de frontend, botones que no responden, formularios que no funcionan, errores visuales, login roto, flujos de signup o CRUD que fallan, verificacion de que una pagina carga bien, testing de interfaces en el navegador, captura de screenshots, debugging de rendering o layout, scraping interactivo, automatizacion de flujos de usuario, o cualquier otra interaccion con un navegador web — incluso si no menciona explicitamente "playwright" o "testing". Si hay un navegador de por medio, este skill aplica.
allowed-tools: Bash(playwright-cli:*)
---

# playwright-testing

playwright-cli es la herramienta CLI oficial de Microsoft para controlar un navegador real desde la terminal. Permite navegar paginas, interactuar con elementos via refs (e1, e2...), capturar snapshots del estado del DOM, leer consola y red, y ejecutar flujos completos de usuario — todo desde bash.

Usar playwright-cli (no playwright-mcp, no el navegador manual) es obligatorio para cualquier interaccion con el navegador porque garantiza diagnostico reproducible y estructurado.

## Protocolo de diagnostico

**Paso 0 — Verificar instalacion**
Correr `playwright-cli --version`. Si falla, instalar automaticamente: `npm install -g @playwright/cli@latest`. No preguntar al usuario.

**Paso 1 — URL y credenciales**
Confirmar URL del entorno (dev/staging/prod) — NUNCA asumir produccion. Buscar credenciales (patrones: `*_URL`, `*_USER`, `*_PASSWORD`, `*_EMAIL`, `*_TOKEN`, `*_API_KEY`) en este orden:
1. `.env.local`
2. `.env.development`
3. `.env`

Si encuentra credenciales, usarlas directamente sin pedir confirmacion. Si no hay archivos .env, preguntar URL y credenciales al usuario. No adivinar ni usar defaults.

Para OAuth/2FA: pedir al usuario que se loguee manualmente, luego `playwright-cli -s=nombre state-save auth.json`. En sesiones futuras: `playwright-cli -s=nombre state-load auth.json`.

**Paso 2 — Session + snapshot inicial**
Verificar sessions existentes con `playwright-cli list`. Si hay session del proyecto, reusarla. Si no, abrir nueva:
```
playwright-cli -s=<nombre-directorio-proyecto> open <URL> --persistent
```
Tomar snapshot obligatorio antes de la primera interaccion: `playwright-cli -s=nombre snapshot`.
Despues de este primer snapshot, cada comando playwright-cli devuelve snapshot automaticamente.
IMPORTANTE: el flag `-s=nombre` es obligatorio en todos los comandos (click, fill, snapshot, etc.), no solo en open.

**Paso 3 — Diagnostico ante error**
Ejecutar SIEMPRE ambos comandos ante cualquier error:
```
playwright-cli -s=nombre console
playwright-cli -s=nombre network
```

Tabla de causa raiz:

| Sintoma en console/network | Causa probable | Accion |
|----------------------------|----------------|--------|
| HTTP 401 o 403 | Credenciales incorrectas o expiradas | Verificar .env, re-login |
| HTTP 500 | Error en backend | Revisar logs del servidor |
| Error JS en console | Bug en frontend | Identificar componente, revisar stack trace |
| Sin errores en console/network | Bug UI puro | Inspeccionar estado del DOM con snapshot |

**Paso 3bis — Resumen antes de fix**
OBLIGATORIO: antes de tocar codigo, mostrar al usuario:
- Error encontrado
- Causa identificada (de la tabla)
- Accion propuesta

El usuario confirma o redirige. No aplicar fix sin confirmacion.

**Paso 4 — Aplicar fix**
Corregir el codigo fuente. Mostrar diff de los cambios realizados y explicar que se cambio.

**Paso 5 — Re-test completo**
Repetir el flujo COMPLETO desde Paso 2 (snapshot → reproducir → verificar). No solo el paso que fallo.
El ciclo se cierra cuando el flujo pasa sin error.
NO cerrar la session — queda abierta. Cerrar es decision implicita de Claude cuando termina.

Ver `references/playwright-cli-commands.md` para opciones completas de cada comando.

## Reglas

**NUNCA usar curl o wget para interacciones con el browser** — curl no da acceso a la consola JS, al trafico de red ni al estado del DOM; el diagnostico es imposible sin esa informacion.

> **NUNCA usar Playwright MCP server (@playwright/mcp)** — consume 4x mas tokens que playwright-cli, da menos control sobre el flujo, y no aporta nada que playwright-cli no tenga. playwright-cli es la herramienta correcta para todo uso interactivo del navegador.

**NUNCA usar @playwright/test ni scripts ad-hoc de Node.js** — playwright-cli resuelve el caso de uso sin el overhead de setup ni scripts que mantener.

**NUNCA asumir credenciales sin verificar .env** — credenciales incorrectas producen diagnostico falso (falsos 401, falsos 403). Siempre ejecutar el Paso 1 del protocolo.

**SIEMPRE tomar snapshot antes de la primera interaccion** — sin snapshot no hay refs disponibles (e1, e2, e3...) y los comandos click/fill no pueden referenciar elementos.

**SIEMPRE ejecutar console + network ante cualquier error** — console solo muestra errores JS, network solo muestra HTTP. El diagnostico requiere ambos para identificar la causa raiz.

**SIEMPRE confirmar URL del entorno (dev/staging/prod) antes de abrir el browser** — testear en produccion por error puede causar dano real a datos o usuarios.

## Triggers y Boundaries

**Usar este skill para:** bugs de frontend, formularios que no funcionan, errores visuales, login roto, flujos de signup/CRUD que fallan, verificacion de que una pagina carga bien, testing de interfaces en el navegador, debugging de rendering o layout, scraping interactivo, automatizacion de flujos de usuario — cualquier interaccion con un navegador web.

**NO usar para:**
- API testing sin frontend → usar `curl` o herramienta de HTTP testing
- Unit tests → usar `vitest` o `jest`
- Queries directas a base de datos → usar SQL directo o cliente de DB
- Generacion de scripts Playwright para CI/CD → usar `@playwright/test` (herramienta distinta)

## Referencia de comandos

Lee `references/playwright-cli-commands.md` para la sintaxis completa de comandos playwright-cli (descargado del repo oficial de Microsoft).
