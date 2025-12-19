#!/bin/bash
# =============================================================================
# CLAUDE CODE - Backup Configurazioni
# Autore: Eliseo Bosco
# Progetto: PRG0020_CLAUDEAI_PROFILO_EB
# =============================================================================

set -e

# Configurazione
CLAUDE_HOME="$HOME/.claude"
BACKUP_DIR="${1:-$(dirname "$0")/../backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="claude-config-$TIMESTAMP"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Colori output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CLAUDE CODE - Backup Configurazioni  ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verifica esistenza directory Claude
if [ ! -d "$CLAUDE_HOME" ]; then
    echo -e "${RED}ERRORE: Directory $CLAUDE_HOME non trovata${NC}"
    exit 1
fi

# Crea directory backup
mkdir -p "$BACKUP_PATH"

echo -e "${YELLOW}Backup in corso...${NC}"
echo ""

# 1. Backup profili
if [ -d "$CLAUDE_HOME/profiles" ]; then
    echo "  [1/6] Copiando profiles..."
    cp -r "$CLAUDE_HOME/profiles" "$BACKUP_PATH/"
fi

# 2. Backup commands
if [ -d "$CLAUDE_HOME/commands" ]; then
    echo "  [2/6] Copiando commands..."
    cp -r "$CLAUDE_HOME/commands" "$BACKUP_PATH/"
fi

# 3. Backup hooks
if [ -d "$CLAUDE_HOME/hooks" ]; then
    echo "  [3/6] Copiando hooks..."
    cp -r "$CLAUDE_HOME/hooks" "$BACKUP_PATH/"
fi

# 4. Backup settings
if [ -f "$CLAUDE_HOME/settings.json" ]; then
    echo "  [4/6] Copiando settings.json..."
    cp "$CLAUDE_HOME/settings.json" "$BACKUP_PATH/"
fi

# 5. Backup history (opzionale - chat history index)
if [ -f "$CLAUDE_HOME/history.jsonl" ]; then
    echo "  [5/6] Copiando history.jsonl..."
    cp "$CLAUDE_HOME/history.jsonl" "$BACKUP_PATH/"
fi

# 6. Backup sessioni chat complete (opzionale)
if [ -d "$CLAUDE_HOME/projects" ]; then
    echo "  [6/6] Copiando projects (sessioni chat)..."
    cp -r "$CLAUDE_HOME/projects" "$BACKUP_PATH/"
fi

# Crea file manifest
cat > "$BACKUP_PATH/manifest.json" << EOF
{
    "backup_date": "$(date -Iseconds)",
    "hostname": "$(hostname)",
    "user": "$USER",
    "claude_home": "$CLAUDE_HOME",
    "contents": {
        "profiles": $([ -d "$BACKUP_PATH/profiles" ] && echo "true" || echo "false"),
        "commands": $([ -d "$BACKUP_PATH/commands" ] && echo "true" || echo "false"),
        "hooks": $([ -d "$BACKUP_PATH/hooks" ] && echo "true" || echo "false"),
        "settings": $([ -f "$BACKUP_PATH/settings.json" ] && echo "true" || echo "false"),
        "history": $([ -f "$BACKUP_PATH/history.jsonl" ] && echo "true" || echo "false"),
        "projects": $([ -d "$BACKUP_PATH/projects" ] && echo "true" || echo "false")
    }
}
EOF

echo ""
echo -e "${GREEN}Backup completato!${NC}"
echo ""
echo "Percorso: $BACKUP_PATH"
echo ""

# Statistiche
echo "Contenuto backup:"
du -sh "$BACKUP_PATH"/* 2>/dev/null | while read size path; do
    echo "  $size  $(basename "$path")"
done

echo ""
echo -e "${YELLOW}Per sincronizzare su altra postazione:${NC}"
echo "  1. Copia la cartella $BACKUP_NAME sulla nuova postazione"
echo "  2. Esegui: ./restore-claude-config.sh <percorso-backup>"
