## Archimista FAQ 3.1.0

**È possibile estrarre un complesso o un’unità includendo tutta la gerarchia (ascendenza e discendenza)?**
Sì. Il tracciato relativo ad un complesso ora contiene: tutta l’ascendenza (se presente) a partire dal complesso radice secondo una struttura breve contenente solo *unitid* e *unittitle*; il complesso oggetto di esportazione; tutta la discendenza (se presente); le unità archivistiche associate al complesso oggetto di esportazione ed ai complessi figli. Il tracciato relativo ad una unità ora contiene: tutta l’ascendenza sia in termini di complessi che di unità a partire dal complesso radice secondo una struttura breve contenente solo *unitid* e *unittitle*; l’unità oggetto di esportazione; tutta la discendenza (se presente).

**Come avviene l’esportazione di dati secondo il nuovo tracciato ICAR-IMPORT?**
L’esportazione avviene in un unico file, di un complesso archivistico e di tutte le entità ad esso associate.
Il tracciato ICAR-IMPORT è costruito a partire da un complesso archivistico (radice o non) ed include le seguenti entità:
* complesso archivistico secondo il tracciato EAD3 (con tutta la gerarchia ascendente e discendente);
* i complessi figli sono inseriti con tutte le informazioni che il tracciato prevede;
* ogni unità comprende gli oggetti digitali collegati (file inclusi nell’archivio zip insieme al file ICAR-IMPORT);
* i soggetti conservatori collegati al complesso radice secondo il tracciato SCONS2;
* i soggetti produttori collegati al complesso oggetto di esportazione o ad uno dei suoi complessi figli secondo il tracciato EAC-CPF; 
* i profili istituzionali collegati ai soggetti produttori secondo il tracciato EAC-CPF;
* le schede anagrafiche collegate alle unità incluse secondo il tracciato EAC-CPF;
* le fonti archivistiche collegate al complesso oggetto di esportazione o ai complessi figli secondo il tracciato EAD3.

**È possibile creare una scheda sottofascicolo?**
Sì. È possibile crearla, dalla schermata in cui compare la lista delle unità relative ad un determinato complesso archivistico, è sufficiente cliccare sul bottone “crea sottofascicolo”. E’ anche possibile reiterare l’operazione su più livelli.

**Gli aef prodotti con le precedenti versioni si importano senza problemi?**
Sì. Gli aef delle versioni sono sempre importati: si è scelto di gestire sempre la compatibilità con le versioni precedenti.
Anche i dati delle schede speciali prodotti con le versioni precedenti (sino alla versione 2.0.0) sono riconvertiti automaticamente e riportati nei nuovi campi delle schede unità di tipo unità documentaria al variare del tracciato di riferimento (in particolare D, F, S).
Tutti i dati delle vecchie schede speciali che non hanno corrispondenza nelle nuove (OA, BDM) sono salvati nel campo “descrizione estrinseca” (unità documentaria).

**Per installare la nuova versione si sovrascrive la vecchia versione o è meglio disinstallare e reinstallare?**
Quando si procede a una nuova installazione della versione standalone, il database eventualmente già presente viene automaticamente aggiornato alla nuova versione (dati ed eventuali oggetti digitali).
Questo avviene anche se si procede alla disinstallazione della versione precedente (operazione consigliata), perché il database non viene mai rimosso.

**Perché in Unità non visualizzo più il pulsante “Vai a scheda speciale” presente sino alla versione 2.0.0?**
La nuova versione 2.1.0 ha modificato il concetto di scheda speciale: in modalità scheda unità documentaria (da Unità), l’utente può richiedere l’attivazione di campi speciali, per la descrizione di schede unità documentaria di tipo:
* CARS Cartografia storica
* D Disegno
* DT Disegno tecnico
* F Fotografia
* S Stampa

Per altri dettagli consulta la pagina [Note di rilascio](http://www.archimista.it/?page_id=30)

**Le novità già introdotte dalla versione 2.0.0 riguardano:**
* Report
  * possibilità di personalizzare il report scegliendo quali campi mostrare per le entità Progetto, Produttore, Conservatore, Complesso archivistico e Unità
  * scelta per la visualizzazione o non visualizzazione del nome del campo per ogni entità principale
*Esempio di report con etichetta del campo*
`Titolo`
`“Titolo della mia unità”`
`Estremi cronologici 1977-2015`
*Esempio di report senza etichetta del campo*
`“Titolo della mia unità”`
`1977-2015`
  * possibilità di inserimento dei campi delle schede speciali Unità
* Fonti
  * possibilità di creare relazioni fra Fonti e le entità principali direttamente dalla scheda Fonte

Per dettagli consulta la pagina [Note di rilascio](http://www.archimista.it/?page_id=30)

**Le novità introdotte dalla versione 1.2.1 riguardano**
* esportazioni e importazioni, possibili sia per Complesso, sia per Progetto oppure Conservatore
* produzione di report per Complesso archivistico, Progetto o Soggetto conservatore
* upload multiplo di oggetti digitali
* creazione sotto-unità e sotto-sotto-unità e possibilità di modificarne il livello
