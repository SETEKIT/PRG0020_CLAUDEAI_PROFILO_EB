#!/bin/bash
# =============================================================================
# CLAUDE CODE - Importa Documenti in Profilo
# Autore: Eliseo Bosco
# Progetto: PRG0020_CLAUDEAI_PROFILO_EB
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
ESEMPI_DIR="$BASE_DIR/esempi"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

show_help() {
    echo "CLAUDE CODE - Importa Documenti in Profilo"
    echo ""
    echo "Uso: $0 <CODICE_PROFILO> <PATH_DOCUMENTI> [opzioni]"
    echo ""
    echo "Argomenti:"
    echo "  CODICE_PROFILO    Codice profilo (es. PRF100)"
    echo "  PATH_DOCUMENTI    Cartella con i documenti da importare"
    echo ""
    echo "Opzioni:"
    echo "  --readme          Importa solo README.md"
    echo "  --standards       Cerca file di standard (STANDARDS.md, CODING.md, etc.)"
    echo "  --all             Importa tutti i .md trovati"
    echo "  --summary         Genera solo sommario (non copia contenuto)"
    echo ""
    echo "Esempio:"
    echo "  $0 PRF100 /path/to/project/docs --standards"
}

if [ "$#" -lt 2 ]; then
    show_help
    exit 1
fi

PROFILE_CODE="$1"
DOCS_PATH="$2"
MODE="${3:---standards}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CLAUDE CODE - Importa Documenti      ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verifica profilo esistente
PROFILE_FILE=$(find "$ESEMPI_DIR" -name "${PROFILE_CODE}*.md" 2>/dev/null | head -1)

if [ -z "$PROFILE_FILE" ]; then
    echo -e "${YELLOW}Profilo $PROFILE_CODE non trovato in $ESEMPI_DIR${NC}"
    echo "Creo un nuovo file di contesto..."
    PROFILE_FILE="$ESEMPI_DIR/${PROFILE_CODE}-contesto-importato.md"
    echo "# ${PROFILE_CODE} - Contesto Importato" > "$PROFILE_FILE"
    echo "" >> "$PROFILE_FILE"
    echo "Documenti importati da: $DOCS_PATH" >> "$PROFILE_FILE"
    echo "Data: $(date '+%Y-%m-%d %H:%M')" >> "$PROFILE_FILE"
    echo "" >> "$PROFILE_FILE"
fi

# Verifica path documenti
if [ ! -d "$DOCS_PATH" ]; then
    echo -e "${RED}ERRORE: Directory non trovata: $DOCS_PATH${NC}"
    exit 1
fi

echo -e "${CYAN}Profilo:${NC} $PROFILE_FILE"
echo -e "${CYAN}Documenti:${NC} $DOCS_PATH"
echo -e "${CYAN}Modalità:${NC} $MODE"
echo ""

# Trova documenti da importare
declare -a DOCS_TO_IMPORT

case $MODE in
    --readme)
        DOCS_TO_IMPORT=($(find "$DOCS_PATH" -maxdepth 2 -name "README.md" 2>/dev/null))
        ;;
    --standards)
        DOCS_TO_IMPORT=($(find "$DOCS_PATH" -maxdepth 3 \( \
            -name "README.md" -o \
            -name "STANDARDS.md" -o \
            -name "CODING*.md" -o \
            -name "ARCHITECTURE*.md" -o \
            -name "STYLE*.md" -o \
            -name "CONTRIBUTING.md" -o \
            -name "GUIDELINES*.md" \
        \) 2>/dev/null))
        ;;
    --all)
        DOCS_TO_IMPORT=($(find "$DOCS_PATH" -maxdepth 3 -name "*.md" 2>/dev/null | head -20))
        ;;
    --summary)
        DOCS_TO_IMPORT=($(find "$DOCS_PATH" -maxdepth 3 -name "*.md" 2>/dev/null))
        ;;
esac

if [ ${#DOCS_TO_IMPORT[@]} -eq 0 ]; then
    echo -e "${YELLOW}Nessun documento trovato con modalità $MODE${NC}"
    exit 0
fi

echo -e "${CYAN}Documenti trovati: ${#DOCS_TO_IMPORT[@]}${NC}"
echo ""

# Mostra documenti trovati
echo -e "${BOLD}Documenti da importare:${NC}"
for doc in "${DOCS_TO_IMPORT[@]}"; do
    size=$(wc -c < "$doc" | tr -d ' ')
    echo "  - $(basename "$doc") (${size} bytes)"
done
echo ""

read -p "Procedere con l'importazione? (s/N): " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "Operazione annullata."
    exit 0
fi

# Aggiungi sezione al profilo
echo "" >> "$PROFILE_FILE"
echo "---" >> "$PROFILE_FILE"
echo "" >> "$PROFILE_FILE"
echo "## Contesto Importato da Documenti" >> "$PROFILE_FILE"
echo "" >> "$PROFILE_FILE"
echo "Data importazione: $(date '+%Y-%m-%d %H:%M')" >> "$PROFILE_FILE"
echo "Sorgente: \`$DOCS_PATH\`" >> "$PROFILE_FILE"
echo "" >> "$PROFILE_FILE"

# Importa ogni documento
for doc in "${DOCS_TO_IMPORT[@]}"; do
    doc_name=$(basename "$doc")
    doc_rel_path="${doc#$DOCS_PATH/}"

    echo "  Importando: $doc_name"

    echo "### Da: $doc_rel_path" >> "$PROFILE_FILE"
    echo "" >> "$PROFILE_FILE"

    if [ "$MODE" == "--summary" ]; then
        # Solo prima riga/titolo
        head -5 "$doc" >> "$PROFILE_FILE"
        echo "" >> "$PROFILE_FILE"
        echo "*[Sommario - vedi documento originale per dettagli]*" >> "$PROFILE_FILE"
    else
        # Estrai contenuto rilevante (max 2000 caratteri per doc)
        # Rimuovi frontmatter YAML se presente
        content=$(sed '/^---$/,/^---$/d' "$doc" | head -c 2000)
        echo "$content" >> "$PROFILE_FILE"

        # Aggiungi indicazione se troncato
        original_size=$(wc -c < "$doc" | tr -d ' ')
        if [ "$original_size" -gt 2000 ]; then
            echo "" >> "$PROFILE_FILE"
            echo "*[...contenuto troncato - originale: ${original_size} bytes]*" >> "$PROFILE_FILE"
        fi
    fi

    echo "" >> "$PROFILE_FILE"
done

echo ""
echo -e "${GREEN}Importazione completata!${NC}"
echo ""
echo -e "${CYAN}Profilo aggiornato:${NC} $PROFILE_FILE"
echo ""

# Mostra dimensione finale
final_size=$(wc -c < "$PROFILE_FILE" | tr -d ' ')
final_words=$(wc -w < "$PROFILE_FILE" | tr -d ' ')

echo -e "${CYAN}Statistiche profilo:${NC}"
echo "  Dimensione: ${final_size} bytes"
echo "  Parole: ${final_words}"

if [ "$final_words" -gt 4000 ]; then
    echo ""
    echo -e "${YELLOW}ATTENZIONE: Il profilo supera 4000 parole.${NC}"
    echo "Considera di ridurre il contenuto per migliori performance."
fi

echo ""
echo -e "${YELLOW}Prossimi passi:${NC}"
echo "  1. Rivedi il profilo: nano $PROFILE_FILE"
echo "  2. Installa: cp $PROFILE_FILE ~/.claude/profiles/"
echo "  3. Attiva: /profilo $PROFILE_CODE"
