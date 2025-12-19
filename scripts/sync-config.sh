#!/bin/bash
# =============================================================================
# CLAUDE CODE - Sincronizzazione Configurazioni tra Postazioni
# Autore: Eliseo Bosco
# Progetto: PRG0020_CLAUDEAI_PROFILO_EB
# =============================================================================

set -e

# Configurazione - MODIFICA QUESTO PERCORSO per la tua cartella sincronizzata
SYNC_DIR="${CLAUDE_SYNC_DIR:-$HOME/AI-WORKSPACE/projects/PRG0020_CLAUDEAI_PROFILO_EB/sync}"
CLAUDE_HOME="$HOME/.claude"
HOSTNAME=$(hostname)

# Colori output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

show_help() {
    echo "CLAUDE CODE - Sincronizzazione Configurazioni"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandi:"
    echo "  push    Carica configurazioni locali nella cartella sync"
    echo "  pull    Scarica configurazioni dalla cartella sync"
    echo "  status  Mostra stato sincronizzazione"
    echo "  diff    Mostra differenze tra locale e sync"
    echo ""
    echo "Variabili ambiente:"
    echo "  CLAUDE_SYNC_DIR  Percorso cartella sincronizzazione (default: $SYNC_DIR)"
    echo ""
}

init_sync_dir() {
    mkdir -p "$SYNC_DIR"/{profiles,commands,hooks}
    if [ ! -f "$SYNC_DIR/.sync-info" ]; then
        echo "{\"initialized\": \"$(date -Iseconds)\", \"hosts\": []}" > "$SYNC_DIR/.sync-info"
    fi
}

push_config() {
    echo -e "${GREEN}PUSH: Caricamento configurazioni locali...${NC}"
    echo ""

    init_sync_dir

    # Copia profiles
    if [ -d "$CLAUDE_HOME/profiles" ]; then
        echo "  Sincronizzando profiles..."
        rsync -av --delete "$CLAUDE_HOME/profiles/" "$SYNC_DIR/profiles/"
    fi

    # Copia commands
    if [ -d "$CLAUDE_HOME/commands" ]; then
        echo "  Sincronizzando commands..."
        rsync -av --delete "$CLAUDE_HOME/commands/" "$SYNC_DIR/commands/"
    fi

    # Copia hooks
    if [ -d "$CLAUDE_HOME/hooks" ]; then
        echo "  Sincronizzando hooks..."
        rsync -av --delete "$CLAUDE_HOME/hooks/" "$SYNC_DIR/hooks/"
    fi

    # Copia settings
    if [ -f "$CLAUDE_HOME/settings.json" ]; then
        echo "  Sincronizzando settings.json..."
        cp "$CLAUDE_HOME/settings.json" "$SYNC_DIR/"
    fi

    # Aggiorna info sync
    echo "{\"last_push\": \"$(date -Iseconds)\", \"host\": \"$HOSTNAME\", \"user\": \"$USER\"}" > "$SYNC_DIR/.last-push"

    echo ""
    echo -e "${GREEN}Push completato!${NC}"
    echo "Percorso sync: $SYNC_DIR"
}

