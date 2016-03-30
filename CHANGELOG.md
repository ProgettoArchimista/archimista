## Archimista 2.1.0 (25 marzo 2016)

- Scheda progetto
    modificato vocabolario controllato del campo Identificazione/Tipologia di intervento
    modificato vocabolario controllato del campo Identificazione/Status
    modificato vocabolario controllato del campo Responsabilità/Responsabili/Qualifica
    modificato vocabolario controllato del campo Responsabilità/Soggetti coinvolti/Qualifica
    aggiornata la struttura di database che adesso prevede due tabelle distinte per i "Responsabili" (project_managers) e i "Soggetti coinvolti" (project_stakeholders)
    nella procedura di migrazione della banca dati contestuale all'installazione della nuova versione viene gestito il corretto passaggio dei dati pregressi alle due nuove tabelle

- Modifiche per gestione "multisito"
    modificate le informazioni descrittive dei gruppi in modo da potervi associare dati (nome sotto-sito, descrizione del gruppo, credits) e immagini (carousel, loghi) che vengono utilizzati per la pubblicazione tramite ArchiVista

- Schede speciali
    la logica di gestione delle schede speciali è stata cambiata in modo che siano delle estensioni di schede unità di tipo "unità documentaria". Le relative informazioni aggiuntive previste per ciascuna tipologia di scheda speciale si rendono disponibili per la compilazione se l'operatore imposta un valore per il campo "Unità/Scheda speciale" che a sua volta è disponibile solo se il campo Tipologia è impostato su "Unità documentaria"
    sono state ridefinite le categorie di schede scpeciali esistenti (CARS - Cartografia Storica, D - Disegno artistico, DT - Disegno tecnico, F - Fotografia, S - Stampe). Le tipologie OA e BDM sono state eliminate
    nella procedura di migrazione della banca dati contestuale all'installazione della nuova versione viene gestito ll recupero dei dati pregressi per mapparli nei nuvi campi previsti. Le informazioni che non sono più previste dalla nuova versione delle schede così come i contenuti delle vecchie schede speciali di tipo OA e BDM vengono recuperati nel campo "Unità/descrizione estrinseca"
 
- Unità
  modificata la funzione di ordinamento delle unità in modo che sia possibile richiedere l'ordinamento anche di tutte le unità contenute nei complessi archivistici discendenti dal complesso archivistico corrente

- Correzione di errori
  Lemmi
  Corretto errore nella pagina di presentazione dei lemmi (Indici) che impediva di aprire l'unità associata ad un determinato lemma
  Corretto errore che impediva di creare una relazione nuova tra scheda unità e lemma nuovo (direttamente da scheda unità)
  Modificato il funzionamento del pannello modale per l'impostazione di una relazione nuova tra scheda unità e lemma esistente. Prima presentava una lista comprendente al max 20 elementi, adesso invece è stato rimosso questo limite: si ritornano tutti i lemmi che soddisfano l'eventuale criterio di filtro impostato con il campo "Cerca un lemma".
  Modificata l'interfaccia che nel pannello dell'unità mostra le relazioni con i lemmi. E' stato dato più spazio alla lista e sono stati ridotti i padding dei div contenuti nella parte destra dell'interfaccia (file app\views\shared\_side.html.erb).
  Corretto errore in importazione lemmi da CSV
  
  Controllo qualità
  Corretto errore nella funzione "Controllo qualità" che ne impediva l'esecuzione.

  Report
  corretto errore nella produzione dei report in formato PDF nella versione standalone


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
