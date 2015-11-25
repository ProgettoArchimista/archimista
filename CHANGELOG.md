## Archimista 2.0.0 (24 novembre 2015)

- Aggiornate le versioni di Ruby e Rails: Ruby 2.1.5 e Rails 4.2.1
- Report:
    possibilità di scegliere i campi da inserire per tutte le entità coinvolte
    possibilità di scegliere se inserire le etichette dei campi
    riorganizzazione delle informazioni presentate in ciascun report
    aggiunta la gestione dei dati relativi alle schede speciali
    ottimizzazione dei tempi di elaborazione per il formato RTF (per ora solo su "Inventario")

- Campo "Collegamenti"
    navigabilità del link (url) in modalità anteprima per tutte le entità in cui è previsto
    aggiunto anche in "Progetto" nel quale precedentemente non era visualizzato

- Relazioni
    le relazioni tra un'entità e le fonti sono ora gestibili in entrambe le direzioni (es. da complesso a fonti e viceversa da fonti a complesso)

## Archimista 1.2.1 (18 giugno 2013)

Correzione di bug. Vedi [dettaglio](https://github.com/codexcoop/archimista/compare/v1.2.0...v1.2.1)

## Archimista 1.2.0 (25 marzo 2013)

La nuova versione consolida e migliora le funzionalità dell'applicazione, con particolare riguardo a Oggetti digitali, Unità e Report. Si segnalano le novità principali.

### Oggetti digitali

- Funzionalità di upload multiplo di file per singolo record di entità (Unità archivistica, Soggetto produttore, ecc.)
- Funzionalità di riordino dei file mediante *drag and drop*
- Migliorata l'interfaccia utente

### Unità

- Possibilità di creare unità di terzo livello (sottosottounità)
- Possibilità di modificare il livello delle unità (trasformare unità in sottounità e viceversa, trasformare sottounità in sottosottounità e viceversa)
- Visualizzazione del numero di sequenza di sottounità e sottounità nella forma: 1.1, 1.1.1

### Report

- Migliorato il report *Inventario*
- Migliorato il report *Etichette unità*, con possibilità di esportazione in formato CSV / Excel per una completa personalizzazione mediante word processor
- Migliorato il report *Lista unità*, con possibilità di esportazione in formato CSV / Excel
- Aggiunto il report per *Soggetto conservatore*
- Aggiunto il report per *Progetto*

### Correzioni di bug

- Unità: in modalità tabella talvolta non era possibile digitare spazi nei campi testo e nelle caselle dei filtri. Riferimento: [http://www.archiviando.org/forum/viewtopic.php?f=65&t=1388](http://www.archiviando.org/forum/viewtopic.php?f=65&t=1388)
- Soggetti produttori: nella creazione di nuova scheda Persona non si visualizzavano i campi "Luogo di nascita" e "Luogo di morte"
- Varie correzioni minori

## Archimista 1.1.0 (22 giugno 2012)

- Migliorate le funzionalità di Esporta / Importa (in formato *aef*).
È ora possibile esportare e importare i dati non solo di singoli complessi archivistici, ma anche di insiemi di complessi archivistici collegati a un soggetto conservatore o a un progetto.
- Risolto il problema che azzerava il numero di sequenza delle unità nelle azioni di riordino (si verificava solo nella versione standalone). Riferimento: [http://www.archiviando.org/forum/viewtopic.php?f=65&t=1115](http://www.archiviando.org/forum/viewtopic.php?f=65&t=1115)
- Risolto il problema che impediva di "catturare" i nomi di compilatori nelle schede di altre entità (si verificava solo nella versione standalone)
- Modifiche minori del codice di programmazione e dell'interfaccia utente

## Archimista 1.0.0 (20 aprile 2012)

Rilascio iniziale
