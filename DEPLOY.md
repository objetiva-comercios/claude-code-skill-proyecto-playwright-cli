# Deploy — playwright-testing

## Instalacion rapida

```bash
curl -sL https://raw.githubusercontent.com/objetiva-comercios/claude-code-skill-proyecto-playwright-cli/main/install.sh | bash
```

## Requisitos

- **git** (cualquier version)
- **Claude Code** instalado (`~/.claude/` debe existir)
- **playwright-cli** (`npm install -g playwright-cli`)

## Que instala

La skill `playwright-testing` se copia a `~/.claude/skills/playwright-testing/` con esta estructura:

```
~/.claude/skills/playwright-testing/
├── SKILL.md                           # Protocolo de 5 pasos (99 lineas)
├── references/
│   └── playwright-cli-commands.md     # Referencia oficial de Microsoft (278 lineas)
└── evals/
    ├── evals.json                     # 5 quality evals con assertions
    └── trigger_evals.json             # 8 trigger evals (5 positivos + 3 negativos)
```

Claude Code detecta automaticamente las skills en `~/.claude/skills/` y las hace
disponibles en todas las conversaciones.

**Importante:** Claude Code usa el nombre de la **carpeta** como identificador del
comando, no el campo `name` del SKILL.md. Por eso la carpeta debe llamarse
`playwright-testing/`, no el nombre del repo.

## Instalacion manual

Si preferis no usar el script:

```bash
# Clonar el repo
git clone https://github.com/objetiva-comercios/claude-code-skill-proyecto-playwright-cli.git /tmp/playwright-testing-skill

# Copiar a la ubicacion de skills
mkdir -p ~/.claude/skills/playwright-testing/{references,evals}
cp /tmp/playwright-testing-skill/SKILL.md ~/.claude/skills/playwright-testing/
cp -r /tmp/playwright-testing-skill/references/. ~/.claude/skills/playwright-testing/references/
cp -r /tmp/playwright-testing-skill/evals/. ~/.claude/skills/playwright-testing/evals/

# Limpiar
rm -rf /tmp/playwright-testing-skill
```

## Instalacion por proyecto (alternativa)

Si solo queres la skill en un proyecto especifico en vez de globalmente:

```bash
# Desde la raiz del proyecto donde queres usar la skill
mkdir -p .claude/skills/playwright-testing/references
curl -sL https://raw.githubusercontent.com/objetiva-comercios/claude-code-skill-proyecto-playwright-cli/main/SKILL.md \
  -o .claude/skills/playwright-testing/SKILL.md
curl -sL https://raw.githubusercontent.com/objetiva-comercios/claude-code-skill-proyecto-playwright-cli/main/references/playwright-cli-commands.md \
  -o .claude/skills/playwright-testing/references/playwright-cli-commands.md
```

## Actualizacion

Correr el mismo comando de instalacion rapida. El script detecta la instalacion
previa, la elimina, y copia la version nueva. Tambien limpia carpetas con nombre
incorrecto si existen (ver Troubleshooting).

## Desinstalacion

```bash
rm -rf ~/.claude/skills/playwright-testing
```

## Verificacion

Despues de instalar, abrir una nueva conversacion en Claude Code y decir:

```
el boton de login no funciona en mi app
```

Claude deberia activar la skill automaticamente y seguir el protocolo de 5 pasos:
verificar instalacion → credenciales → snapshot+session → console/network → fix+retest.

## Troubleshooting

| Problema | Causa | Solucion |
|----------|-------|----------|
| Claude no reconoce la skill | `~/.claude/skills/playwright-testing/SKILL.md` no existe | Reinstalar con el comando curl |
| El comando aparece como `/proyecto-playwright-cli` | La carpeta se llama `proyecto-playwright-cli` en vez de `playwright-testing` (tipicamente por clonar el repo directo en `~/.claude/skills/`) | Correr el install.sh — detecta y corrige carpetas mal nombradas automaticamente |
| `playwright-cli: command not found` | playwright-cli no esta instalado | `npm install -g playwright-cli` |
| `curl` falla al descargar | El repo no es accesible | Verificar que el repo es publico o que tenes acceso. Probar la URL en el navegador |
| "Claude Code no parece estar instalado" | No existe `~/.claude/` | Verificar que Claude Code esta instalado. El directorio se crea automaticamente al usarlo |
