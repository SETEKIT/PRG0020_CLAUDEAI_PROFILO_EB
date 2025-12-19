# Analisi Convenienza Piano Claude

Analizza il tuo utilizzo e suggerisce il piano più conveniente tra Pro, Max 5x e Max 20x.

## Istruzioni

Esegui lo script di analisi:

```bash
~/PRG0020_CLAUDEAI_PROFILO_EB/scripts/analizza-piano.sh
```

Poi presenta i risultati con una raccomandazione chiara su quale piano conviene in base all'utilizzo rilevato.

## Piani Disponibili

| Piano | Costo Mese | Costo Anno | Limiti |
|-------|------------|------------|--------|
| Pro | $20 (~€18) | $240 (~€220) | Base |
| Max 5x | $100 (~€92) | $1200 (~€1100) | 5x Pro |
| Max 20x | $200 (~€184) | $2400 (~€2200) | 20x Pro |

## Criteri Valutazione

- **Pro sufficiente**: < 500 interazioni/mese, blocchi rari
- **Max 5x consigliato**: 500-1500 interazioni/mese, blocchi settimanali
- **Max 20x consigliato**: > 1500 interazioni/mese, blocchi giornalieri

## Output Atteso

Mostra:
1. Statistiche utilizzo attuale
2. Proiezione mensile
3. Confronto piani con costi in EUR
4. Raccomandazione chiara con motivazione
