## Archimista
Archimista è un'applicazione web open source per la descrizione di archivi storici. È disponibile in due versioni: standalone e server.
Versione corrente: **3.1.0**

## Requisiti
Archimista funziona sui sistemi operativi GNU/Linux, Mac OS X, Windows Vista e superiori. Per Windows XP è necessario utilizzare una versione apposita

* Ruby 2.1.5
* Rails 4.2.1
* Varie gemme Ruby dichiarate nel file Gemfile
* Gemma rubyzip
* ImageMagick (opzionale, per la gestione di oggetti digitali)
* Database: MySQL (>= 5.1) o PostgreSQL (>= 9.1) o SQLite
* Webserver configurato per applicazioni Rails

## Installazione
Per Windows, versione standalone, è disponibile un pacchetto di installazione, scaricabile dal sito ufficiale: [http://www.archimista.it](http://www.archimista.it).

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

## Crediti
Archimista è un progetto promosso da:

* Direzione Generale per gli Archivi
* Regione Lombardia, Direzione Generale Istruzione, Formazione e Cultura
* Università degli Studi di Pavia
* Politecnico di Milano

## Autori
Codex Società Cooperativa, Pavia
* [http://www.codexcoop.it](http://www.codexcoop.it)
TAI S.a.s.
* [http://www.taisas.com](http://www.taisas.com)

Lo sviluppo attuale è curato da INGLOBA360 s.r.l.
* [http://www.ingloba360.it](http://www.ingloba360.it)

## Licenza
Archimista è rilasciato sotto licenza GNU General Public License v2.0 o successive.
