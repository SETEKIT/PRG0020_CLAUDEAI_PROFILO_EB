#!/bin/bash
# =============================================================================
# CLAUDE CODE - Restore con Menu Selezione Backup
# Autore: Eliseo Bosco
# Progetto: PRG0020_CLAUDEAI_PROFILO_EB
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_BASE="$PROJECT_DIR/backups"
CLAUDE_HOME="$HOME/.claude"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CLAUDE CODE - Restore Backup         ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verifica esistenza directory backup
if [ ! -d "$BACKUP_BASE" ]; then
    echo -e "${RED}ERRORE: Directory backup non trovata: $BACKUP_BASE${NC}"
    exit 1
fi

# Trova tutti i backup disponibili
BACKUPS=($(ls -1d "$BACKUP_BASE"/backup-* 2>/dev/null | sort -r))

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo -e "${RED}Nessun backup disponibile.${NC}"
    echo "Esegui prima: ./scripts/backup.sh"
    exit 1
fi

# Mostra menu di selezione
echo -e "${CYAN}Backup disponibili:${NC}"
echo ""
echo -e "${BOLD}  #   Data                Host              Profiles  Commands${NC}"
echo "  ─────────────────────────────────────────────────────────────"

i=1
for backup in "${BACKUPS[@]}"; do
    backup_name=$(basename "$backup")

    # Estrai info dal manifest se esiste
    if [ -f "$backup/manifest.json" ]; then
        info=$(python3 -c "
import json
with open('$backup/manifest.json') as f:
    data = json.load(f)
    date = data.get('backup_date', 'N/A')[:19].replace('T', ' ')
    host = data.get('hostname', 'N/A')[:15]
    profiles = data.get('contents', {}).get('profiles', 0)
    commands = data.get('contents', {}).get('commands', 0)
    print(f'{date}  {host:<15}  {profiles:<8}  {commands}')
" 2>/dev/null) || info="N/A"
    else
        # Estrai data dal nome cartella
        date_part=$(echo "$backup_name" | sed 's/backup-//' | sed 's/_/ /')
        info="$date_part"
    fi

    echo -e "  ${BOLD}$i)${NC}  $info"
    ((i++))
done

echo ""
echo -e "  ${BOLD}0)${NC}  Annulla"
echo ""

# Chiedi selezione
while true; do
    read -p "Seleziona backup da ripristinare [0-${#BACKUPS[@]}]: " choice

    # Verifica input valido
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if [ "$choice" -eq 0 ]; then
            echo "Operazione annullata."
            exit 0
        elif [ "$choice" -ge 1 ] && [ "$choice" -le ${#BACKUPS[@]} ]; then
            SELECTED_BACKUP="${BACKUPS[$((choice-1))]}"
            break
        fi
    fi
    echo -e "${RED}Selezione non valida. Riprova.${NC}"
done

echo ""
BACKUP_NAME=$(basename "$SELECTED_BACKUP")
echo -e "${CYAN}Backup selezionato:${NC} $BACKUP_NAME"

# Mostra dettagli backup
if [ -f "$SELECTED_BACKUP/manifest.json" ]; then
    echo ""
    echo -e "${CYAN}Dettagli:${NC}"
    python3 -c "
import json
with open('$SELECTED_BACKUP/manifest.json') as f:
    data = json.load(f)
    print(f\"  Data:     {data.get('backup_date', 'N/A')}\")
    print(f\"  Host:     {data.get('hostname', 'N/A')}\")
    print(f\"  User:     {data.get('user', 'N/A')}\")
    contents = data.get('contents', {})
    print(f\"  Profiles: {contents.get('profiles', 0)}\")
    print(f\"  Commands: {contents.get('commands', 0)}\")
    print(f\"  Hooks:    {contents.get('hooks', 0)}\")
    print(f\"  Settings: {'Si' if contents.get('settings') else 'No'}\")
    print(f\"  History:  {'Si' if contents.get('history') else 'No'}\")
" 2>/dev/null || true
fi

echo ""
echo -e "${YELLOW}ATTENZIONE: Questa operazione sovrascrivera' le configurazioni attuali.${NC}"
read -p "Procedere con il restore? (s/N): " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "Operazione annullata."
    exit 0
fi

echo ""
echo -e "${CYAN}Restore in corso...${NC}"

# Crea directory Claude se non esiste
mkdir -p "$CLAUDE_HOME"

# Restore profiles
if [ -d "$SELECTED_BACKUP/profiles" ]; then
    echo "  [1/5] Ripristinando profiles..."
    mkdir -p "$CLAUDE_HOME/profiles"
    rm -rf "$CLAUDE_HOME/profiles/"*
    cp -r "$SELECTED_BACKUP/profiles/"* "$CLAUDE_HOME/profiles/"
fi

# Restore commands
if [ -d "$SELECTED_BACKUP/commands" ]; then
    echo "  [2/5] Ripristinando commands..."
    mkdir -p "$CLAUDE_HOME/commands"
    rm -rf "$CLAUDE_HOME/commands/"*
    cp -r "$SELECTED_BACKUP/commands/"* "$CLAUDE_HOME/commands/"
fi

# Restore hooks
if [ -d "$SELECTED_BACKUP/hooks" ]; then
    echo "  [3/5] Ripristinando hooks..."
    mkdir -p "$CLAUDE_HOME/hooks"
    rm -rf "$CLAUDE_HOME/hooks/"*
    cp -r "$SELECTED_BACKUP/hooks/"* "$CLAUDE_HOME/hooks/"
    chmod +x "$CLAUDE_HOME/hooks/"*.sh 2>/dev/null || true
fi

# Restore settings
if [ -f "$SELECTED_BACKUP/settings.json" ]; then
    echo "  [4/5] Ripristinando settings.json..."
    cp "$SELECTED_BACKUP/settings.json" "$CLAUDE_HOME/"
fi

# Restore history (opzionale)
if [ -f "$SELECTED_BACKUP/history.jsonl" ]; then
    echo "  [5/5] Ripristinando history.jsonl..."
    cp "$SELECTED_BACKUP/history.jsonl" "$CLAUDE_HOME/"
fi

echo ""
echo -e "${GREEN}Restore completato!${NC}"
echo ""
echo -e "${CYAN}Riepilogo:${NC}"
echo "  Profiles: $(ls -1 "$CLAUDE_HOME/profiles" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Commands: $(ls -1 "$CLAUDE_HOME/commands" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Hooks:    $(ls -1 "$CLAUDE_HOME/hooks" 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo -e "${YELLOW}Riavvia Claude Code per applicare le modifiche.${NC}"
