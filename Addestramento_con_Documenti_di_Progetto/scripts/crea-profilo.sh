#!/bin/bash
# =============================================================================
# CLAUDE CODE - Wizard Creazione Profilo
# Autore: Eliseo Bosco
# Progetto: PRG0020_CLAUDEAI_PROFILO_EB
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$BASE_DIR/templates"
OUTPUT_DIR="$BASE_DIR/esempi"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CLAUDE CODE - Creazione Profilo      ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 1. Codice profilo
while true; do
    read -p "Codice profilo (es. PRF100): " PROFILE_CODE
    if [[ "$PROFILE_CODE" =~ ^PRF[0-9]{3}$ ]]; then
        break
    fi
    echo -e "${RED}Formato non valido. Usa PRFxxx (es. PRF100)${NC}"
done

# 2. Nome profilo
read -p "Nome profilo (es. sviluppo-webapp): " PROFILE_NAME
PROFILE_NAME=${PROFILE_NAME:-"nuovo-profilo"}

# 3. Tipo template
echo ""
echo -e "${CYAN}Seleziona template base:${NC}"
echo "  1) Base (generico)"
echo "  2) Sviluppo Software"
echo "  3) Vuoto (crea da zero)"
echo ""
read -p "Scelta [1-3]: " TEMPLATE_CHOICE

case $TEMPLATE_CHOICE in
    1) TEMPLATE="$TEMPLATES_DIR/profilo-base.md" ;;
    2) TEMPLATE="$TEMPLATES_DIR/profilo-sviluppo.md" ;;
    3) TEMPLATE="" ;;
    *) TEMPLATE="$TEMPLATES_DIR/profilo-base.md" ;;
esac

# 4. Informazioni base
echo ""
echo -e "${CYAN}Informazioni Profilo:${NC}"
read -p "Ruolo principale (es. Senior Developer): " ROLE
read -p "Tecnologie/Stack (es. Python, FastAPI): " STACK
read -p "Azienda/Progetto (es. SETEK): " COMPANY

# 5. Genera file
FILENAME="${PROFILE_CODE}-${PROFILE_NAME}.md"
OUTPUT_FILE="$OUTPUT_DIR/$FILENAME"

echo ""
echo -e "${CYAN}Generazione profilo...${NC}"

if [ -n "$TEMPLATE" ] && [ -f "$TEMPLATE" ]; then
    # Copia template e sostituisci placeholder
    cp "$TEMPLATE" "$OUTPUT_FILE"

    # Sostituzioni base
    sed -i '' "s/PRFxxx/${PROFILE_CODE}/g" "$OUTPUT_FILE" 2>/dev/null || \
    sed -i "s/PRFxxx/${PROFILE_CODE}/g" "$OUTPUT_FILE"

    sed -i '' "s/\[Nome Profilo\]/${PROFILE_NAME}/g" "$OUTPUT_FILE" 2>/dev/null || \
    sed -i "s/\[Nome Profilo\]/${PROFILE_NAME}/g" "$OUTPUT_FILE"

    sed -i '' "s/\[STACK_TECNOLOGICO\]/${STACK}/g" "$OUTPUT_FILE" 2>/dev/null || \
    sed -i "s/\[STACK_TECNOLOGICO\]/${STACK}/g" "$OUTPUT_FILE"

    sed -i '' "s/\[AZIENDA\]/${COMPANY}/g" "$OUTPUT_FILE" 2>/dev/null || \
    sed -i "s/\[AZIENDA\]/${COMPANY}/g" "$OUTPUT_FILE"

    sed -i '' "s/\[DATA\]/$(date '+%Y-%m-%d')/g" "$OUTPUT_FILE" 2>/dev/null || \
    sed -i "s/\[DATA\]/$(date '+%Y-%m-%d')/g" "$OUTPUT_FILE"
else
    # Crea profilo vuoto
    cat > "$OUTPUT_FILE" << EOF
# ${PROFILE_CODE} - ${PROFILE_NAME}

## Ruolo
Sei un ${ROLE:-"assistente specializzato"} che lavora con ${STACK:-"varie tecnologie"} per ${COMPANY:-"il progetto corrente"}.

## Competenze Principali
- [Aggiungi competenza 1]
- [Aggiungi competenza 2]
- [Aggiungi competenza 3]

## Contesto Progetto
[Aggiungi informazioni sul progetto]

## Linee Guida
[Aggiungi linee guida specifiche]

## Esempi
[Aggiungi esempi di comportamento atteso]

---
Versione: 1.0
Creato: $(date '+%Y-%m-%d')
EOF
fi

echo ""
echo -e "${GREEN}Profilo creato!${NC}"
echo ""
echo -e "${CYAN}File:${NC} $OUTPUT_FILE"
echo ""
echo -e "${YELLOW}Prossimi passi:${NC}"
echo "  1. Modifica il profilo: nano $OUTPUT_FILE"
echo "  2. Importa documenti:   ./scripts/importa-documenti.sh $PROFILE_CODE /path/docs/"
echo "  3. Installa:            cp $OUTPUT_FILE ~/.claude/profiles/"
echo "  4. Attiva:              /profilo $PROFILE_CODE"
