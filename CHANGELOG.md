## Archimista 3.0.0 (23 dicembre 2016)
Nuove funzionalità
- Ogni item delle entità Complesso archivistico (di 1° livello), Produttore, Conservatore e Progetto mostra il gruppo di appartenenza che ha generato il dato.
- Aggiunto flag "Pubblicato" per le entità Complesso archivistico (a ogni livello), Progetto, Soggetto Produttore, Soggetto Conservatore, Unità e Oggetto Digitale e link alle azioni "Pubblica/Rimuovi pubblicazione" negli elenchi di visualizzazione
  di Complessi archivistici e Progetti. Le suddette azioni agiscono a cascata su tutte le istanze di entità collegate mentre il check/uncheck della flag singola agisce puntualmente sull'entità selezionata.
- Esportazione/Importazione di Oggetti digitali associati ai corredi in formato aef.
- Aggiunto tool di controllo e bonifica delle occorrenze multiple delle schede Fonti in Strumenti/Occorrenze Multiple. Nel caso di più istanze duplicate, la selezione della fonte corretta da mantenere elimina tutti i duplicati e fa ereditare tutte le relazioni relative alle istanze eliminate.
- Modificata la funzione "Unisci a" per un Complesso archivistico: è possibile effettuare l'unione su un qualsiasi livello gerarchico anzichè sul 1° come in precedenza.
- Aggiunta la funzione "Dividi" per un Complesso archivistico: è possibile dividere un qualsiasi livello gerarchico di un Complesso archivistico dal Complesso di primo livello di appartenenza creando un nuovo Complesso archivistico di 1° livello.
- Le entità Profili documentari e Profili istituzionali saranno modificabili esclusivamente a cura degli operatori di profilo admin.
- Aggiunto filtro Schede speciali in modalità visione tabellare per le unità.

## Archimista 2.2.0 (22 settembre 2016)

Correzione errori:
- corretto errore che si manifestava nel form indice dei soggetti produttori. Il comando "Nuova scheda" presentava la lista con l'opzione "F - Fotografia" invece che "Famiglia". Sono state aggiornate le traduzioni dei termini nel file "config\locales\views\units.yml" aggiungendo il livello "units_sc2_tsk" per fare in modo che le traduzioni dei valori del campo units.sc2_tsk non interferiscano con il resto. Cambiati coerentemente i form di visualizzazione delle unità (app\views\units\_form.html.erb, app\views\units\show.html.erb)
- è stata aggiunta una migrazione del database per correggere la gestione dei valori del vocabolario di units.sc2_tsk
- nella pagina che mostra le unità collegate ad un indice corretto errore che in presenta di unità di livelli maggiori del primo le mostrava con una caption non corretta (la caption era preceduta da "&mdash;" invece che dal corrispondente carattere)
- corretto errore nella procedura di recupero dei dati delle unità speciali (vedi lib\sc2_restore.rb) che non recuperava correttamente i dati di MISA e MISL delle schede OA, BDM
- corretta funzione di export e import da aef (app\models\export.rb, app\models\import.rb): i campi delle schede speciali non venivano esportati ed importati
- per questa correzione è stata creata una migrazione (20160401000000_sc2_add_legacy_current_id_field.rb) che aggiunge un nuovo campo (legacy_current_id) alle tabelle sc2_authors e sc2_commissions
- rigenerati i file db\seeds\*.json utilizzati per creare un database nuovo con la procedura "rake db:setup". Oltre ad aggiungere i file .json corrispondenti alle modifiche alla struttura di database introdotte dalla versione 2.1.0 in avanti, sono stati corretti alcuni errori nei contenuti dei file già esistenti, che non corrispondevano più alla struttura del database. In particolare tra questi è stata attuata la segnalazione evidenziata in https://github.com/ProgettoArchimista/archimista/pull/2 e relativa alla tabella groups.
- sono state aggiornate anche le procedure rake lib\tasks\db.rake che oltre a non prevedere i dati di seeding per i modelli introdotti dalla 2.1.0 in avanti, avevano qualche errore nel codice legato all'utilizzo delle nuove versioni ruby/rail introdotte con la versione 2.0.0

Nuove funzionalità
- gestione di profili utente associati a più di un gruppo con possibilità per questi utenti di visionare/modificare i dati appartenenti a più gruppi
- nel report inventario aggiunta la gestione dei campi con ripetitività doppia (es. schede speciali CARS: "Motivo dell'attribuzione" dell'autore e "Nome" nella committenza). In precedenza non erano gestiti. (lib\report_support.rb)
- In Bacheca>ComplessiArchivistici>Elenco visualizzato anche l'elenco dei progetti collegati
- In Bacheca>SoggettiProduttori>Elenco visualizzato anche l'elenco dei progetti collegati
- In Bacheca>Progetti>Elenco visualizzato anche Tipologia dell'intervento, Responsabili (tutti e anche i soggetti coinvolti), Status
- In Bacheca>Progetti>Elenco possibilità di ricerca per Denominazione, Tipologia dell'intervento, Status
- Aggiunto campo consistenza nelle unità (extent) dopo Descrizione>Contenuto. Aggiornati report, anteprima unità, editing in formato tabella
- modificata la gestione dei report per correggere una segnalazione del 22/06/2016: "nei report il titolo viene sempre scritto, quindi selezionandolo come campo da scrivere viene scritto due volte". La soluzione adottata è stata di togliere il campo titolo dai campi di default delle unità, e di aggiungere nell'elenco dei campi una indicazione del fatto che il titolo delle unità compare sempre anche se non è selezionato.
- aggiunto pannello di opzioni nel form di editing delle unità per permettere di impostare etichette alternative per i prefissi utilizzati per comporre il valore del campo "Segnatura definitiva" come concatenazione dei campi "Busta", "Fascicolo".
- esportazione/importazione unità in formato .aef.
- nella visualizzazione delle unità di un complesso aggiunta la possibilità di selezionare solo le unità del complesso di primo livello e la possibilità di non effettuare la paginazione dei risultati per poter selezionare tutte le unità di un complesso.
- nella visualizzazione elenco di produttori, conservatori, complessi, indici, progetti, fonti e unità il filtro è stato reso sempre visibile indipendentemente dal numero di risultati
- modificato il nome del file prodotto con l'esportazione in formato aef in modo che contenga l'indicazione dell'entità di riferimento che è stata esportata (Es.: archimista-export_complesso-20160921182205.aef)


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
