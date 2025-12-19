#!/bin/bash
# =============================================================================
# CLAUDE CODE - Restore Configurazioni
# Autore: Eliseo Bosco
# Progetto: PRG0020_CLAUDEAI_PROFILO_EB
# =============================================================================

set -e

# Configurazione
CLAUDE_HOME="$HOME/.claude"
BACKUP_PATH="$1"

# Colori output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CLAUDE CODE - Restore Configurazioni ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verifica parametro
if [ -z "$BACKUP_PATH" ]; then
    echo -e "${RED}ERRORE: Specificare il percorso del backup${NC}"
    echo ""
    echo "Uso: $0 <percorso-backup>"
    echo ""
    echo "Esempio: $0 ./backups/claude-config-20251219_120000"
    exit 1
fi

# Verifica esistenza backup
if [ ! -d "$BACKUP_PATH" ]; then
    echo -e "${RED}ERRORE: Directory backup non trovata: $BACKUP_PATH${NC}"
    exit 1
fi

# Mostra manifest se esiste
if [ -f "$BACKUP_PATH/manifest.json" ]; then
    echo -e "${CYAN}Info Backup:${NC}"
    cat "$BACKUP_PATH/manifest.json" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(f\"  Data: {data.get('backup_date', 'N/A')}\" )
print(f\"  Host origine: {data.get('hostname', 'N/A')}\")
print(f\"  Utente: {data.get('user', 'N/A')}\")
" 2>/dev/null || true
    echo ""
fi

# Crea directory Claude se non esiste
mkdir -p "$CLAUDE_HOME"

# Chiedi conferma
echo -e "${YELLOW}ATTENZIONE: Questa operazione sovrascrivera' le configurazioni esistenti.${NC}"
echo ""
read -p "Vuoi procedere? (s/N): " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "Operazione annullata."
    exit 0
fi

echo ""
echo -e "${YELLOW}Restore in corso...${NC}"
echo ""

# 1. Restore profili
if [ -d "$BACKUP_PATH/profiles" ]; then
    echo "  [1/6] Ripristinando profiles..."
    rm -rf "$CLAUDE_HOME/profiles"
    cp -r "$BACKUP_PATH/profiles" "$CLAUDE_HOME/"
fi

# 2. Restore commands
if [ -d "$BACKUP_PATH/commands" ]; then
    echo "  [2/6] Ripristinando commands..."
    rm -rf "$CLAUDE_HOME/commands"
    cp -r "$BACKUP_PATH/commands" "$CLAUDE_HOME/"
fi

# 3. Restore hooks
if [ -d "$BACKUP_PATH/hooks" ]; then
    echo "  [3/6] Ripristinando hooks..."
    rm -rf "$CLAUDE_HOME/hooks"
    cp -r "$BACKUP_PATH/hooks" "$CLAUDE_HOME/"
fi

# 4. Restore settings
if [ -f "$BACKUP_PATH/settings.json" ]; then
    echo "  [4/6] Ripristinando settings.json..."
    cp "$BACKUP_PATH/settings.json" "$CLAUDE_HOME/"
fi

# 5. Restore history (opzionale)
if [ -f "$BACKUP_PATH/history.jsonl" ]; then
    echo "  [5/6] Ripristinando history.jsonl..."
    cp "$BACKUP_PATH/history.jsonl" "$CLAUDE_HOME/"
fi

# 6. Restore progetti/sessioni (opzionale)
if [ -d "$BACKUP_PATH/projects" ]; then
    echo "  [6/6] Ripristinando projects..."
    # Merge invece di sovrascrivere per non perdere sessioni locali
    mkdir -p "$CLAUDE_HOME/projects"
    cp -r "$BACKUP_PATH/projects/"* "$CLAUDE_HOME/projects/" 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}Restore completato!${NC}"
echo ""
echo "Configurazioni ripristinate in: $CLAUDE_HOME"
echo ""
echo -e "${YELLOW}Nota: Riavvia Claude Code per applicare le modifiche.${NC}"
