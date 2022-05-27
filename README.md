## Archimista
Archimista è un'applicazione web open source per la descrizione di archivi storici. È disponibile in due versioni: standalone e server.
La versione corrente è la **3.1.1**.

## Requisiti
Archimista funziona sui sistemi operativi GNU/Linux, Mac OS X, Windows Vista e superiori. Per Windows XP è necessario utilizzare una versione apposita che viene compilata allo scopo.
I requisiti generali dell’applicazione sono i seguenti:
* Ruby 2.1.5
* Rails 4.2.1
* Varie gemme Ruby dichiarate nel file Gemfile
* Gemma rubyzip
* ImageMagick (opzionale, per la gestione di oggetti digitali)
* Database: MySQL (>= 5.1) o PostgreSQL (>= 9.1) o SQLite
* Webserver configurato per applicazioni Rails

## Installazione
Sono disponibili le versioni standalone con un proprio pacchetto di installazione per le versioni windows XP e per le versioni superiori. I pacchetti di installazione sono disponibili su github nella directory releases.
Per la versione server, nel caso di prima installazione:
1. Predisporre il proprio computer con il software indicato nei Requisiti
2. Creare un file di configurazione per il database: config/database.yml. Per maggiori informazioni leggi: [http://guides.rubyonrails.org/v2.3.11/getting_started.html#configuring-a-database](http://guides.rubyonrails.org/v2.3.11/getting_started.html#configuring-a-database)
3. Eseguire il task rake gems:install
4. Eseguire il task RAILS_ENV=production rake db:setup
5. Nel file config/initializers/metadata.rb modificare la variabile BASE_URL inserendo il proprio url di archivista, modificare il file tmp/Configurazione_dl.rb con i dati da usare negli export SAN
6. Avviare il webserver

L'utente per il primo login è:
* user: admin_archimista
* pass: admin_archimista

Nel caso di aggiornamento da versioni precedenti dell'applicazione:
1. Eseguire il task RAILS_ENV=production rake db:migrate
2. Eseguire il task RAILS_ENV=production rake assets:clean

## Macchina virtuale
È possibile utilizzare una macchina virtuale già pronta per l'utilizzo di archimista e archivista scaricandola dal seguente url:
[http://archimista.icar.beniculturali.it/downloads/2021-02-06-archimista.ova](http://archimista.icar.beniculturali.it/downloads/2021-02-06-archimista.ova) (*se si dovessero verificare problemi nell'apertura del link, è consigliato copiare e incollare l'url in un nuovo tab del browser manualmente*)

Di seguito il link alla guida all'uso della macchina virtuale:
[http://archimista.icar.beniculturali.it/downloads/VM-Archimista-manuale.pdf](http://archimista.icar.beniculturali.it/downloads/VM-Archimista-manuale.pdf)

*NB: VirtualBox non è al momento compatibile con chip M1*

## Supporto a Windows XP
In considerazione dell'obsolescenza del sistema operativo Windows XP, non più supportato da Microsoft dal 2014, non è stato possibile verificare appieno le funzionalità della versione archimista 3.1.1 per XP, e quindi non se ne raccomanda l'installazione. A partire dalle versioni di archimista successive alla 3.1.1, Windows XP non sarà più supportato.

## FAQ
Consulta le FAQ per risolvere problemi comuni come ad esempio la gestione di export di dimensioni maggiori di 4GB o scoprire come utilizzare al meglio archimista.
[https://github.com/ProgettoArchimista/archimista/blob/master/FAQ.md](https://github.com/ProgettoArchimista/archimista/blob/master/FAQ.md)

## Crediti
Archimista è un progetto promosso da:
* [Direzione Generale per gli Archivi](http://www.regione.lombardia.it)
* [ICAR – Istituto Centrale per gli Archivi](http://www.icar.beniculturali.it/)
* [Regione Lombardia, Direzione Generale Istruzione, Formazione e Cultura](http://www.regione.lombardia.it/wps/portal/istituzionale/HP/istituzione/direzioni-generali/direzione-generale-autonomia-e-cultura)
* [Università degli Studi di Pavia](http://www.unipv.eu/site/home.html)
* [Politecnico di Milano](https://www.polimi.it/)
* [Regione Piemonte](https://www.regione.piemonte.it/)

## Autori
Codex Società Cooperativa, Pavia ([http://www.codexcoop.it](http://www.codexcoop.it))
TAI S.a.s. ([http://www.taisas.com](http://www.taisas.com))
Lo sviluppo attuale è curato da INGLOBA360 s.r.l. ([http://www.ingloba360.it](http://www.ingloba360.it))

## Licenza
Archimista è rilasciato sotto licenza GNU General Public License v2.0 o successive.

