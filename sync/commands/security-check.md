---
description: Esegui un quick security check sul codice corrente
---

# Security Quick Check

Esegui una rapida analisi di sicurezza sul codice o sulla configurazione attuale.

## Checklist da Verificare

### Input Validation
- [ ] Tutti gli input utente sono validati
- [ ] Whitelist validation dove possibile
- [ ] Sanitizzazione appropriata

### Authentication & Authorization
- [ ] Autenticazione robusta
- [ ] Authorization check su ogni operazione
- [ ] Session management sicuro

### Data Protection
- [ ] Dati sensibili criptati at rest
- [ ] TLS per dati in transito
- [ ] No secrets hardcoded

### Injection Prevention
- [ ] Prepared statements per SQL
- [ ] Output encoding per XSS
- [ ] Command injection prevention

### Configuration
- [ ] Default sicuri
- [ ] Error messages generici
- [ ] Logging appropriato

### Dependencies
- [ ] Dipendenze aggiornate
- [ ] No vulnerabilita' note (CVE)

---

Analizza il codice nel contesto attuale e segnala eventuali problemi di sicurezza con severity e remediation suggerita.
