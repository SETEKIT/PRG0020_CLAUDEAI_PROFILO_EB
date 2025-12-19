#!/bin/bash
# =============================================================================
# CLAUDE CODE - Analisi Convenienza Piano
# Autore: Eliseo Bosco
# Progetto: PRG0020_CLAUDEAI_PROFILO_EB
# =============================================================================

python3 << 'EOF'
import json
from datetime import datetime
from pathlib import Path

history_file = Path.home() / ".claude" / "history.jsonl"
projects_dir = Path.home() / ".claude" / "projects"

# Colori ANSI
CYAN = '\033[0;36m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
BOLD = '\033[1m'
NC = '\033[0m'

print()
print(f"{CYAN}╔══════════════════════════════════════════════════════════════╗{NC}")
print(f"{CYAN}║{NC}{BOLD}         ANALISI CONVENIENZA PIANO CLAUDE                     {NC}{CYAN}║{NC}")
print(f"{CYAN}╚══════════════════════════════════════════════════════════════╝{NC}")
print()

# Analizza history
entries = []
try:
    with open(history_file) as f:
        for line in f:
            try:
                entries.append(json.loads(line))
            except:
                pass
except FileNotFoundError:
    print(f"{RED}File history.jsonl non trovato{NC}")
    exit(1)

# Date range
timestamps = [e.get('timestamp', 0) for e in entries if e.get('timestamp')]
if timestamps:
    first_date = datetime.fromtimestamp(min(timestamps)/1000)
    last_date = datetime.fromtimestamp(max(timestamps)/1000)
    days_active = (last_date - first_date).days + 1
else:
    print(f"{RED}Nessun dato disponibile{NC}")
    exit(1)

# Conta sessioni uniche
sessions = set(e.get('sessionId') for e in entries if e.get('sessionId'))

# Stima token da dimensione file sessioni
total_session_bytes = 0
session_count = 0
try:
    for sf in projects_dir.glob("**/*.jsonl"):
        if not sf.name.startswith("agent-"):
            total_session_bytes += sf.stat().st_size
            session_count += 1
except:
    pass

# Calcoli
daily_interactions = len(entries) / max(days_active, 1)
monthly_interactions = daily_interactions * 30
daily_sessions = len(sessions) / max(days_active, 1)
monthly_sessions = daily_sessions * 30

print(f"{CYAN}━━━ UTILIZZO RILEVATO ━━━{NC}")
print(f"  Periodo:               {first_date.strftime('%d/%m/%Y')} - {last_date.strftime('%d/%m/%Y')} ({days_active} giorni)")
print(f"  Interazioni totali:    {len(entries)}")
print(f"  Sessioni uniche:       {len(sessions)}")
print(f"  Dati locali:           {total_session_bytes / 1024 / 1024:.1f} MB")
print()
print(f"  Media giornaliera:     {daily_interactions:.0f} interazioni/giorno")
print(f"  Media sessioni/giorno: {daily_sessions:.1f}")
print()

print(f"{CYAN}━━━ PROIEZIONE MENSILE ━━━{NC}")
print(f"  Interazioni stimate:   ~{int(monthly_interactions)}/mese")
print(f"  Sessioni stimate:      ~{int(monthly_sessions)}/mese")
print()

print(f"{CYAN}━━━ CONFRONTO PIANI ━━━{NC}")
print()
print("  ┌─────────────┬────────────┬────────────┬─────────────────────┐")
print("  │ Piano       │ USD/mese   │ EUR/mese   │ Per chi?            │")
print("  ├─────────────┼────────────┼────────────┼─────────────────────┤")
print("  │ Pro         │ $20        │ ~€18       │ Uso occasionale     │")
print("  │ Max 5x      │ $100       │ ~€92       │ Uso quotidiano      │")
print("  │ Max 20x     │ $200       │ ~€184      │ Uso intensivo       │")
print("  └─────────────┴────────────┴────────────┴─────────────────────┘")
print()

# Valutazione
print(f"{CYAN}━━━ VALUTAZIONE ━━━{NC}")
print()

if monthly_interactions > 2000 or daily_interactions > 80:
    level = "INTENSIVO"
    color = RED
    emoji = "🔴"
    recommendation = "MAX 20x"
    reason = "Alto volume di interazioni, probabili blocchi frequenti"
    cost = "€184/mese (€2.208/anno)"
elif monthly_interactions > 1000 or daily_interactions > 40:
    level = "ALTO"
    color = YELLOW
    emoji = "🟠"
    recommendation = "MAX 5x"
    reason = "Uso consistente, Max 5x offre buon rapporto qualità/prezzo"
    cost = "€92/mese (€1.104/anno)"
elif monthly_interactions > 500 or daily_interactions > 20:
    level = "MEDIO"
    color = YELLOW
    emoji = "🟡"
    recommendation = "PRO o MAX 5x"
    reason = "Dipende dalla frequenza dei blocchi. Prova Pro, passa a Max 5x se blocchi frequenti"
    cost = "€18-92/mese"
else:
    level = "MODERATO"
    color = GREEN
    emoji = "🟢"
    recommendation = "PRO"
    reason = "Utilizzo contenuto, Pro dovrebbe essere sufficiente"
    cost = "€18/mese (€216/anno)"

print(f"  {emoji} Livello utilizzo: {color}{BOLD}{level}{NC}")
print()
print(f"  {BOLD}Raccomandazione:{NC} {GREEN}{recommendation}{NC}")
print(f"  {BOLD}Motivazione:{NC} {reason}")
print(f"  {BOLD}Costo stimato:{NC} {cost}")
print()

# Calcolo risparmio/costo extra
print(f"{CYAN}━━━ CALCOLO ECONOMICO ━━━{NC}")
print()
pro_annual = 216
max5_annual = 1104
max20_annual = 2208

if "PRO" in recommendation and "MAX" not in recommendation:
    print(f"  Con Pro risparmi vs Max 5x:   €{max5_annual - pro_annual}/anno")
    print(f"  Con Pro risparmi vs Max 20x:  €{max20_annual - pro_annual}/anno")
elif "5x" in recommendation and "20x" not in recommendation:
    print(f"  Max 5x costa extra vs Pro:    +€{max5_annual - pro_annual}/anno")
    print(f"  Max 5x risparmia vs Max 20x:  €{max20_annual - max5_annual}/anno")
elif "20x" in recommendation:
    print(f"  Max 20x costa extra vs Pro:    +€{max20_annual - pro_annual}/anno")
    print(f"  Max 20x costa extra vs Max 5x: +€{max20_annual - max5_annual}/anno")
else:
    # PRO o MAX 5x
    print(f"  Pro:    €{pro_annual}/anno")
    print(f"  Max 5x: €{max5_annual}/anno (+€{max5_annual - pro_annual} vs Pro)")

print()

# Domande chiave
print(f"{CYAN}━━━ DOMANDE PER DECIDERE ━━━{NC}")
print()
print("  Rispondi a queste domande per confermare:")
print()
print("  1. Raggiungi il limite messaggi più di 2-3 volte/settimana?")
print("     Sì → Considera upgrade")
print()
print("  2. Usi principalmente Opus (più costoso) o Sonnet?")
print("     Opus → Limiti più stretti, considera upgrade")
print()
print("  3. Hai bisogno di sessioni lunghe senza interruzioni?")
print("     Sì → Max 5x o 20x")
print()

print(f"{CYAN}━━━ LINK UTILI ━━━{NC}")
print(f"  → Piani:  https://claude.ai/settings/billing")
print(f"  → Usage:  https://console.anthropic.com/settings/usage")
print()
EOF
