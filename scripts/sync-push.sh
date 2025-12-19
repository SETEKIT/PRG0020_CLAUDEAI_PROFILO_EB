#!/bin/bash
# =============================================================================
# CLAUDE CODE - Sync Push (Local → Repository)
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
echo -e "${GREEN}  CLAUDE CODE - Sync Push              ${NC}"
echo -e "${GREEN}  Local → Repository                   ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verifica esistenza config locale
if [ ! -d "$CLAUDE_HOME" ]; then
    echo -e "${RED}ERRORE: Directory ~/.claude non trovata${NC}"
    exit 1
fi

echo -e "${CYAN}Postazione:${NC} $(hostname)"
echo -e "${CYAN}Data:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Mostra differenze
echo -e "${CYAN}Configurazioni locali:${NC}"
echo "  - Profiles: $(ls -1 "$CLAUDE_HOME/profiles" 2>/dev/null | wc -l | tr -d ' ') file"
echo "  - Commands: $(ls -1 "$CLAUDE_HOME/commands" 2>/dev/null | wc -l | tr -d ' ') file"
echo "  - Hooks:    $(ls -1 "$CLAUDE_HOME/hooks" 2>/dev/null | wc -l | tr -d ' ') file"
echo ""

# Conferma
read -p "Sincronizzare le configurazioni locali nel repository? (s/N): " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "Operazione annullata."
    exit 0
fi

echo ""
echo -e "${CYAN}Sincronizzazione in corso...${NC}"

# Crea directory se non esistono
mkdir -p "$CONFIG_DIR"/{profiles,commands,hooks}

# Sync profiles
if [ -d "$CLAUDE_HOME/profiles" ]; then
    echo "  [1/4] Sincronizzando profiles..."
    rm -rf "$CONFIG_DIR/profiles/"*
    cp "$CLAUDE_HOME/profiles/"*.md "$CONFIG_DIR/profiles/" 2>/dev/null || true
fi

# Sync commands
if [ -d "$CLAUDE_HOME/commands" ]; then
    echo "  [2/4] Sincronizzando commands..."
    rm -rf "$CONFIG_DIR/commands/"*
    cp "$CLAUDE_HOME/commands/"*.md "$CONFIG_DIR/commands/" 2>/dev/null || true
fi

# Sync hooks
if [ -d "$CLAUDE_HOME/hooks" ]; then
    echo "  [3/4] Sincronizzando hooks..."
    rm -rf "$CONFIG_DIR/hooks/"*
    cp "$CLAUDE_HOME/hooks/"*.sh "$CONFIG_DIR/hooks/" 2>/dev/null || true
fi

# Sync settings
if [ -f "$CLAUDE_HOME/settings.json" ]; then
    echo "  [4/4] Sincronizzando settings.json..."
    cp "$CLAUDE_HOME/settings.json" "$CONFIG_DIR/"
fi

# Salva metadata
cat > "$CONFIG_DIR/.sync-metadata.json" << EOF
{
    "last_push": "$(date -Iseconds)",
    "hostname": "$(hostname)",
    "user": "$USER",
    "profiles_count": $(ls -1 "$CONFIG_DIR/profiles" 2>/dev/null | wc -l | tr -d ' '),
    "commands_count": $(ls -1 "$CONFIG_DIR/commands" 2>/dev/null | wc -l | tr -d ' '),
    "hooks_count": $(ls -1 "$CONFIG_DIR/hooks" 2>/dev/null | wc -l | tr -d ' ')
}
EOF

echo ""
echo -e "${GREEN}Sync completato!${NC}"
echo ""

# Mostra status git
echo -e "${CYAN}Status Git:${NC}"
cd "$PROJECT_DIR"
git status --short

echo ""
echo -e "${YELLOW}Per completare la sincronizzazione:${NC}"
echo "  cd $PROJECT_DIR"
echo "  git add -A"
echo "  git commit -m 'sync: $(date '+%Y-%m-%d %H:%M') da $(hostname)'"
echo "  git push"