pull_config() {
    echo -e "${GREEN}PULL: Scaricamento configurazioni...${NC}"
    echo ""

    if [ ! -d "$SYNC_DIR" ]; then
        echo -e "${RED}ERRORE: Directory sync non trovata: $SYNC_DIR${NC}"
        exit 1
    fi

    # Mostra info ultimo push
    if [ -f "$SYNC_DIR/.last-push" ]; then
        echo -e "${CYAN}Ultimo push:${NC}"
        cat "$SYNC_DIR/.last-push" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(f\"  Data: {data.get('last_push', 'N/A')}\")
print(f\"  Host: {data.get('host', 'N/A')}\")
" 2>/dev/null || true
        echo ""
    fi

    # Chiedi conferma
    echo -e "${YELLOW}Questa operazione sovrascrivera' le configurazioni locali.${NC}"
    read -p "Procedere? (s/N): " confirm
    if [[ ! "$confirm" =~ ^[sS]$ ]]; then
        echo "Operazione annullata."
        exit 0
    fi

    mkdir -p "$CLAUDE_HOME"

    # Sincronizza profiles
    if [ -d "$SYNC_DIR/profiles" ]; then
        echo "  Scaricando profiles..."
        rsync -av "$SYNC_DIR/profiles/" "$CLAUDE_HOME/profiles/"
    fi

    # Sincronizza commands
    if [ -d "$SYNC_DIR/commands" ]; then
        echo "  Scaricando commands..."
        rsync -av "$SYNC_DIR/commands/" "$CLAUDE_HOME/commands/"
    fi

    # Sincronizza hooks
    if [ -d "$SYNC_DIR/hooks" ]; then
        echo "  Scaricando hooks..."
        rsync -av "$SYNC_DIR/hooks/" "$CLAUDE_HOME/hooks/"
    fi

    # Sincronizza settings
    if [ -f "$SYNC_DIR/settings.json" ]; then
        echo "  Scaricando settings.json..."
        cp "$SYNC_DIR/settings.json" "$CLAUDE_HOME/"
    fi

    echo ""
    echo -e "${GREEN}Pull completato!${NC}"
    echo -e "${YELLOW}Riavvia Claude Code per applicare le modifiche.${NC}"
}

show_status() {
    echo -e "${GREEN}STATO SINCRONIZZAZIONE${NC}"
    echo ""

    echo -e "${CYAN}Postazione corrente:${NC} $HOSTNAME"
    echo -e "${CYAN}Directory sync:${NC} $SYNC_DIR"
    echo ""

    if [ -f "$SYNC_DIR/.last-push" ]; then
        echo -e "${CYAN}Ultimo push:${NC}"
        cat "$SYNC_DIR/.last-push"
        echo ""
    fi

    echo -e "${CYAN}Contenuto locale (~/.claude):${NC}"
    for dir in profiles commands hooks; do
        if [ -d "$CLAUDE_HOME/$dir" ]; then
            count=$(ls -1 "$CLAUDE_HOME/$dir" 2>/dev/null | wc -l | tr -d ' ')
            echo "  $dir: $count file"
        fi
    done
    [ -f "$CLAUDE_HOME/settings.json" ] && echo "  settings.json: presente"

    echo ""
    echo -e "${CYAN}Contenuto sync:${NC}"
    if [ -d "$SYNC_DIR" ]; then
        for dir in profiles commands hooks; do
            if [ -d "$SYNC_DIR/$dir" ]; then
                count=$(ls -1 "$SYNC_DIR/$dir" 2>/dev/null | wc -l | tr -d ' ')
                echo "  $dir: $count file"
            fi
        done
        [ -f "$SYNC_DIR/settings.json" ] && echo "  settings.json: presente"
    else
        echo "  (non inizializzata)"
    fi
}

show_diff() {
    echo -e "${GREEN}DIFFERENZE CONFIGURAZIONI${NC}"
    echo ""

    if [ ! -d "$SYNC_DIR" ]; then
        echo -e "${RED}Directory sync non trovata${NC}"
        exit 1
    fi

    for dir in profiles commands hooks; do
        if [ -d "$CLAUDE_HOME/$dir" ] || [ -d "$SYNC_DIR/$dir" ]; then
            echo -e "${CYAN}=== $dir ===${NC}"
            diff -rq "$CLAUDE_HOME/$dir" "$SYNC_DIR/$dir" 2>/dev/null || true
            echo ""
        fi
    done

    if [ -f "$CLAUDE_HOME/settings.json" ] && [ -f "$SYNC_DIR/settings.json" ]; then
        echo -e "${CYAN}=== settings.json ===${NC}"
        diff "$CLAUDE_HOME/settings.json" "$SYNC_DIR/settings.json" 2>/dev/null || echo "(identici)"
    fi
}

# Main
case "${1:-}" in
    push)
        push_config
        ;;
    pull)
        pull_config
        ;;
    status)
        show_status
        ;;
    diff)
        show_diff
        ;;
    *)
        show_help
        ;;
esac
