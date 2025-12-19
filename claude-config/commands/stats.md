# Statistiche Utilizzo Claude AI

Analizza e mostra le statistiche di utilizzo di Claude Code.

## Istruzioni

Esegui i seguenti controlli e presenta un report dettagliato:

### 1. Costo Sessione Corrente
Usa il comando interno per mostrare i costi della sessione attuale.

### 2. Statistiche Locali
Leggi e analizza il file `~/.claude/stats-cache.json` se esiste, mostrando:
- Numero totale di sessioni
- Token totali utilizzati (input/output)
- Costo stimato totale

### 3. Cronologia Utilizzo
Analizza `~/.claude/history.jsonl` per mostrare:
- Numero di conversazioni negli ultimi 7 giorni
- Numero di conversazioni negli ultimi 30 giorni
- Progetti più utilizzati

### 4. Formato Report

Presenta le statistiche in questo formato:

```
╔══════════════════════════════════════════════════════════════╗
║           STATISTICHE UTILIZZO CLAUDE AI                     ║
╠══════════════════════════════════════════════════════════════╣
║ SESSIONE CORRENTE                                            ║
║   Token Input:      [numero]                                 ║
║   Token Output:     [numero]                                 ║
║   Costo Sessione:   $[costo] (~€[costo_eur])                ║
╠══════════════════════════════════════════════════════════════╣
║ STORICO (se disponibile)                                     ║
║   Sessioni Totali:  [numero]                                 ║
║   Ultimi 7 giorni:  [numero] conversazioni                   ║
║   Ultimi 30 giorni: [numero] conversazioni                   ║
╠══════════════════════════════════════════════════════════════╣
║ PROGETTI PIÙ ATTIVI                                          ║
║   1. [nome_progetto] - [n] sessioni                         ║
║   2. [nome_progetto] - [n] sessioni                         ║
║   3. [nome_progetto] - [n] sessioni                         ║
╠══════════════════════════════════════════════════════════════╣
║ CREDITO DISPONIBILE                                          ║
║   Verifica su: https://console.anthropic.com/settings/plans  ║
║   (Il credito non è accessibile via API locale)              ║
╚══════════════════════════════════════════════════════════════╝
```

### 5. Conversione Valuta
- Usa tasso di cambio approssimativo: 1 USD = 0.92 EUR
- Mostra sempre entrambe le valute

### 6. Prezzi di Riferimento Claude (Dicembre 2024)

| Modello | Input (1M tokens) | Output (1M tokens) |
|---------|-------------------|-------------------|
| Claude 3.5 Sonnet | $3.00 | $15.00 |
| Claude 3.5 Haiku | $0.80 | $4.00 |
| Claude 3 Opus | $15.00 | $75.00 |

### 7. Link Utili
Alla fine del report, mostra:
- Console Anthropic: https://console.anthropic.com
- Usage Dashboard: https://console.anthropic.com/settings/usage
- Billing: https://console.anthropic.com/settings/plans
