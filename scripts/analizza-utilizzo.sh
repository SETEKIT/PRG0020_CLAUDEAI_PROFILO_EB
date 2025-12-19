#!/bin/bash
# =============================================================================
# CLAUDE CODE - Analisi Utilizzo e Statistiche
# Autore: Eliseo Bosco
# Progetto: PRG0020_CLAUDEAI_PROFILO_EB
# =============================================================================

CLAUDE_HOME="$HOME/.claude"
HISTORY_FILE="$CLAUDE_HOME/history.jsonl"
STATS_FILE="$CLAUDE_HOME/stats-cache.json"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Tasso di cambio USD -> EUR (approssimativo)
USD_TO_EUR=0.92

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}${BOLD}           STATISTICHE UTILIZZO CLAUDE AI                     ${NC}${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Sezione 1: Stats Cache
echo -e "${CYAN}━━━ CACHE STATISTICHE ━━━${NC}"
if [ -f "$STATS_FILE" ]; then
    python3 << 'PYTHON_SCRIPT'
import json
from datetime import datetime

try:
    with open("$HOME/.claude/stats-cache.json".replace("$HOME", __import__("os").environ["HOME"])) as f:
        data = json.load(f)

    print(f"  Ultimo aggiornamento: {data.get('lastUpdated', 'N/A')}")

    if 'stats' in data:
        stats = data['stats']
        print(f"  Sessioni totali:      {stats.get('totalSessions', 'N/A')}")
        print(f"  Token input totali:   {stats.get('totalInputTokens', 'N/A'):,}")
        print(f"  Token output totali:  {stats.get('totalOutputTokens', 'N/A'):,}")

except Exception as e:
    print(f"  Errore lettura stats: {e}")
PYTHON_SCRIPT
else
    echo -e "  ${YELLOW}File stats-cache.json non trovato${NC}"
fi

echo ""

# Sezione 2: Cronologia
echo -e "${CYAN}━━━ CRONOLOGIA CONVERSAZIONI ━━━${NC}"
if [ -f "$HISTORY_FILE" ]; then
    TOTAL_ENTRIES=$(wc -l < "$HISTORY_FILE" | tr -d ' ')
    echo "  Totale entries cronologia: $TOTAL_ENTRIES"

    # Ultimi 7 giorni
    WEEK_AGO=$(date -v-7d +%s 2>/dev/null || date -d '7 days ago' +%s 2>/dev/null || echo "0")
    if [ "$WEEK_AGO" != "0" ]; then
        WEEK_AGO_MS=$((WEEK_AGO * 1000))
        LAST_7_DAYS=$(python3 -c "
import json
count = 0
with open('$HISTORY_FILE') as f:
    for line in f:
        try:
            data = json.loads(line)
            ts = data.get('timestamp', 0)
            if ts > $WEEK_AGO_MS:
                count += 1
        except:
            pass
print(count)
" 2>/dev/null || echo "N/A")
        echo "  Ultimi 7 giorni:          $LAST_7_DAYS entries"
    fi

    # Ultimi 30 giorni
    MONTH_AGO=$(date -v-30d +%s 2>/dev/null || date -d '30 days ago' +%s 2>/dev/null || echo "0")
    if [ "$MONTH_AGO" != "0" ]; then
        MONTH_AGO_MS=$((MONTH_AGO * 1000))
        LAST_30_DAYS=$(python3 -c "
import json
count = 0
with open('$HISTORY_FILE') as f:
    for line in f:
        try:
            data = json.loads(line)
            ts = data.get('timestamp', 0)
            if ts > $MONTH_AGO_MS:
                count += 1
        except:
            pass
print(count)
" 2>/dev/null || echo "N/A")
        echo "  Ultimi 30 giorni:         $LAST_30_DAYS entries"
    fi
else
    echo -e "  ${YELLOW}File history.jsonl non trovato${NC}"
fi

echo ""

# Sezione 3: Progetti
echo -e "${CYAN}━━━ PROGETTI PIÙ ATTIVI ━━━${NC}"
if [ -d "$CLAUDE_HOME/projects" ]; then
    python3 << 'PYTHON_SCRIPT'
import os
from pathlib import Path
from collections import defaultdict

projects_dir = Path(os.environ["HOME"]) / ".claude" / "projects"
project_counts = defaultdict(int)

for project_path in projects_dir.iterdir():
    if project_path.is_dir():
        # Conta file .jsonl (sessioni)
        sessions = list(project_path.glob("*.jsonl"))
        # Escludi file agent-*
        sessions = [s for s in sessions if not s.name.startswith("agent-")]
        if sessions:
            # Estrai nome progetto dal path
            name = project_path.name.replace("-Users-eliseobosco-", "").replace("-", "/")[:40]
            project_counts[name] = len(sessions)

# Top 5
sorted_projects = sorted(project_counts.items(), key=lambda x: x[1], reverse=True)[:5]

for i, (name, count) in enumerate(sorted_projects, 1):
    print(f"  {i}. {name}: {count} sessioni")

if not sorted_projects:
    print("  Nessun progetto trovato")
PYTHON_SCRIPT
else
    echo -e "  ${YELLOW}Directory projects non trovata${NC}"
fi

echo ""

# Sezione 4: Dimensione dati locali
echo -e "${CYAN}━━━ SPAZIO OCCUPATO ━━━${NC}"
if [ -d "$CLAUDE_HOME" ]; then
    TOTAL_SIZE=$(du -sh "$CLAUDE_HOME" 2>/dev/null | cut -f1)
    echo "  Directory ~/.claude:     $TOTAL_SIZE"

    if [ -d "$CLAUDE_HOME/projects" ]; then
        PROJECTS_SIZE=$(du -sh "$CLAUDE_HOME/projects" 2>/dev/null | cut -f1)
        echo "  Sessioni (projects/):    $PROJECTS_SIZE"
    fi

    if [ -f "$HISTORY_FILE" ]; then
        HISTORY_SIZE=$(du -sh "$HISTORY_FILE" 2>/dev/null | cut -f1)
        echo "  Cronologia:              $HISTORY_SIZE"
    fi
fi

echo ""

# Sezione 5: Prezzi riferimento
echo -e "${CYAN}━━━ PREZZI RIFERIMENTO (Dic 2024) ━━━${NC}"
echo "  ┌─────────────────┬────────────┬─────────────┐"
echo "  │ Modello         │ Input/1M   │ Output/1M   │"
echo "  ├─────────────────┼────────────┼─────────────┤"
echo "  │ Claude Sonnet   │ \$3.00      │ \$15.00      │"
echo "  │ Claude Haiku    │ \$0.80      │ \$4.00       │"
echo "  │ Claude Opus     │ \$15.00     │ \$75.00      │"
echo "  └─────────────────┴────────────┴─────────────┘"

echo ""

# Sezione 6: Link utili
echo -e "${CYAN}━━━ VERIFICA CREDITO ONLINE ━━━${NC}"
echo -e "  ${YELLOW}Il credito disponibile non è accessibile via API locale.${NC}"
echo ""
echo "  Verifica su Anthropic Console:"
echo -e "  ${GREEN}→ Usage:   https://console.anthropic.com/settings/usage${NC}"
echo -e "  ${GREEN}→ Billing: https://console.anthropic.com/settings/plans${NC}"
echo -e "  ${GREEN}→ Logs:    https://console.anthropic.com/settings/logs${NC}"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
