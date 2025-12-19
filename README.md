# PRG0020_CLAUDEAI_PROFILO_EB

Strumenti per sincronizzare e gestire la configurazione di Claude Code tra postazioni Mac multiple.

## Struttura Progetto

```
PRG0020_CLAUDEAI_PROFILO_EB/
├── scripts/
│   ├── backup-claude-config.sh    # Backup completo configurazioni
│   ├── restore-claude-config.sh   # Restore da backup
│   ├── sync-config.sh             # Sincronizzazione tra postazioni
│   └── export-chats.py            # Export chat in Markdown
├── backups/                       # Backup locali
├── exports/                       # Chat esportate
├── sync/                          # Cartella sincronizzazione (da condividere)
└── docs/                          # Documentazione aggiuntiva
```

## Configurazione Claude Code

La configurazione di Claude Code si trova in `~/.claude/`:

| Directory/File | Contenuto | Sincronizzabile |
|----------------|-----------|-----------------|
| `profiles/` | Profili security (PRF01-PRF08) | Si |
| `commands/` | Slash commands personalizzati | Si |
| `hooks/` | Hook di automazione | Si |
| `settings.json` | Impostazioni globali | Si |
| `history.jsonl` | Indice cronologia comandi | Opzionale |
| `projects/` | Sessioni chat complete (.jsonl) | Opzionale |

## Quick Start

### 1. Setup iniziale (postazione principale)

```bash
cd ~/AI-WORKSPACE/projects/PRG0020_CLAUDEAI_PROFILO_EB

# Rendi eseguibili gli script
chmod +x scripts/*.sh

# Esegui primo backup
./scripts/backup-claude-config.sh

# Push nella cartella sync
./scripts/sync-config.sh push
```

### 2. Setup su nuova postazione

```bash
# Clona/copia questo progetto sulla nuova postazione
# Poi esegui il pull delle configurazioni

cd ~/AI-WORKSPACE/projects/PRG0020_CLAUDEAI_PROFILO_EB
chmod +x scripts/*.sh
./scripts/sync-config.sh pull
```

## Utilizzo Script

### Backup Completo

```bash
# Backup nella cartella default (./backups)
./scripts/backup-claude-config.sh

# Backup in cartella specifica
./scripts/backup-claude-config.sh /path/to/backup/dir
```

### Restore da Backup

```bash
./scripts/restore-claude-config.sh ./backups/claude-config-20251219_120000
```

### Sincronizzazione tra Postazioni

```bash
# Mostra stato attuale
./scripts/sync-config.sh status

# Carica configurazioni locali (da postazione principale)
./scripts/sync-config.sh push

# Scarica configurazioni (su altre postazioni)
./scripts/sync-config.sh pull

# Mostra differenze
./scripts/sync-config.sh diff
```

### Export Chat

```bash
# Lista sessioni disponibili
python3 scripts/export-chats.py --list

# Esporta indice cronologia
python3 scripts/export-chats.py --history

# Esporta una sessione specifica
python3 scripts/export-chats.py -s <session-id>

# Esporta tutte le sessioni
python3 scripts/export-chats.py --all

# Output in cartella specifica
python3 scripts/export-chats.py --all -o ./exports
```

## Archiviazione Chat

Le chat di Claude Code sono salvate in formato JSONL in `~/.claude/projects/`.

**Formato dei file:**
- `history.jsonl` - Indice dei comandi utente (input)
- `projects/<project-path>/<session-id>.jsonl` - Sessioni complete

**Opzioni per archiviare le chat:**

1. **Export Markdown** (consigliato per lettura)
   ```bash
   python3 scripts/export-chats.py --all -o ./exports
   ```

2. **Backup raw JSONL** (per restore completo)
   ```bash
   ./scripts/backup-claude-config.sh
   ```

3. **Sincronizzazione cloud** - Metti la cartella `sync/` su iCloud/Dropbox/Google Drive

## Sincronizzazione Multi-Postazione

### Metodo 1: Cartella Cloud Condivisa

1. Metti questo progetto in una cartella sincronizzata (iCloud, Dropbox, etc.)
2. Su ogni postazione, esegui:
   ```bash
   # Imposta variabile ambiente (aggiungi a .zshrc)
   export CLAUDE_SYNC_DIR="$HOME/path/to/PRG0020_CLAUDEAI_PROFILO_EB/sync"
   ```
3. Usa `sync-config.sh push/pull` per sincronizzare

### Metodo 2: Git Repository

1. Inizializza git in questo progetto
2. Aggiungi la cartella `sync/` al repo
3. Push/pull su ogni postazione

### Metodo 3: Backup Manuale

1. Esegui backup su postazione principale
2. Copia la cartella backup sulla nuova postazione
3. Esegui restore

## Note Importanti

- **Riavvia Claude Code** dopo ogni restore/pull per applicare le modifiche
- Le **sessioni chat** contengono dati sensibili - gestiscile con cura
- I **profili security** sono personalizzati per il tuo workflow
- Gli **hook** potrebbero richiedere adattamenti per path diversi

## Struttura ~/.claude

```
~/.claude/
├── profiles/                 # Profili security
│   ├── PRF01-penetration-testing.md
│   ├── PRF02-red-team.md
│   └── ...
├── commands/                 # Slash commands
│   ├── profilo.md
│   ├── profili.md
│   └── security-check.md
├── hooks/                    # Hook automazione
│   └── profile-selector.sh
├── settings.json             # Configurazioni
├── history.jsonl             # Cronologia comandi
└── projects/                 # Sessioni chat
    └── <project-path>/
        └── <session-id>.jsonl
```

## Troubleshooting

**Le configurazioni non si applicano dopo il restore**
- Chiudi e riapri Claude Code

**Errore permessi sugli script**
- Esegui: `chmod +x scripts/*.sh`

**Directory sync non trovata**
- Imposta `CLAUDE_SYNC_DIR` o usa il path default

---

Autore: Eliseo Bosco
Progetto: PRG0020_CLAUDEAI_PROFILO_EB
