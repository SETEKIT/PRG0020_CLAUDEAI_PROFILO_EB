#!/bin/zsh
# Claude Code - Security Profile Selector
# Questo script viene eseguito all'avvio di ogni sessione Claude Code

set -e

PROFILES_DIR="$HOME/.claude/profiles"
PROFILE_CACHE="$HOME/.claude/.last-profile"

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

# Recupera ultimo profilo usato
LAST_PROFILE=""
if [[ -f "$PROFILE_CACHE" ]]; then
  LAST_PROFILE=$(cat "$PROFILE_CACHE" 2>/dev/null || echo "")
fi

# Funzione per ottenere codice e nome profilo da numero
get_profile_code() {
  case $1 in
    1) echo "PRF01" ;;
    2) echo "PRF02" ;;
    3) echo "PRF03" ;;
    4) echo "PRF04" ;;
    5) echo "PRF05" ;;
    6) echo "PRF06" ;;
    7) echo "PRF07" ;;
    8) echo "PRF08" ;;
    *) echo "" ;;
  esac
}

get_profile_name() {
  case $1 in
    1|PRF01) echo "penetration-testing" ;;
    2|PRF02) echo "red-team" ;;
    3|PRF03) echo "threat-intelligence" ;;
    4|PRF04) echo "incident-response" ;;
    5|PRF05) echo "blue-team" ;;
    6|PRF06) echo "compliance-audit" ;;
    7|PRF07) echo "secure-development" ;;
    8|PRF08) echo "general" ;;
    *) echo "" ;;
  esac
}

get_profile_display() {
  case $1 in
    1|PRF01) echo "Penetration Testing" ;;
    2|PRF02) echo "Red Team Operations" ;;
    3|PRF03) echo "Threat Intelligence" ;;
    4|PRF04) echo "Incident Response" ;;
    5|PRF05) echo "Blue Team Defense" ;;
    6|PRF06) echo "Compliance & Audit" ;;
    7|PRF07) echo "Secure Development" ;;
    8|PRF08) echo "General Purpose" ;;
    *) echo "" ;;
  esac
}

# Mostra menu se interattivo
if [[ -t 0 ]]; then
  echo ""
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}${CYAN}║           CLAUDE CODE - SECURITY ANALYSIS PLATFORM               ║${NC}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
  echo ""

  if [[ -n "$LAST_PROFILE" ]]; then
    last_display=$(get_profile_display "$LAST_PROFILE")
    echo -e "${YELLOW}  Ultimo profilo: ${BOLD}$LAST_PROFILE - $last_display${NC} ${YELLOW}(premi 0)${NC}"
    echo ""
  fi

  echo -e "${BOLD}  OFFENSIVE SECURITY${NC}"
  echo -e "  ${GREEN}1.${NC} PRF01 - Penetration Testing    Vulnerability assessment, OWASP, PTES"
  echo -e "  ${GREEN}2.${NC} PRF02 - Red Team Operations    Adversary simulation, MITRE ATT&CK"
  echo ""
  echo -e "${BOLD}  DEFENSIVE SECURITY${NC}"
  echo -e "  ${BLUE}3.${NC} PRF03 - Threat Intelligence    Threat analysis, IOC hunting, APT"
  echo -e "  ${BLUE}4.${NC} PRF04 - Incident Response      IR handling, forensics, containment"
  echo -e "  ${BLUE}5.${NC} PRF05 - Blue Team Defense      Detection, threat hunting, SIEM"
  echo ""
  echo -e "${BOLD}  GOVERNANCE & DEVELOPMENT${NC}"
  echo -e "  ${CYAN}6.${NC} PRF06 - Compliance & Audit     ISO 27001, SOC 2, GDPR, NIST CSF"
  echo -e "  ${CYAN}7.${NC} PRF07 - Secure Development     Secure coding, SAST/DAST, DevSecOps"
  echo ""
  echo -e "${BOLD}  ALTRO${NC}"
  echo -e "  ${NC}8.${NC} PRF08 - General Purpose        Sviluppo generale"
  echo ""
  echo -e "────────────────────────────────────────────────────────────────────"

  read "selection?  Seleziona profilo (1-8 o 0 per ultimo): "

  if [[ "$selection" == "0" ]] && [[ -n "$LAST_PROFILE" ]]; then
    profile_code="$LAST_PROFILE"
  else
    profile_code=$(get_profile_code "$selection")
    if [[ -z "$profile_code" ]]; then
      echo -e "${RED}  Selezione non valida. Uso PRF08 - General Purpose.${NC}"
      profile_code="PRF08"
    fi
  fi

  profile_name=$(get_profile_name "$profile_code")
  profile_display=$(get_profile_display "$profile_code")

  echo ""
  echo -e "${GREEN}  ✓ Profilo caricato: ${BOLD}$profile_code - $profile_display${NC}"
  echo ""
else
  # Modalita' non interattiva: usa ultimo profilo o default
  if [[ -n "$LAST_PROFILE" ]]; then
    profile_code="$LAST_PROFILE"
  else
    profile_code="PRF08"
  fi
  profile_name=$(get_profile_name "$profile_code")
fi

# Salva scelta profilo (salva il codice)
echo "$profile_code" > "$PROFILE_CACHE" 2>/dev/null || true

# Esporta variabile ambiente se disponibile
if [[ -n "$CLAUDE_ENV_FILE" ]]; then
  echo "export SECURITY_PROFILE=$profile_code" >> "$CLAUDE_ENV_FILE"
  echo "export SECURITY_PROFILE_NAME=$profile_name" >> "$CLAUDE_ENV_FILE"

  # Carica env specifico del profilo se esiste
  if [[ -f "$PROFILES_DIR/$profile_code-$profile_name.env" ]]; then
    cat "$PROFILES_DIR/$profile_code-$profile_name.env" >> "$CLAUDE_ENV_FILE"
  fi
fi

exit 0
