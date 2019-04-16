## Archimista 3.0 e 3.1 versione server e stand alone – gennaio 2019
* Sviluppo del fascicolo edilizio secondo il modello presentato e dopo analisi con l’ICAR; 
* Integrazione con la procedura di esportazione/importazione aef; 
* Integrazione con la procedura di esportazione/importazione EAD3/EAC; 
* Integrazione con la procedura di esportazione CAT-SAN/METS SAN; 
* Integrazione con la procedura di batch esportazione/importazione aef comprensiva degli oggetti digitali;. 
* Procedura batch di caricamento multiplo di documenti digitali (jpg e pdf) ad una unità utilizzando una nomenclatura specifica o una piccola struttura in json o in xml; 

## Archimista 2.2.0 - 22 settembre 2016
* Correzione errori:
  * corretto errore che si manifestava nel form indice dei soggetti produttori. Il comando "Nuova scheda" presentava la lista con l'opzione "F - Fotografia" invece che "Famiglia". Sono state aggiornate le traduzioni dei termini nel file "config\locales\views\units.yml" aggiungendo il livello "units_sc2_tsk" per fare in modo che le traduzioni dei valori del campo units.sc2_tsk non interferiscano con il resto. Cambiati coerentemente i form di visualizzazione delle unità (app\views\units\_form.html.erb, app\views\units\show.html.erb)
  * è stata aggiunta una migrazione del database per correggere la gestione dei valori del vocabolario di units.sc2_tsk
  * nella pagina che mostra le unità collegate ad un indice corretto errore che in presenta di unità di livelli maggiori del primo le mostrava con una caption non corretta (la caption era preceduta da "&mdash;" invece che dal corrispondente carattere)
  * corretto errore nella procedura di recupero dei dati delle unità speciali (vedi lib\sc2_restore.rb) che non recuperava correttamente i dati di MISA e MISL delle schede OA, BDM
  * corretta funzione di export e import da aef (app\models\export.rb, app\models\import.rb): i campi delle schede speciali non venivano esportati ed importati
  * per questa correzione è stata creata una migrazione (20160401000000_sc2_add_legacy_current_id_field.rb) che aggiunge un nuovo campo (legacy_current_id) alle tabelle sc2_authors e sc2_commissions
  * rigenerati i file db\seeds\*.json utilizzati per creare un database nuovo con la procedura "rake db:setup". Oltre ad aggiungere i file .json corrispondenti alle modifiche alla struttura di database introdotte dalla versione 2.1.0 in avanti, sono stati corretti alcuni errori nei contenuti dei file già esistenti, che non corrispondevano più alla struttura del database. In particolare tra questi è stata attuata la segnalazione evidenziata in https://github.com/ProgettoArchimista/archimista/pull/2 e relativa alla tabella groups.
  * sono state aggiornate anche le procedure rake lib\tasks\db.rake che oltre a non prevedere i dati di seeding per i modelli introdotti dalla 2.1.0 in avanti, avevano qualche errore nel codice legato all'utilizzo delle nuove versioni ruby/rail introdotte con la versione 2.0.0
