#!/bin/bash
# =============================================================================
# playwright-testing — Instalador automatico de skill para Claude Code
# =============================================================================
# Uso:
#   curl -sL https://raw.githubusercontent.com/objetiva-comercios/claude-code-skill-proyecto-playwright-cli/main/install.sh | bash
#
# Que hace:
#   1. Verifica que exista el directorio ~/.claude/
#   2. Limpia carpetas con nombre incorrecto (ej: proyecto-playwright-cli)
#   3. Clona el repositorio en un directorio temporal
#   4. Copia SKILL.md, references/ y evals/ a ~/.claude/skills/playwright-testing/
#   5. Limpia el directorio temporal
#
# Requisitos:
#   - git
#   - Claude Code instalado (~/.claude/ debe existir)
#   - playwright-cli instalado (npm install -g playwright-cli)
# =============================================================================

set -euo pipefail

# -- Config ------------------------------------------------------------------
SKILL_NAME="playwright-testing"
SKILLS_DIR="${HOME}/.claude/skills"
SKILL_DIR="${SKILLS_DIR}/${SKILL_NAME}"
REPO_URL="https://github.com/objetiva-comercios/claude-code-skill-proyecto-playwright-cli.git"
TMP_DIR=$(mktemp -d)

# -- Colores -----------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# -- Banner ------------------------------------------------------------------
echo ""
echo "=========================================="
echo "  playwright-testing — Instalador de Skill"
echo "=========================================="
echo ""

# -- Verificar dependencias --------------------------------------------------
command -v git >/dev/null 2>&1 || error "git no esta instalado. Instalar con: sudo apt install git"

if [ ! -d "${HOME}/.claude" ]; then
    error "No se encontro ~/.claude/ — Claude Code no parece estar instalado"
fi

ok "Dependencias verificadas (git, Claude Code)"

# -- Verificar playwright-cli (informativo, no bloqueante) --------------------
if command -v playwright-cli >/dev/null 2>&1; then
    ok "playwright-cli encontrado: $(playwright-cli --version 2>/dev/null || echo 'version desconocida')"
else
    warn "playwright-cli no esta instalado"
    warn "La skill lo necesita para funcionar. Instalar con:"
    echo "    npm install -g playwright-cli"
    echo ""
fi

# -- Crear directorio de skills si no existe ---------------------------------
if [ ! -d "${SKILLS_DIR}" ]; then
    info "Creando directorio de skills: ${SKILLS_DIR}"
    mkdir -p "${SKILLS_DIR}"
fi

# -- Limpiar carpetas con nombre incorrecto ----------------------------------
# Claude Code usa el nombre de la CARPETA como identificador del comando.
# Si alguien clono el repo directo en ~/.claude/skills/, la carpeta se llama
# "claude-code-skill-proyecto-playwright-cli" o "proyecto-playwright-cli" y el
# comando queda mal registrado. Detectamos y limpiamos esas carpetas.
for dir in "${SKILLS_DIR}/"*playwright*; do
    [ -d "$dir" ] || continue
    dir_name=$(basename "$dir")
    if [ "$dir_name" != "${SKILL_NAME}" ]; then
        warn "Carpeta con nombre incorrecto detectada: ${dir_name}/"
        warn "Claude Code registra el comando como /${dir_name} en vez de /${SKILL_NAME}"
        info "Eliminando ${dir_name}/..."
        rm -rf "$dir"
        ok "Carpeta incorrecta eliminada"
    fi
done

# -- Manejar instalacion previa ---------------------------------------------
if [ -d "${SKILL_DIR}" ]; then
    warn "Skill '${SKILL_NAME}' ya instalada — actualizando..."
    rm -rf "${SKILL_DIR}"
fi

# -- Clonar repositorio en temporal ------------------------------------------
info "Clonando repositorio..."
git clone --quiet --depth 1 "${REPO_URL}" "${TMP_DIR}/repo" 2>/dev/null || error "No se pudo clonar el repositorio"
ok "Repositorio clonado"

# -- Copiar archivos de la skill ---------------------------------------------
info "Instalando skill en ${SKILL_DIR}..."
mkdir -p "${SKILL_DIR}/references" "${SKILL_DIR}/evals"

cp "${TMP_DIR}/repo/SKILL.md" "${SKILL_DIR}/SKILL.md"
ok "SKILL.md copiado"

if [ -d "${TMP_DIR}/repo/references" ]; then
    cp -r "${TMP_DIR}/repo/references/." "${SKILL_DIR}/references/"
    ok "Referencias copiadas"
fi

if [ -d "${TMP_DIR}/repo/evals" ]; then
    cp -r "${TMP_DIR}/repo/evals/." "${SKILL_DIR}/evals/"
    ok "Evaluaciones copiadas"
fi

# -- Limpiar temporal --------------------------------------------------------
rm -rf "${TMP_DIR}"
ok "Directorio temporal limpiado"

# -- Verificacion ------------------------------------------------------------
if [ -f "${SKILL_DIR}/SKILL.md" ] && [ -f "${SKILL_DIR}/references/playwright-cli-commands.md" ]; then
    ok "Skill instalada correctamente"
else
    error "La instalacion fallo — archivos faltantes en ${SKILL_DIR}"
fi

# -- Resultado final ---------------------------------------------------------
echo ""
echo "=========================================="
echo "  Instalacion completada"
echo "=========================================="
echo ""
echo "  Skill:     ${SKILL_NAME}"
echo "  Ubicacion: ${SKILL_DIR}/"
echo "  Archivos:"
find "${SKILL_DIR}" -type f | sort | sed "s|${SKILL_DIR}/|    |"
echo ""
echo "  La skill se activa automaticamente en Claude Code"
echo "  cuando menciones bugs de frontend, login roto,"
echo "  formularios que no funcionan, o cualquier"
echo "  interaccion con un navegador web."
echo ""
if ! command -v playwright-cli >/dev/null 2>&1; then
    echo "  ⚠ Recordatorio: instalar playwright-cli antes de usar:"
    echo "    npm install -g playwright-cli"
    echo ""
fi
