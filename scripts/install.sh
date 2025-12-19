#!/bin/bash
# =============================================================================
# CLAUDE CODE - Install/Setup su nuovo Mac
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
echo -e "${GREEN}  CLAUDE CODE - Setup Nuovo Mac        ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verifica esistenza config
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${RED}ERRORE: Directory config non trovata: $CONFIG_DIR${NC}"
    exit 1
fi

# Mostra cosa verra' installato
echo -e "${CYAN}Configurazioni da installare:${NC}"
echo "  - Profiles: $(ls -1 "$CONFIG_DIR/profiles" 2>/dev/null | wc -l | tr -d ' ') file"
echo "  - Commands: $(ls -1 "$CONFIG_DIR/commands" 2>/dev/null | wc -l | tr -d ' ') file"
echo "  - Hooks:    $(ls -1 "$CONFIG_DIR/hooks" 2>/dev/null | wc -l | tr -d ' ') file"
[ -f "$CONFIG_DIR/settings.json" ] && echo "  - settings.json"
echo ""

# Backup se esiste gia' configurazione
if [ -d "$CLAUDE_HOME/profiles" ] || [ -d "$CLAUDE_HOME/commands" ]; then
    echo -e "${YELLOW}Configurazione esistente rilevata.${NC}"
    read -p "Vuoi creare un backup prima di procedere? (S/n): " backup_choice
    if [[ ! "$backup_choice" =~ ^[nN]$ ]]; then
        BACKUP_DIR="$PROJECT_DIR/backups/pre-install-$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        [ -d "$CLAUDE_HOME/profiles" ] && cp -r "$CLAUDE_HOME/profiles" "$BACKUP_DIR/"
        [ -d "$CLAUDE_HOME/commands" ] && cp -r "$CLAUDE_HOME/commands" "$BACKUP_DIR/"
        [ -d "$CLAUDE_HOME/hooks" ] && cp -r "$CLAUDE_HOME/hooks" "$BACKUP_DIR/"
        [ -f "$CLAUDE_HOME/settings.json" ] && cp "$CLAUDE_HOME/settings.json" "$BACKUP_DIR/"
        echo -e "${GREEN}Backup creato in: $BACKUP_DIR${NC}"
        echo ""
    fi
fi

# Conferma installazione
echo -e "${YELLOW}Questa operazione copiera' le configurazioni in ~/.claude${NC}"
read -p "Procedere con l'installazione? (s/N): " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "Installazione annullata."
    exit 0
fi

echo ""
echo -e "${CYAN}Installazione in corso...${NC}"

# Crea directory Claude se non esiste
mkdir -p "$CLAUDE_HOME"

# Installa profiles
if [ -d "$CONFIG_DIR/profiles" ]; then
    echo "  [1/4] Installando profiles..."
    mkdir -p "$CLAUDE_HOME/profiles"
    cp -r "$CONFIG_DIR/profiles/"* "$CLAUDE_HOME/profiles/"
fi

# Installa commands
if [ -d "$CONFIG_DIR/commands" ]; then
    echo "  [2/4] Installando commands..."
    mkdir -p "$CLAUDE_HOME/commands"
    cp -r "$CONFIG_DIR/commands/"* "$CLAUDE_HOME/commands/"
fi

# Installa hooks
if [ -d "$CONFIG_DIR/hooks" ]; then
    echo "  [3/4] Installando hooks..."
    mkdir -p "$CLAUDE_HOME/hooks"
    cp -r "$CONFIG_DIR/hooks/"* "$CLAUDE_HOME/hooks/"
    chmod +x "$CLAUDE_HOME/hooks/"*.sh 2>/dev/null || true
fi

# Installa settings
if [ -f "$CONFIG_DIR/settings.json" ]; then
    echo "  [4/4] Installando settings.json..."
    cp "$CONFIG_DIR/settings.json" "$CLAUDE_HOME/"
fi

echo ""
echo -e "${GREEN}Installazione completata!${NC}"
echo ""
echo -e "${CYAN}Riepilogo:${NC}"
echo "  Profiles installati:  $(ls -1 "$CLAUDE_HOME/profiles" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Commands installati:  $(ls -1 "$CLAUDE_HOME/commands" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Hooks installati:     $(ls -1 "$CLAUDE_HOME/hooks" 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo -e "${YELLOW}Riavvia Claude Code per applicare le modifiche.${NC}"
echo ""
echo "Comandi disponibili:"
echo "  /profili         - Lista profili disponibili"
echo "  /profilo PRF01   - Carica un profilo specifico"
echo "  /security-check  - Quick security check"
