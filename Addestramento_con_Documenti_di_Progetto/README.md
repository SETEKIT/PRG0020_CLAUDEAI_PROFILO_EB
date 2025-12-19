# Addestramento Profili con Documenti di Progetto

Guida completa per creare profili Claude Code personalizzati basati sui documenti dei tuoi progetti.

## Concetti Chiave

### Cos'è un Profilo?
Un profilo è un file Markdown che definisce:
- **Ruolo**: Chi è Claude in questo contesto
- **Competenze**: Cosa sa fare
- **Contesto**: Informazioni dal progetto
- **Linee Guida**: Come deve comportarsi
- **Esempi**: Risposte/comportamenti attesi

### Perché Addestrare con Documenti?
- **Consistenza**: Risposte uniformi su tutti i progetti
- **Contesto**: Claude conosce le convenzioni aziendali
- **Efficienza**: Non devi ripetere le stesse istruzioni
- **Qualità**: Output allineato agli standard

## Struttura Cartella

```
Addestramento_con_Documenti_di_Progetto/
├── README.md                    # Questa guida
├── templates/
│   ├── profilo-base.md         # Template profilo vuoto
│   ├── profilo-sviluppo.md     # Template per sviluppo
│   └── profilo-documentazione.md
├── esempi/
│   └── PRF999-esempio.md       # Profilo di esempio completo
├── docs/
│   └── guida-estrazione.md     # Come estrarre info dai documenti
└── scripts/
    ├── crea-profilo.sh         # Wizard creazione profilo
    ├── importa-documenti.sh    # Importa docs in profilo
    └── valida-profilo.sh       # Verifica profilo
```

## Quick Start

### 1. Crea un Nuovo Profilo
```bash
./scripts/crea-profilo.sh
```

### 2. Importa Documenti di Progetto
```bash
./scripts/importa-documenti.sh PRF999 /path/to/progetto/docs/
```

### 3. Installa il Profilo
```bash
cp esempi/PRF999-esempio.md ~/.claude/profiles/
```

### 4. Attiva il Profilo
```
/profilo PRF999
```

## Workflow Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                    ADDESTRAMENTO PROFILO                        │
└─────────────────────────────────────────────────────────────────┘

   ┌──────────────┐
   │ 1. RACCOGLI  │
   │  Documenti   │
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐     Cosa estrarre:
   │ 2. ESTRAI    │     - Standard codifica
   │  Contenuti   │────▶ - Architettura
   └──────┬───────┘     - Convenzioni naming
          │             - Template risposte
          ▼
   ┌──────────────┐
   │ 3. STRUTTURA │     Organizza in sezioni:
   │  Profilo     │────▶ Ruolo, Competenze, Contesto
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │ 4. VALIDA    │     Test con casi reali
   │  e Testa     │
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │ 5. INSTALLA  │     ~/.claude/profiles/
   │  e Sincronizza│
   └──────────────┘
```

## Tipi di Documenti da Includere

| Tipo Documento | Sezione Profilo | Esempio |
|----------------|-----------------|---------|
| Coding Standards | Linee Guida | "Usa camelCase per variabili" |
| Architecture Docs | Contesto Tecnico | "Backend: FastAPI + PostgreSQL" |
| Style Guide | Formato Output | "Commenti in italiano" |
| API Docs | Riferimenti | "Endpoint base: /api/v1/" |
| Templates | Esempi | Template email, commit msg |
| Glossario | Terminologia | Termini specifici azienda |

## Best Practices

### DO ✓
- Estrai solo informazioni rilevanti
- Usa esempi concreti
- Mantieni il profilo aggiornato
- Testa prima di deployare

### DON'T ✗
- Non includere dati sensibili (password, chiavi API)
- Non copiare documenti interi
- Non creare profili troppo lunghi (max ~4000 parole)
- Non duplicare informazioni

## Limiti e Considerazioni

- **Dimensione**: Profili troppo grandi riducono il contesto disponibile
- **Aggiornamenti**: Sincronizza quando cambiano i documenti sorgente
- **Specificità**: Meglio più profili specifici che uno generico

---
Autore: Eliseo Bosco
