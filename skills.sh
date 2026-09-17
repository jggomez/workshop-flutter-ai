#!/usr/bin/env bash
# ==============================================================================
# skills.sh — Provisioning Script for Cancun DashBooth AI Developer Harness
# ==============================================================================
# Repositorio de Skills: https://github.com/jggomez/expert-ai-developer-skills
# Plugins: senior-dev-flutter
# Plataformas soportadas: Google Antigravity (AGY) & Claude Code
# ==============================================================================

set -e

# --- Colores de Salida ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}${BOLD}======================================================${NC}"
echo -e "${CYAN}${BOLD}  Cancun DashBooth — AI Harness & Skills Setup        ${NC}"
echo -e "${CYAN}${BOLD}  FlutterConf LATAM 2026                             ${NC}"
echo -e "${CYAN}${BOLD}======================================================${NC}\n"

# --- 1. Verificación de Prerrequisitos de Sistema ---
echo -e "${YELLOW}[1/4] Verificando herramientas del sistema...${NC}"

if ! command -v dart &> /dev/null; then
    echo -e "${RED}❌ Error: Dart SDK no está en el PATH. Instala Flutter o Dart primero.${NC}"
    exit 1
fi
echo -e "  ${GREEN}✔ Dart SDK:${NC} $(dart --version 2>&1 | head -n 1)"

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Error: Flutter SDK no está en el PATH.${NC}"
    exit 1
fi
echo -e "  ${GREEN}✔ Flutter SDK:${NC} $(flutter --version 2>&1 | head -n 1)"

if ! command -v npx &> /dev/null; then
    echo -e "${RED}❌ Error: Node.js / npx no está disponible. Requerido para 'npx skills'.${NC}"
    exit 1
fi
echo -e "  ${GREEN}✔ Node/npx:${NC} $(node -v)"

# --- 2. Instalación de Agent Skills Oficiales ---
echo -e "\n${YELLOW}[2/4] Instalando Agent Skills (Flutter, Dart, Firebase)...${NC}"

# Skills oficiales de Flutter
echo -e "  ${CYAN}📦 Instalando flutter/agent-plugins...${NC}"
npx -y skills add flutter/agent-plugins \
  --skill flutter-apply-architecture-best-practices \
  --skill flutter-build-responsive-layout \
  --skill flutter-add-widget-test \
  --skill flutter-add-widget-preview \
  --skill flutter-add-integration-test \
  --skill flutter-use-http-package \
  --agent universal --yes || true

# Skills oficiales de Dart
echo -e "  ${CYAN}📦 Instalando dart-lang/skills...${NC}"
npx -y skills add dart-lang/skills \
  --skill dart-add-unit-test \
  --skill dart-run-static-analysis \
  --skill dart-build-cli-app \
  --skill dart-use-doc-examples \
  --agent universal --yes || true

# Skills oficiales de Firebase
echo -e "  ${CYAN}📦 Instalando firebase/agent-skills...${NC}"
npx -y skills add firebase/agent-skills \
  --skill firebase-ai-logic-basics \
  --skill firebase-firestore \
  --skill firebase-basics \
  --skill firebase-auth-basics \
  --skill firebase-hosting-basics \
  --agent universal --yes || true

# --- 3. Instalación de Skills de Ingeniería Avanzada de @jggomez ---
echo -e "\n${YELLOW}[3/4] Instalando Skills de jggomez/expert-ai-developer-skills...${NC}"
echo -e "  ${CYAN}🔗 Repositorio: https://github.com/jggomez/expert-ai-developer-skills${NC}"

npx -y skills add jggomez/expert-ai-developer-skills \
  --skill test-driven-development \
  --skill refactoring-code-expert \
  --skill code-smells-expert \
  --agent universal --yes || true

# --- 4. Configuración del Plugin senior-dev-flutter ---
echo -e "\n${YELLOW}[4/4] Verificando Plugin 'senior-dev-flutter'...${NC}"

PLUGIN_LOCAL_DIR=".agents/plugins/senior-dev-flutter"

if [ -d "$PLUGIN_LOCAL_DIR" ]; then
    echo -e "  ${GREEN}✔ Plugin senior-dev-flutter detectado en el workspace:${NC} $PLUGIN_LOCAL_DIR"
else
    echo -e "  ${YELLOW}ℹ Descargando plugin senior-dev-flutter desde el repo oficial...${NC}"
    mkdir -p .agents/plugins
    TEMP_DIR=$(mktemp -d)
    git clone --depth 1 https://github.com/jggomez/expert-ai-developer-skills.git "$TEMP_DIR"
    cp -r "$TEMP_DIR/plugins/antigravity/senior-dev-flutter" "$PLUGIN_LOCAL_DIR" 2>/dev/null || \
    cp -r "$TEMP_DIR/plugins/senior-dev-flutter" "$PLUGIN_LOCAL_DIR" 2>/dev/null || true
    rm -rf "$TEMP_DIR"
    echo -e "  ${GREEN}✔ Plugin instalado localmente en:${NC} $PLUGIN_LOCAL_DIR"
fi

# Instrucciones para Antigravity CLI y Claude Code
echo -e "\n${CYAN}${BOLD}------------------------------------------------------${NC}"
echo -e "${GREEN}${BOLD}🎉 ¡Harness de Desarrollo IA Aprovisionado con Éxito!${NC}"
echo -e "${CYAN}${BOLD}------------------------------------------------------${NC}"
echo -e "\n${BOLD}Para habilitar el plugin en tu entorno:${NC}"
echo -e "  ${BOLD}• Google Antigravity (AGY):${NC}"
echo -e "    agy plugin install .agents/plugins/senior-dev-flutter"
echo -e "    agy plugin list"
echo -e "\n  ${BOLD}• Claude Code:${NC}"
echo -e "    /plugin marketplace add jggomez/expert-ai-developer-skills"
echo -e "    /plugin install senior-dev-flutter"
echo -e "\n${BOLD}Skills instalados en:${NC} .agents/skills/ y registrados en skills-lock.json"
echo -e "${BOLD}Listo para ejecutar el bucle autónomo con:${NC} ${CYAN}/goal${NC}\n"
