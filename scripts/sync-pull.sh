#!/bin/bash
# =============================================================================
# CLAUDE CODE - Sync Pull (Repository → Local)
# Autore: Eliseo Bosco
# Progetto: PRG0020_CLAUDEAI_PROFILO_EB
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/claude-config"
CLAUDE_HOME="$HOME/.claude"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CLAUDE CODE - Sync Pull              ${NC}"
echo -e "${GREEN}  Repository → Local                   ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verifica esistenza config nel repo
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${RED}ERRORE: Directory config non trovata: $CONFIG_DIR${NC}"
    exit 1
fi

# Pull git prima
echo -e "${CYAN}Aggiornamento repository...${NC}"
cd "$PROJECT_DIR"
git pull --rebase 2>/dev/null || echo -e "${YELLOW}Warning: git pull fallito, continuo con versione locale${NC}"
echo ""

# Mostra metadata ultimo push
if [ -f "$CONFIG_DIR/.sync-metadata.json" ]; then
    echo -e "${CYAN}Ultimo push:${NC}"
    cat "$CONFIG_DIR/.sync-metadata.json" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(f\"  Data: {data.get('last_push', 'N/A')}\")
print(f\"  Host: {data.get('hostname', 'N/A')}\")
print(f\"  User: {data.get('user', 'N/A')}\")
" 2>/dev/null || true
    echo ""
fi

echo -e "${CYAN}Configurazioni nel repository:${NC}"
echo "  - Profiles: $(ls -1 "$CONFIG_DIR/profiles" 2>/dev/null | wc -l | tr -d ' ') file"
echo "  - Commands: $(ls -1 "$CONFIG_DIR/commands" 2>/dev/null | wc -l | tr -d ' ') file"
echo "  - Hooks:    $(ls -1 "$CONFIG_DIR/hooks" 2>/dev/null | wc -l | tr -d ' ') file"
echo ""

echo -e "${CYAN}Configurazioni locali attuali:${NC}"
echo "  - Profiles: $(ls -1 "$CLAUDE_HOME/profiles" 2>/dev/null | wc -l | tr -d ' ') file"
echo "  - Commands: $(ls -1 "$CLAUDE_HOME/commands" 2>/dev/null | wc -l | tr -d ' ') file"
echo "  - Hooks:    $(ls -1 "$CLAUDE_HOME/hooks" 2>/dev/null | wc -l | tr -d ' ') file"
echo ""

# Conferma
echo -e "${YELLOW}Questa operazione sovrascrivera' le configurazioni locali.${NC}"
read -p "Procedere? (s/N): " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "Operazione annullata."
    exit 0
fi

echo ""
echo -e "${CYAN}Sincronizzazione in corso...${NC}"

# Crea directory Claude se non esiste
mkdir -p "$CLAUDE_HOME"/{profiles,commands,hooks}

# Sync profiles
if [ -d "$CONFIG_DIR/profiles" ] && [ "$(ls -A "$CONFIG_DIR/profiles" 2>/dev/null)" ]; then
    echo "  [1/4] Sincronizzando profiles..."
    rm -rf "$CLAUDE_HOME/profiles/"*
    cp "$CONFIG_DIR/profiles/"* "$CLAUDE_HOME/profiles/"
fi

# Sync commands
if [ -d "$CONFIG_DIR/commands" ] && [ "$(ls -A "$CONFIG_DIR/commands" 2>/dev/null)" ]; then
    echo "  [2/4] Sincronizzando commands..."
    rm -rf "$CLAUDE_HOME/commands/"*
    cp "$CONFIG_DIR/commands/"* "$CLAUDE_HOME/commands/"
fi

# Sync hooks
if [ -d "$CONFIG_DIR/hooks" ] && [ "$(ls -A "$CONFIG_DIR/hooks" 2>/dev/null)" ]; then
    echo "  [3/4] Sincronizzando hooks..."
    rm -rf "$CLAUDE_HOME/hooks/"*
    cp "$CONFIG_DIR/hooks/"* "$CLAUDE_HOME/hooks/"
    chmod +x "$CLAUDE_HOME/hooks/"*.sh 2>/dev/null || true
fi

# Sync settings
if [ -f "$CONFIG_DIR/settings.json" ]; then
    echo "  [4/4] Sincronizzando settings.json..."
    cp "$CONFIG_DIR/settings.json" "$CLAUDE_HOME/"
fi

echo ""
echo -e "${GREEN}Sync completato!${NC}"
echo ""
echo -e "${CYAN}Riepilogo configurazioni installate:${NC}"
echo "  Profiles: $(ls -1 "$CLAUDE_HOME/profiles" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Commands: $(ls -1 "$CLAUDE_HOME/commands" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Hooks:    $(ls -1 "$CLAUDE_HOME/hooks" 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo -e "${YELLOW}Riavvia Claude Code per applicare le modifiche.${NC}"
