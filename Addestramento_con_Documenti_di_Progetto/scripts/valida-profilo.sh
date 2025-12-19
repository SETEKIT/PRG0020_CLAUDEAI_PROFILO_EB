#!/bin/bash
# =============================================================================
# CLAUDE CODE - Valida Profilo
# Autore: Eliseo Bosco
# Progetto: PRG0020_CLAUDEAI_PROFILO_EB
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo "Uso: $0 <file_profilo.md>"
    exit 1
fi

PROFILE_FILE="$1"

if [ ! -f "$PROFILE_FILE" ]; then
    echo -e "${RED}ERRORE: File non trovato: $PROFILE_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CLAUDE CODE - Validazione Profilo    ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

PROFILE_NAME=$(basename "$PROFILE_FILE")
echo -e "${CYAN}File:${NC} $PROFILE_NAME"
echo ""

# Contatori
ERRORS=0
WARNINGS=0

# 1. Verifica dimensione
SIZE=$(wc -c < "$PROFILE_FILE" | tr -d ' ')
WORDS=$(wc -w < "$PROFILE_FILE" | tr -d ' ')
LINES=$(wc -l < "$PROFILE_FILE" | tr -d ' ')

echo -e "${CYAN}Statistiche:${NC}"
echo "  Dimensione: ${SIZE} bytes"
echo "  Parole: ${WORDS}"
echo "  Righe: ${LINES}"
echo ""

if [ "$WORDS" -gt 5000 ]; then
    echo -e "${RED}[ERRORE] Profilo troppo lungo (${WORDS} parole > 5000)${NC}"
    ((ERRORS++))
elif [ "$WORDS" -gt 4000 ]; then
    echo -e "${YELLOW}[WARNING] Profilo lungo (${WORDS} parole > 4000)${NC}"
    ((WARNINGS++))
else
    echo -e "${GREEN}[OK] Dimensione accettabile${NC}"
fi

# 2. Verifica sezioni richieste
echo ""
echo -e "${CYAN}Verifica sezioni:${NC}"

REQUIRED_SECTIONS=("Ruolo" "Competenze" "Linee Guida")
for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qi "## .*${section}" "$PROFILE_FILE" || grep -qi "# .*${section}" "$PROFILE_FILE"; then
        echo -e "${GREEN}[OK] Sezione '$section' presente${NC}"
    else
        echo -e "${YELLOW}[WARNING] Sezione '$section' non trovata${NC}"
        ((WARNINGS++))
    fi
done

# 3. Verifica codice profilo nel nome
if [[ "$PROFILE_NAME" =~ ^PRF[0-9]{3} ]]; then
    echo -e "${GREEN}[OK] Naming convention rispettata (PRFxxx)${NC}"
else
    echo -e "${YELLOW}[WARNING] Nome file non segue convention PRFxxx-nome.md${NC}"
    ((WARNINGS++))
fi

# 4. Verifica contenuti sensibili
echo ""
echo -e "${CYAN}Verifica sicurezza:${NC}"

SENSITIVE_PATTERNS=("password" "api_key" "apikey" "secret" "token" "Bearer " "sk-" "pk_")
FOUND_SENSITIVE=0

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if grep -qi "$pattern" "$PROFILE_FILE"; then
        echo -e "${RED}[ERRORE] Possibile dato sensibile trovato: '$pattern'${NC}"
        ((ERRORS++))
        ((FOUND_SENSITIVE++))
    fi
done

if [ "$FOUND_SENSITIVE" -eq 0 ]; then
    echo -e "${GREEN}[OK] Nessun dato sensibile rilevato${NC}"
fi

# 5. Verifica placeholder non sostituiti
echo ""
echo -e "${CYAN}Verifica placeholder:${NC}"

PLACEHOLDERS=("\[.*\]" "xxx" "TODO" "FIXME")
FOUND_PLACEHOLDER=0

for pattern in "${PLACEHOLDERS[@]}"; do
    count=$(grep -c "$pattern" "$PROFILE_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
    if [ "${count:-0}" -gt 3 ]; then
        echo -e "${YELLOW}[WARNING] Possibili placeholder non sostituiti: '$pattern' (${count} occorrenze)${NC}"
        ((WARNINGS++))
        ((FOUND_PLACEHOLDER++))
    fi
done

if [ "$FOUND_PLACEHOLDER" -eq 0 ]; then
    echo -e "${GREEN}[OK] Nessun placeholder evidente${NC}"
fi

# 6. Verifica encoding
echo ""
echo -e "${CYAN}Verifica encoding:${NC}"

if file "$PROFILE_FILE" | grep -q "UTF-8\|ASCII"; then
    echo -e "${GREEN}[OK] Encoding valido (UTF-8/ASCII)${NC}"
else
    echo -e "${YELLOW}[WARNING] Encoding potenzialmente problematico${NC}"
    ((WARNINGS++))
fi

# Riepilogo
echo ""
echo "=========================================="
echo -e "${CYAN}RIEPILOGO VALIDAZIONE${NC}"
echo "=========================================="

if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}Errori: ${ERRORS}${NC}"
fi

if [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}Warning: ${WARNINGS}${NC}"
fi

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}Profilo valido! Nessun problema rilevato.${NC}"
    echo ""
    echo "Puoi installarlo con:"
    echo "  cp $PROFILE_FILE ~/.claude/profiles/"
    exit 0
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}Profilo utilizzabile ma con avvertimenti.${NC}"
    exit 0
else
    echo -e "${RED}Profilo con errori. Correggere prima dell'uso.${NC}"
    exit 1
fi
