# PRG0020 - Claude Code Config Sync

Sincronizzazione configurazioni Claude Code tra postazioni Mac.

## Struttura

```
PRG0020_CLAUDEAI_PROFILO_EB/
├── claude-config/           # Configurazioni sincronizzate
│   ├── profiles/           # Profili sicurezza (PRF01-PRF08)
│   ├── commands/           # Slash commands
│   ├── hooks/              # Scripts hook
│   └── settings.json       # Impostazioni Claude
├── scripts/
│   ├── install.sh          # Setup nuovo Mac
│   ├── sync-push.sh        # Local → Repository
│   ├── sync-pull.sh        # Repository → Local
│   ├── backup.sh           # Backup completo
│   └── export-chats.py     # Export chat in Markdown
├── backups/                # Backup locali
└── README.md
```

## Quick Start

### Setup Nuovo Mac

```bash
# 1. Clona il repository
cd ~
git clone https://github.com/SETEKIT/PRG0020_CLAUDEAI_PROFILO_EB.git

# 2. Installa configurazioni
cd PRG0020_CLAUDEAI_PROFILO_EB
./scripts/install.sh

# 3. Riavvia Claude Code
```

### Sincronizzazione Giornaliera

**Dal Mac principale (dopo modifiche):**
```bash
cd ~/PRG0020_CLAUDEAI_PROFILO_EB
./scripts/sync-push.sh
git add -A && git commit -m "sync: $(date '+%Y-%m-%d')" && git push
```

**Su altri Mac:**
```bash
cd ~/PRG0020_CLAUDEAI_PROFILO_EB
git pull
./scripts/sync-pull.sh
```

## Scripts

| Script | Descrizione |
|--------|-------------|
| `install.sh` | Prima installazione su nuovo Mac |
| `sync-push.sh` | Copia config locali → repository |
| `sync-pull.sh` | Copia config repository → locali |
| `backup.sh` | Crea backup completo in `backups/` |
| `export-chats.py` | Esporta chat in formato Markdown |

## Profili Disponibili

| Codice | Nome | Uso |
|--------|------|-----|
| PRF01 | Penetration Testing | Test di sicurezza autorizzati |
| PRF02 | Red Team | Simulazione attacchi |
| PRF03 | Threat Intelligence | Analisi minacce |
| PRF04 | Incident Response | Gestione incidenti |
| PRF05 | Blue Team | Difesa e monitoraggio |
| PRF06 | Compliance Audit | Audit conformità |
| PRF07 | Secure Development | Sviluppo sicuro |
| PRF08 | General | Uso generale |

## Slash Commands

```
/profili          # Lista profili disponibili
/profilo PRF01    # Carica profilo specifico
/security-check   # Quick security check
```

## Configurazioni Sincronizzate

- `~/.claude/profiles/` - Profili di sicurezza
- `~/.claude/commands/` - Comandi slash personalizzati
- `~/.claude/hooks/` - Hook di automazione
- `~/.claude/settings.json` - Impostazioni

## Export Chat

```bash
# Lista sessioni disponibili
./scripts/export-chats.py --list

# Esporta tutte le sessioni
./scripts/export-chats.py --all -o ./exports

# Esporta sessione specifica
./scripts/export-chats.py --session <session-id>
```

## Note

- Dopo sync-pull, riavviare Claude Code per applicare le modifiche
- I backup vengono salvati in `backups/` con timestamp
- Il file `.sync-metadata.json` traccia l'ultimo push

---
Autore: Eliseo Bosco