* Nuove funzionalità:
  * gestione di profili utente associati a più di un gruppo con possibilità per questi utenti di visionare/modificare i dati appartenenti a più gruppi
  * nel report inventario aggiunta la gestione dei campi con ripetitività doppia (es. schede speciali CARS: "Motivo dell'attribuzione" dell'autore e "Nome" nella committenza). In precedenza non erano gestiti. (lib\report_support.rb)
  * In Bacheca>ComplessiArchivistici>Elenco visualizzato anche l'elenco dei progetti collegati
  * In Bacheca>SoggettiProduttori>Elenco visualizzato anche l'elenco dei progetti collegati
  * In Bacheca>Progetti>Elenco visualizzato anche Tipologia dell'intervento, Responsabili (tutti e anche i soggetti coinvolti), Status
  * In Bacheca>Progetti>Elenco possibilità di ricerca per Denominazione, Tipologia dell'intervento, Status
  * Aggiunto campo consistenza nelle unità (extent) dopo Descrizione>Contenuto. Aggiornati report, anteprima unità, editing in formato tabella
  * modificata la gestione dei report per correggere una segnalazione del 22/06/2016: "nei report il titolo viene sempre scritto, quindi selezionandolo come campo da scrivere viene scritto due volte". La soluzione adottata è stata di togliere il campo titolo dai campi di default delle unità, e di aggiungere nell'elenco dei campi una indicazione del fatto che il titolo delle unità compare sempre anche se non è selezionato.
  * aggiunto pannello di opzioni nel form di editing delle unità per permettere di impostare etichette alternative per i prefissi utilizzati per comporre il valore del campo "Segnatura definitiva" come concatenazione dei campi "Busta", "Fascicolo".
  * esportazione/importazione unità in formato .aef.
  * nella visualizzazione delle unità di un complesso aggiunta la possibilità di selezionare solo le unità del complesso di primo livello e la possibilità di non effettuare la paginazione dei risultati per poter selezionare tutte le unità di un complesso.
  * nella visualizzazione elenco di produttori, conservatori, complessi, indici, progetti, fonti e unità il filtro è stato reso sempre visibile indipendentemente dal numero di risultati
  * modificato il nome del file prodotto con l'esportazione in formato aef in modo che contenga l'indicazione dell'entità di riferimento che è stata esportata (Es.: archimista-export_complesso-20160921182205.aef)

## Archimista 2.1.0 versione server e stand alone – 28 marzo 2016
* Ridisegno unità speciali, in particolare per la descrizione di schede unità documentaria di tipo CARS – cartografia storica, D-Disegno, DT-Disegno Tecnico, S-Stampa
* Migliorameno vocabolari controllati scheda Progetto
* Miglioramento scheda Gruppo, per gestione delle pubblicazioni in ArchiVista con filtri corrispondenti ai gruppi di lavoro
* Risoluzione bug per Indici
* Risoluzione bug per per report pdf su versioni stand alone

## ArchiVista 2.0.0 versione server e stand alone (prima ArchimistaWeb solo versione server) – 28 marzo 2016
* Introduzione della versione stand alone per consentire la visione dei dati sulle postazioni stand alone su cui è installato Archimista stand alone
* Gestione multisito: possibilità di creare una home page per ogni gruppo di lavoro presente in Archimista che consenta la ricerca e navigazione sui soli dati del gruppo
* Miglioramento visualizzazione unità speciali

## Archimista Web 1.0.0 – 14 marzo 2014
* Rilascio iniziale della versione 1.0.0

## Archimista 2.0.0 - 23 novembre 2015
* Aggiornamento del framework, in particolare
  * versione server: Ruby 2.1.5 e Rails 4.2.1
  * versione stand alone per sistemi Windows successivi a XP: Ruby 2.1.5 e Rails 4.2.1
  * versione stand alone per sistemi Windows XP: Ruby versione 2.0.0 e Rails 4.2.1
* Report personalizzati, in particolare:
  * possibilità di scelta dei campi da inserire per le entità (Progetto, Conservatore, Produttore, Complesso, Unità)
  * possibilità di inserire o togliere le etichette dei campi per ogni entità
* Relazione tra fonti e altre entità, in particolare
  * possibilità dalla scheda Fonte di creare una relazione con istanze delle entità Complesso, Conservatore, Produttore

## Archimista 1.2.1 - 18 giugno 2013
* Correzione errore nell’importazione aef di complessi archivistici con sottounità in un’istanza di Archimista con altri complessi archivistici comprensivi di sottounità
* Risoluzione della visualizzazione incompleta degli elenchi nei report rtf
Vedi elenco [completo delle correzioni](https://github.com/codexcoop/archimista/compare/v1.2.0...v1.2.1)

## Archimista 1.2.0 - 25 marzo 2013
La versione consolida e migliora le funzionalità dell’applicazione, con particolare riguardo a Oggetti digitali, Unità e Report.
### Oggetti digitali
* Funzionalità di upload multiplo di file per singolo record di entità (Unità archivistica, Soggetto produttore, ecc.)
* Funzionalità di riordino dei file mediante *drag and drop*
* Migliorata l'interfaccia utente
### Unità
* Possibilità di creare unità di terzo livello (sottosottounità)
* Possibilità di modificare il livello delle unità (trasformare unità in sottounità e viceversa, trasformare sottounità in sottosottounità e viceversa)
* Visualizzazione del numero di sequenza di sottounità e sottounità nella forma: 1.1, 1.1.1
### Report
* Migliorato il report *Inventario*
* Migliorato il report *Etichette unità*, con possibilità di esportazione in formato CSV / Excel per una completa personalizzazione mediante word processor
* Migliorato il report *Lista unità*, con possibilità di esportazione in formato CSV / Excel
* Aggiunto il report per *Soggetto conservatore*
* Aggiunto il report per *Progetto*
### Correzioni di bug
* Unità: in modalità tabella talvolta non era possibile digitare spazi nei campi testo e nelle caselle dei filtri. Riferimento: [http://www.archiviando.org/forum/viewtopic.php?f=65&t=1388](http://www.archiviando.org/forum/viewtopic.php?f=65&t=1388)
* Soggetti produttori: nella creazione di nuova scheda Persona non si visualizzavano i campi "Luogo di nascita" e "Luogo di morte"
* Varie correzioni minori

## Archimista 1.1.0 - 22 giugno 2012
* Migliorate le funzionalità di Esporta / Importa (in formato *aef*). È ora possibile esportare e importare i dati non solo di singoli complessi archivistici, ma anche di insiemi di complessi archivistici collegati a un soggetto conservatore o a un progetto.
* Risolto il problema che azzerava il numero di sequenza delle unità nelle azioni di riordino (si verificava solo nella versione standalone; bug segnalato sul [Forum Archiviando](http://www.archiviando.org/forum/viewtopic.php?f=65&t=1115)
* Risolto il problema che impediva di "catturare" i nomi di compilatori nelle schede di altre entità (si verificava solo nella versione standalone)
* Modifiche minori del codice di programmazione e dell'interfaccia utente

## Archimista 1.0.0 - 20 aprile 2012
* Rilascio iniziale della versione 1.0.0
