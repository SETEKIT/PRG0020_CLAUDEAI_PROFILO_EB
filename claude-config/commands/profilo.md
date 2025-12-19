---
description: Carica un profilo di sicurezza (usa codice PRFxx o nome)
argument-hint: <PRFxx|nome-profilo>
allowed-tools: Read
---

# Caricamento Profilo Security

Carica il profilo di sicurezza: **$ARGUMENTS**

## Profili Disponibili

| Codice | Nome | Descrizione |
|--------|------|-------------|
| PRF01 | penetration-testing | Vulnerability assessment, exploit analysis |
| PRF02 | red-team | Adversary simulation, stealth attacks |
| PRF03 | threat-intelligence | Threat analysis, IOC hunting |
| PRF04 | incident-response | IR handling, forensics |
| PRF05 | blue-team | Detection engineering, threat hunting |
| PRF06 | compliance-audit | ISO 27001, SOC 2, GDPR, NIST |
| PRF07 | secure-development | Secure coding, DevSecOps |
| PRF08 | general | Sviluppo generale |

## Istruzioni

Determina quale profilo caricare dall'argomento fornito ($ARGUMENTS):
- Se e' un codice (PRF01-PRF08), usa quello
- Se e' un nome (penetration-testing, red-team, etc.), mappa al codice corrispondente

Poi leggi il file di profilo corrispondente da: /Users/eliseobosco/.claude/profiles/

I file sono nominati: PRFxx-nome.md (es: PRF01-penetration-testing.md)

Dopo aver letto il profilo, conferma con:
1. Codice e nome del profilo caricato
2. Breve riassunto del contesto operativo
